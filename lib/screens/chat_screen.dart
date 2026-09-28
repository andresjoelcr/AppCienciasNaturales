import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/app_config.dart';
import '../services/firestore_service.dart';
import '../services/guia_context_service.dart';
import '../theme/app_theme.dart';
import 'chat_history_screen.dart';

class ChatScreen extends StatefulWidget {
  final String? sessionId;

  const ChatScreen({super.key, this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  late AnimationController _animationController;

  // Speech to Text
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
    _initSpeech();

    if (widget.sessionId != null) {
      _firestoreService.setCurrentSession(widget.sessionId);
      _loadSessionMessages();
    }
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    setState(() {});
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El reconocimiento de voz no esta disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _messageController.text = result.recognizedWords;
        });

        // Si el resultado es final, detener y enviar automáticamente
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _stopListening();
          // Pequeño delay para asegurar que el estado se actualice
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _messageController.text.isNotEmpty) {
              _sendMessage(_messageController.text);
            }
          });
        }
      },
      localeId: 'es_ES',
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
      ),
    );
    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  Future<void> _loadSessionMessages() async {
    if (widget.sessionId == null) return;

    setState(() => _isLoadingHistory = true);

    final messages = await _firestoreService.getSessionMessagesOnce(
      widget.sessionId!,
    );

    setState(() {
      for (var msg in messages) {
        _messages.add(ChatMessage(text: msg['userMessage'], isUser: true));
        _messages.add(ChatMessage(text: msg['botResponse'], isUser: false));
      }
      _isLoadingHistory = false;
    });

    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Obtener el prompt del sistema con el contexto de la guía didáctica
      final systemPrompt = GuiaContextService.getSystemPromptConGuia();

      final botResponse = await _callGroqWithRetry(systemPrompt, text);

      setState(() {
        _messages.add(ChatMessage(text: botResponse, isUser: false));
        _isLoading = false;
      });

      await _firestoreService.saveMessage(
        userMessage: text,
        botResponse: botResponse,
      );

      // Incrementar contador de preguntas para logros
      await _firestoreService.incrementChatQuestions();
    } catch (e) {
      debugPrint('[Chat] Excepcion: $e');
      final errorMsg =
          e.toString().contains('TimeoutException')
              ? 'La solicitud tardo demasiado. Verifica tu conexion e intentalo de nuevo.'
              : e.toString().contains('[Chat]')
              ? e.toString().replaceFirst('Exception: [Chat] ', '')
              : 'Error de conexion. Verifica tu internet.';
      setState(() {
        _messages.add(ChatMessage(text: errorMsg, isUser: false));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startNewChat() {
    _firestoreService.clearCurrentSession();
    setState(() {
      _messages.clear();
    });
  }

  /// Llama a la API de Groq con hasta 3 reintentos ante error 429
  Future<String> _callGroqWithRetry(
    String systemPrompt,
    String userText, {
    int attempt = 1,
  }) async {
    final keyProblem = AppConfig.groqApiKeyProblem;
    if (keyProblem != null) {
      debugPrint('[Chat] Sin credencial de Groq: $keyProblem');
      throw Exception('[Chat] $keyProblem');
    }

    final response = await http
        .post(
          Uri.parse(AppConfig.groqApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AppConfig.groqApiKey}',
          },
          body: jsonEncode({
            'model': AppConfig.groqModel,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userText},
            ],
            'max_tokens': 1024,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        // Los modelos de razonamiento pueden gastar todo max_tokens en el
        // razonamiento y devolver content nulo.
        throw Exception(
          '[Chat] La IA no genero respuesta. Intentalo de nuevo.',
        );
      }
      return content;
    }

    if (response.statusCode == 429 && attempt == 1) {
      debugPrint('[Chat] Rate limit (429), reintento en 30s...');
      await Future.delayed(const Duration(seconds: 30));
      return _callGroqWithRetry(systemPrompt, userText, attempt: 2);
    }

    debugPrint('[Chat] Error HTTP ${response.statusCode}: ${response.body}');
    switch (response.statusCode) {
      case 401:
      case 403:
        throw Exception(
          '[Chat] La clave de la IA no es valida o no tiene permisos. Revisa GROQ_API_KEY en el archivo .env.',
        );
      case 404:
        throw Exception(
          '[Chat] El modelo "${AppConfig.groqModel}" ya no esta disponible. Actualiza GROQ_MODEL en el archivo .env.',
        );
      case 429:
        throw Exception(
          '[Chat] Servicio ocupado. Espera unos segundos e intentalo de nuevo.',
        );
      case 500:
      case 503:
        throw Exception(
          '[Chat] El servicio de IA no esta disponible. Intenta mas tarde.',
        );
      default:
        throw Exception('[Chat] Lo siento, hubo un error. Intentalo de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asistente Natural',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.mintGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'En linea',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, size: 20),
            ),
            onPressed: _startNewChat,
            tooltip: 'Nuevo chat',
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.history, size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatHistoryScreen(),
                ),
              );
            },
            tooltip: 'Historial',
          ),
        ],
      ),
      body:
          _isLoadingHistory
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              )
              : Column(
                children: [
                  Expanded(
                    child:
                        _messages.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                return _messages[index];
                              },
                            ),
                  ),
                  if (_isLoading) _buildTypingIndicator(),
                  _buildMessageInput(),
                ],
              ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _animationController,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 56,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Hola! Soy tu asistente',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preguntame sobre ciencias naturales',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.greyText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildSuggestionChip('Que temas tienes en la guia?'),
                  _buildSuggestionChip('Que es la celula?'),
                  _buildSuggestionChip('Partes de la celula'),
                  _buildSuggestionChip('Celula animal y vegetal'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _sendMessage(text),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppColors.sunOrange,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
                const SizedBox(width: 10),
                Text(
                  'Pensando...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.4 + (value * 0.6)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.lightGreen, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.eco_outlined,
                          color: AppColors.primaryGreen,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Escribe tu pregunta...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.greyText.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 14,
                            ),
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.darkText,
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Botón de micrófono
              Container(
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red : AppColors.lightGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _isListening
                            ? Colors.red
                            : AppColors.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isListening ? _stopListening : _startListening,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        color:
                            _isListening
                                ? Colors.white
                                : AppColors.primaryGreen,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _sendMessage(_messageController.text),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryGreen : AppColors.lightGreen,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 20),
                ),
                border: Border.all(
                  color:
                      isUser
                          ? AppColors.primaryGreen
                          : AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isUser ? Colors.white : const Color(0xFF212121),
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.skyBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
