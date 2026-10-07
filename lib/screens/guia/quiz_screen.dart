import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/quiz_model.dart';
import '../../models/achievement_model.dart';
import '../../services/firestore_service.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  final String subtemaNumero;
  final String subtemaId;
  final String subtemaTitulo;
  final bool esGeneradoPorIA;

  const QuizScreen({
    super.key,
    required this.quiz,
    required this.subtemaNumero,
    required this.subtemaId,
    required this.subtemaTitulo,
    this.esGeneradoPorIA = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _preguntaActual = 0;
  int? _respuestaSeleccionada;
  bool _respondida = false;
  int _respuestasCorrectas = 0;
  bool _quizTerminado = false;
  late AnimationController _animationController;

  // Tracking
  final FirestoreService _firestoreService = FirestoreService();
  bool _resultadoGuardado = false;
  int _xpGanado = 0;
  List<Achievement> _logrosDesbloqueados = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _seleccionarRespuesta(int index) {
    if (_respondida) return;

    setState(() {
      _respuestaSeleccionada = index;
      _respondida = true;
      if (index == widget.quiz.preguntas[_preguntaActual].respuestaCorrecta) {
        _respuestasCorrectas++;
      }
    });
  }

  void _siguientePregunta() {
    if (_preguntaActual < widget.quiz.preguntas.length - 1) {
      _animationController.reset();
      setState(() {
        _preguntaActual++;
        _respuestaSeleccionada = null;
        _respondida = false;
      });
      _animationController.forward();
    } else {
      setState(() {
        _quizTerminado = true;
      });
      _guardarResultado();
    }
  }

  Future<void> _guardarResultado() async {
    if (_resultadoGuardado) return;

    final resultado = await _firestoreService.saveQuizResult(
      subtemaId: widget.subtemaId,
      subtemaTitulo: widget.subtemaTitulo,
      score: _respuestasCorrectas,
      totalPreguntas: widget.quiz.preguntas.length,
    );

    if (resultado['success'] == true) {
      setState(() {
        _resultadoGuardado = true;
        _xpGanado = resultado['xpGanado'] ?? 0;
        _logrosDesbloqueados = resultado['nuevosLogros'] ?? [];
      });
    }
  }

  void _reiniciarQuiz() {
    _animationController.reset();
    setState(() {
      _preguntaActual = 0;
      _respuestaSeleccionada = null;
      _respondida = false;
      _respuestasCorrectas = 0;
      _quizTerminado = false;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_quizTerminado) {
      return _buildResultadosScreen();
    }

    final pregunta = widget.quiz.preguntas[_preguntaActual];
    final progreso = (_preguntaActual + 1) / widget.quiz.preguntas.length;

    return Scaffold(
      backgroundColor: AppColors.cloudWhite,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 60,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => _mostrarDialogoSalir(),
        ),
        title: Row(
          children: [
            Text(
              'Quiz ${widget.subtemaNumero}',
              style: AppTextStyles.heading3.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            if (widget.esGeneradoPorIA) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sunOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'IA',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_preguntaActual + 1}/${widget.quiz.preguntas.length}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de progreso
          Container(
            height: 6,
            width: double.infinity,
            color: AppColors.lightGreen,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progreso,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _animationController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Numero de pregunta
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.skyBlue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Pregunta ${_preguntaActual + 1}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.oceanBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Pregunta
                      Text(
                        pregunta.pregunta,
                        style: AppTextStyles.heading2.copyWith(
                          fontSize: 20,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Opciones
                      ...List.generate(pregunta.opciones.length, (index) {
                        return _buildOpcion(
                          index: index,
                          texto: pregunta.opciones[index],
                          esCorrecta: index == pregunta.respuestaCorrecta,
                        );
                      }),

                      // Explicacion
                      if (_respondida && pregunta.explicacion != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.skyBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.oceanBlue,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Explicacion',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.oceanBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pregunta.explicacion!,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Boton siguiente
          if (_respondida)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _siguientePregunta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _preguntaActual < widget.quiz.preguntas.length - 1
                          ? 'Siguiente Pregunta'
                          : 'Ver Resultados',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOpcion({
    required int index,
    required String texto,
    required bool esCorrecta,
  }) {
    Color backgroundColor = Colors.white;
    Color borderColor = AppColors.greyText.withOpacity(0.2);
    Color textColor = AppColors.darkText;
    IconData? iconData;

    if (_respondida) {
      if (esCorrecta) {
        backgroundColor = AppColors.leafGreen.withOpacity(0.15);
        borderColor = AppColors.leafGreen;
        textColor = AppColors.primaryGreen;
        iconData = Icons.check_circle_rounded;
      } else if (_respuestaSeleccionada == index) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red;
        iconData = Icons.cancel_rounded;
      }
    } else if (_respuestaSeleccionada == index) {
      backgroundColor = AppColors.skyBlue.withOpacity(0.15);
      borderColor = AppColors.skyBlue;
      textColor = AppColors.oceanBlue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _seleccionarRespuesta(index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        _respondida &&
                                (esCorrecta || _respuestaSeleccionada == index)
                            ? (esCorrecta ? AppColors.leafGreen : Colors.red)
                            : AppColors.greyText.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        iconData != null
                            ? Icon(iconData, color: Colors.white, size: 20)
                            : Text(
                              String.fromCharCode(65 + index),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    _respuestaSeleccionada == index
                                        ? AppColors.oceanBlue
                                        : AppColors.greyText,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texto,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: textColor,
                      fontWeight:
                          _respondida && esCorrecta
                              ? FontWeight.w600
                              : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultadosScreen() {
    final porcentaje =
        (_respuestasCorrectas / widget.quiz.preguntas.length) * 100;
    final esAprobado = porcentaje >= 60;

    return Scaffold(
      backgroundColor: AppColors.cloudWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de resultado
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color:
                        esAprobado
                            ? AppColors.leafGreen.withOpacity(0.15)
                            : AppColors.sunOrange.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    esAprobado
                        ? Icons.emoji_events_rounded
                        : Icons.refresh_rounded,
                    size: 60,
                    color:
                        esAprobado ? AppColors.leafGreen : AppColors.sunOrange,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  esAprobado ? 'Excelente!' : 'Sigue practicando!',
                  style: AppTextStyles.heading1.copyWith(
                    color:
                        esAprobado
                            ? AppColors.primaryGreen
                            : AppColors.sunOrange,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Has completado el quiz del subtema ${widget.subtemaNumero}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.greyText,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (widget.esGeneradoPorIA) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sunOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.sunOrange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.sunOrange,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quiz generado con IA',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.sunOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Estadisticas
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${porcentaje.toInt()}%',
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 48,
                          color:
                              esAprobado
                                  ? AppColors.primaryGreen
                                  : AppColors.sunOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_respuestasCorrectas de ${widget.quiz.preguntas.length} respuestas correctas',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.darkText,
                        ),
                      ),
                      if (_xpGanado > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sunYellow.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                color: AppColors.sunOrange,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+$_xpGanado XP',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.sunOrange,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Logros desbloqueados
                if (_logrosDesbloqueados.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.sunYellow.withOpacity(0.2),
                          AppColors.sunOrange.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.sunYellow.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: AppColors.sunOrange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nuevo Logro!',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.sunOrange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._logrosDesbloqueados.map(
                          (logro) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: logro.color.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    logro.icono,
                                    color: logro.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        logro.nombre,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        logro.descripcion,
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: logro.color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '+${logro.puntos}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: logro.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reiniciarQuiz,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: AppColors.primaryGreen,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reintentar',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                            ..pop()
                            ..pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.home_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Volver',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoSalir() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.sunOrange),
                const SizedBox(width: 8),
                const Text('Salir del Quiz'),
              ],
            ),
            content: const Text(
              'Si sales ahora, perderas tu progreso en este quiz. Estas seguro?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.greyText),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sunOrange,
                ),
                child: const Text(
                  'Salir',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
