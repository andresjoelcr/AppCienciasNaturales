import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../theme/app_theme.dart';
import '../../models/subtema_model.dart';
import '../../services/firestore_service.dart';
import '../../services/quiz_generator_service.dart';
import '../../widgets/quiz_type_selector.dart';
import '../../widgets/quiz_loading_screen.dart';
import 'quiz_screen.dart';
import '../chat_screen.dart';

class SubtemaScreen extends StatefulWidget {
  final Subtema subtema;

  const SubtemaScreen({super.key, required this.subtema});

  @override
  State<SubtemaScreen> createState() => _SubtemaScreenState();
}

class _SubtemaScreenState extends State<SubtemaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _showFloatingButton = false;
  final FirestoreService _firestoreService = FirestoreService();
  final Map<int, YoutubePlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Inicializar controladores de video
    for (int i = 0; i < widget.subtema.contenido.length; i++) {
      final seccion = widget.subtema.contenido[i];
      if (seccion.tipo == 'video') {
        final videoId = YoutubePlayer.convertUrlToId(seccion.contenido);
        if (videoId != null) {
          _videoControllers[i] = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              enableCaption: true,
            ),
          );
        }
      }
    }

    // Marcar contenido como visto
    _marcarContenidoVisto();
  }

  Future<void> _marcarContenidoVisto() async {
    await _firestoreService.markContenidoVisto(
      widget.subtema.id,
      widget.subtema.titulo,
    );
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showFloatingButton) {
      setState(() => _showFloatingButton = true);
    } else if (_scrollController.offset <= 200 && _showFloatingButton) {
      setState(() => _showFloatingButton = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subtema ${widget.subtema.numero}',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              widget.subtema.titulo,
              style: AppTextStyles.heading3.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatScreen(),
                  ),
                );
              },
              tooltip: 'Preguntar al asistente',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Header con descripcion
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.lightGreen.withOpacity(0.5),
                    Colors.white,
                  ],
                ),
              ),
              child: FadeTransition(
                opacity: _animationController,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.subtema.descripcion,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.subtema.contenido.asMap().entries.map((entry) {
                    final index = entry.key;
                    final seccion = entry.value;
                    return _buildSeccionContenido(seccion, index);
                  }),

                  const SizedBox(height: 24),

                  // Boton para preguntar al chatbot
                  _buildChatbotButton(),

                  const SizedBox(height: 16),

                  // Boton para ir al quiz
                  _buildQuizButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton.extended(
              onPressed: _navegarAlQuiz,
              backgroundColor: AppColors.primaryGreen,
              icon: const Icon(Icons.quiz_rounded, color: Colors.white),
              label: Text(
                'Ir al Quiz',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildSeccionContenido(ContenidoSeccion seccion, int index) {
    final delay = 0.1 + (index * 0.05);
    final endDelay = delay + 0.4;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          delay.clamp(0.0, 0.9),
          endDelay.clamp(0.1, 1.0),
          curve: Curves.easeOut,
        ),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay.clamp(0.0, 0.9), endDelay.clamp(0.1, 1.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSeccionWidget(seccion, index),
        ),
      ),
    );
  }

  Widget _buildSeccionWidget(ContenidoSeccion seccion, int index) {
    switch (seccion.tipo) {
      case 'titulo':
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            seccion.contenido,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primaryGreen,
            ),
          ),
        );

      case 'subtitulo':
        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primaryGreen.withOpacity(0.3),
            ),
          ),
          child: Text(
            seccion.contenido,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryGreen,
              fontSize: 16,
            ),
          ),
        );

      case 'texto':
        return Text(
          seccion.contenido,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.darkText,
            height: 1.6,
          ),
        );

      case 'lista':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (seccion.contenido.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  seccion.contenido,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ...?seccion.items?.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.leafGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.darkText,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        );

      case 'destacado':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.skyBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.skyBlue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.oceanBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  seccion.contenido,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.oceanBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

      case 'sabias_que':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.sunOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.sunOrange.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.sunOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sabias que...?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.sunOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      seccion.contenido,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 'imagen':
        final caption = (seccion.items != null && seccion.items!.isNotEmpty)
            ? seccion.items!.first
            : null;
        return Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  seccion.contenido,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 10),
              Text(
                caption,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.greyText,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );

      case 'imagen_comparativa':
        final paths = seccion.contenido.split('|');
        final labels = seccion.items ?? [];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGreen.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < paths.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      if (i < labels.length)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            labels[i],
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            paths[i].trim(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );

      case 'imagen_grid':
        final paths = seccion.contenido.split('|');
        final labels = seccion.items ?? [];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: paths.length,
          itemBuilder: (context, i) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(
                        paths[i].trim(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  if (i < labels.length)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        labels[i],
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            );
          },
        );

      case 'video':
        final videoTitle = (seccion.items != null && seccion.items!.isNotEmpty)
            ? seccion.items!.first
            : 'Video explicativo';
        final controller = _videoControllers[index];
        if (controller == null) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titulo del video
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.red.shade600,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      videoTitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Player
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red.shade600,
                progressColors: ProgressBarColors(
                  playedColor: Colors.red.shade600,
                  handleColor: Colors.red.shade700,
                ),
              ),
            ),
          ],
        );

      default:
        return Text(seccion.contenido);
    }
  }

  Widget _buildChatbotButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.skyBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: AppColors.oceanBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tienes dudas?',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.oceanBlue,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pregunta al asistente sobre este tema',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.oceanBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pon a prueba tus conocimientos!',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuizBadge(
                Icons.list_alt_rounded,
                '${widget.subtema.quiz.preguntas.length} preguntas',
              ),
              const SizedBox(width: 12),
              _buildQuizBadge(
                Icons.auto_awesome_rounded,
                'Quiz con IA',
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navegarAlQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow_rounded),
                const SizedBox(width: 8),
                Text(
                  'Comenzar Quiz',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navegarAlQuiz() async {
    // Mostrar dialog de seleccion de tipo de quiz
    final resultado = await showDialog(
      context: context,
      builder: (context) => QuizTypeSelectorDialog(
        preguntasQuizEstatico: widget.subtema.quiz.preguntas.length,
      ),
    );

    if (resultado == null) return;

    if (resultado == QuizType.estatico) {
      // Usar quiz estatico existente
      _iniciarQuizEstatico();
    } else if (resultado is IAQuizConfig) {
      // Generar quiz con IA
      _generarQuizConIA(resultado);
    }
  }

  void _iniciarQuizEstatico() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          quiz: widget.subtema.quiz,
          subtemaNumero: widget.subtema.numero,
          subtemaId: widget.subtema.id,
          subtemaTitulo: widget.subtema.titulo,
        ),
      ),
    );
  }

  Future<void> _generarQuizConIA(IAQuizConfig config) async {
    // Mostrar pantalla de carga
    bool cancelado = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => QuizLoadingScreen(
        subtemaTitulo: widget.subtema.titulo,
        onCancel: () {
          cancelado = true;
          Navigator.pop(dialogContext);
        },
      ),
    );

    // Generar quiz
    final resultado = await QuizGeneratorService.generarQuiz(
      subtemaId: widget.subtema.id,
      subtemaTitulo: widget.subtema.titulo,
      numeroPreguntas: config.numeroPreguntas,
      dificultad: config.dificultad,
    );

    // Cerrar dialog de carga si aun esta abierto
    if (mounted && !cancelado) {
      Navigator.pop(context);
    }

    if (cancelado) return;

    if (resultado.success && resultado.quiz != null) {
      // Navegar al quiz generado
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              quiz: resultado.quiz!,
              subtemaNumero: widget.subtema.numero,
              subtemaId: widget.subtema.id,
              subtemaTitulo: widget.subtema.titulo,
              esGeneradoPorIA: true,
            ),
          ),
        );
      }
    } else {
      // Mostrar pantalla de error con opciones
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizErrorScreen(
              error: resultado.error ?? 'Error desconocido',
              onRetry: () {
                Navigator.pop(context);
                _generarQuizConIA(config);
              },
              onUseStatic: () {
                Navigator.pop(context);
                _iniciarQuizEstatico();
              },
            ),
          ),
        );
      }
    }
  }
}
