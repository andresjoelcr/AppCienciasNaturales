import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../theme/brand_colors.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _animationsStarted = false;
  late final AnimationController _entryController;
  late final AnimationController _arrivalController;
  late final AnimationController _butterflyController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _butterflyRest;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _arrivalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _butterflyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0, 0.75, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _butterflyRest = CurvedAnimation(
      parent: _butterflyController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _entryController.value = 1;
      _arrivalController.value = 1;
      _butterflyController.stop();
      _butterflyController.value = 0.5;
    } else if (!_animationsStarted) {
      _animationsStarted = true;
      _playEntrance();
    } else if (_arrivalController.isCompleted &&
        !_butterflyController.isAnimating) {
      _butterflyController.repeat(reverse: true);
    }
  }

  Future<void> _playEntrance() async {
    await _entryController.forward();
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;

    await _arrivalController.forward();
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;

    _butterflyController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _arrivalController.dispose();
    _butterflyController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on AuthSignInException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 8),
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(error.message)),
              ],
            ),
            backgroundColor: const Color(0xFFB33A3A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _LoginPalette.ivory,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _LoginPalette.ivory,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final canvasHeight = math.max(constraints.maxHeight, 690.0);
              final canvasWidth = constraints.maxWidth;
              final compact = canvasHeight < 760;
              final plantWidth = math.min(canvasWidth * 0.98, 430.0);
              final plantBottom = compact ? 128.0 : 142.0;
              final plantTop = canvasHeight - plantBottom - (plantWidth * 1.5);

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: canvasWidth,
                  height: canvasHeight,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: compact ? 28 : 42,
                            left: 24,
                            right: 24,
                            child: const _BrandHeader(),
                          ),
                          Positioned(
                            top: compact ? 174 : 202,
                            right: 13,
                            child: const RotatedBox(
                              quarterTurns: 1,
                              child: Text(
                                'OBSERVA  ·  APRENDE  ·  CUIDA',
                                style: TextStyle(
                                  color: _LoginPalette.forestMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.1,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -(plantWidth * 0.16),
                            bottom: plantBottom,
                            width: plantWidth,
                            child: IgnorePointer(
                              child: Image.asset(
                                'assets/login/botanical_plant.png',
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                          Positioned(
                            left: canvasWidth * 0.47,
                            top: plantTop + (plantWidth * 0.30),
                            width: math.min(canvasWidth * 0.27, 108.0),
                            child: _AnimatedButterfly(
                              arrival: _arrivalController,
                              rest: _butterflyRest,
                              viewport: Size(canvasWidth, canvasHeight),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 18,
                            child: _LoginPanel(
                              isLoading: _isLoading,
                              onGooglePressed:
                                  _isLoading ? null : _signInWithGoogle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          header: true,
          label: 'EduRA',
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: -0.18,
                  child: const Icon(
                    Icons.eco_rounded,
                    color: _LoginPalette.forest,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 7),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 43,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.7,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Edu',
                        style: TextStyle(color: _LoginPalette.forest),
                      ),
                      TextSpan(
                        text: 'RA',
                        style: TextStyle(color: _LoginPalette.amber),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ciencias naturales para explorar y aprender',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: _LoginPalette.ink,
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _AnimatedButterfly extends StatelessWidget {
  const _AnimatedButterfly({
    required this.arrival,
    required this.rest,
    required this.viewport,
  });

  final Animation<double> arrival;
  final Animation<double> rest;
  final Size viewport;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mariposa que llega y reposa sobre una hoja',
      image: true,
      child: AnimatedBuilder(
        animation: Listenable.merge([arrival, rest]),
        builder: (context, child) {
          final progress = arrival.value;
          // El recorrido termina antes que el aleteo para dar tiempo al aterrizaje.
          final travel = Curves.easeInOutSine.transform(
            (progress / 0.86).clamp(0.0, 1.0),
          );
          final remaining = 1 - travel;
          final horizontal =
              remaining * remaining * viewport.width * 0.52 +
              2 * remaining * travel * viewport.width * 0.17;
          final vertical =
              remaining * remaining * -viewport.height * 0.16 +
              2 * remaining * travel * -viewport.height * 0.09;
          final inFlight = 1 - travel;
          final wingBeat = math.sin(progress * math.pi * 18);
          final wingScale =
              (0.965 + 0.035 * rest.value) *
              (1 - inFlight * (0.10 + 0.08 * wingBeat));

          return Transform.translate(
            offset: Offset(horizontal, vertical - 1.5 * rest.value * travel),
            child: Transform.rotate(
              angle:
                  -0.045 +
                  0.018 * rest.value +
                  inFlight * (0.17 + 0.045 * wingBeat),
              alignment: Alignment.bottomCenter,
              child: Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.diagonal3Values(wingScale, 1, 1),
                child: child,
              ),
            ),
          );
        },
        child: Image.asset(
          'assets/login/monarch_butterfly.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({required this.isLoading, required this.onGooglePressed});

  final bool isLoading;
  final VoidCallback? onGooglePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
      decoration: BoxDecoration(
        color: _LoginPalette.ivory.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _LoginPalette.forest.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: _LoginPalette.forest.withValues(alpha: 0.13),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            enabled: onGooglePressed != null,
            label:
                isLoading
                    ? 'Iniciando sesión con Google'
                    : 'Continuar con Google',
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: onGooglePressed,
                style: FilledButton.styleFrom(
                  backgroundColor: _LoginPalette.forest,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _LoginPalette.forest.withValues(
                    alpha: 0.75,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child:
                      isLoading
                          ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                          : Row(
                            key: const ValueKey('label'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const _GoogleMark(),
                              const SizedBox(width: 12),
                              Text(
                                'Continuar con Google',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tu progreso se guardará de forma segura.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _LoginPalette.forestMuted,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: const Size.square(17),
        painter: _GoogleMarkPainter(),
      ),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(2.1);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.7
          ..strokeCap = StrokeCap.square;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(arcRect, -0.72, 1.42, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(arcRect, 0.7, 1.35, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(arcRect, 2.05, 0.92, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(arcRect, 2.97, 1.68, false, paint);

    paint
      ..color = const Color(0xFF4285F4)
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(size.width * 0.54, size.height * 0.51),
      Offset(size.width * 0.91, size.height * 0.51),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.84, size.height * 0.51),
      Offset(size.width * 0.84, size.height * 0.72),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

abstract final class _LoginPalette {
  static const forest = BrandColors.forest;
  static const amber = BrandColors.amber;
  static const ivory = BrandColors.ivory;
  static const ink = BrandColors.ink;
  static const forestMuted = BrandColors.forestMuted;
}
