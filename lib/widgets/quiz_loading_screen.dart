import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pantalla de carga mientras se genera el quiz con IA
class QuizLoadingScreen extends StatefulWidget {
  final String subtemaTitulo;
  final VoidCallback? onCancel;

  const QuizLoadingScreen({
    super.key,
    required this.subtemaTitulo,
    this.onCancel,
  });

  @override
  State<QuizLoadingScreen> createState() => _QuizLoadingScreenState();
}

class _QuizLoadingScreenState extends State<QuizLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 0;

  final List<String> _mensajes = [
    'Analizando el contenido del tema',
    'Generando preguntas personalizadas',
    'Creando opciones de respuesta',
    'Preparando explicaciones educativas',
    'Casi listo',
  ];
  int _mensajeIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Cambiar mensaje cada 3 segundos
    _startMessageRotation();

    // Animar puntos suspensivos
    _startDotAnimation();
  }

  void _startMessageRotation() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _mensajeIndex = (_mensajeIndex + 1) % _mensajes.length;
        });
      }
    }
  }

  void _startDotAnimation() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono animado
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * 3.14159,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Titulo
              Text(
                'Generando Quiz con IA',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                widget.subtemaTitulo,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.greyText,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Mensaje animado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        '${_mensajes[_mensajeIndex]}${'.' * _dotCount}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Boton cancelar
              if (widget.onCancel != null)
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(
                    'Cancelar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.greyText,
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

/// Widget de error cuando falla la generacion
class QuizErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onUseStatic;

  const QuizErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onUseStatic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.darkText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de error
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 48,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'No se pudo generar el quiz',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.darkText,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                error,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.greyText,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Boton reintentar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: Text(
                    'Intentar de nuevo',
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Boton usar quiz estatico
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onUseStatic,
                  icon: const Icon(
                    Icons.list_alt_rounded,
                    color: AppColors.primaryGreen,
                  ),
                  label: Text(
                    'Usar Quiz del Tema',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
