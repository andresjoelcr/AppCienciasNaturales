import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/celula_data.dart';
import '../models/user_progress_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/brand_colors.dart';
import 'ar_image_target_screen.dart';
import 'unity_escaneo_screen.dart';
import 'chat_screen.dart';
import 'glosario/glosario_screen.dart';
import 'guia/guia_home_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  List<UserProgress> _progress = const [];
  bool _progressLoading = true;
  bool _progressLoadFailed = false;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _firestoreService.getOrCreateUserProfile();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await _firestoreService.getAllProgressOrThrow();
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _progressLoading = false;
        _progressLoadFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _progressLoading = false;
        _progressLoadFailed = true;
      });
    }
  }

  Future<void> _openGuide() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GuiaHomeScreen()));
    if (mounted) await _loadProgress();
  }

  Future<void> _openProfile() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
    if (mounted) await _loadProgress();
  }

  void _openARModeSelector() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: BrandColors.ivory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder:
          (sheetContext) => _ARModeSelector(
            onSimple: () {
              Navigator.pop(sheetContext);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UnityEscaneoScreen()),
              );
            },
            onImageTarget: () {
              Navigator.pop(sheetContext);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ARImageTargetScreen()),
              );
            },
          ),
    );
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cerrar sesión. Inténtalo de nuevo.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final displayName = user?.displayName?.trim();
    final rawFirstName =
        displayName == null || displayName.isEmpty
            ? 'Estudiante'
            : displayName.split(RegExp(r'\s+')).first;
    final firstName =
        '${rawFirstName[0].toUpperCase()}${rawFirstName.substring(1)}';

    final lessonIds = CelulaData.subtemas.map((lesson) => lesson.id).toSet();
    final completedLessons =
        _progress
            .where(
              (item) => lessonIds.contains(item.subtemaId) && item.completado,
            )
            .length;

    return Scaffold(
      backgroundColor: BrandColors.ivory,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        toolbarHeight: 72,
        backgroundColor: BrandColors.ivory,
        surfaceTintColor: BrandColors.ivory,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: BrandColors.ivory,
          systemNavigationBarColor: BrandColors.ivory,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        title: const _BrandWordmark(),
        actions: [
          _HeaderButton(
            tooltip: 'Mi perfil',
            onPressed: _openProfile,
            child:
                user?.photoURL == null
                    ? const Icon(Icons.person_outline_rounded, size: 23)
                    : CircleAvatar(
                      radius: 17,
                      backgroundImage: NetworkImage(user!.photoURL!),
                    ),
          ),
          const SizedBox(width: 8),
          _HeaderButton(
            tooltip: 'Cerrar sesión',
            onPressed: _signingOut ? null : _signOut,
            child:
                _signingOut
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.logout_rounded, size: 21),
          ),
          const SizedBox(width: 18),
        ],
      ),
      body: RefreshIndicator(
        color: BrandColors.forest,
        onRefresh: _loadProgress,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $firstName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: BrandColors.forest,
                  fontSize: 29,
                  height: 1.18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '¿Qué quieres aprender hoy?',
                style: GoogleFonts.poppins(
                  color: BrandColors.forestMuted,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _ProgressCard(
                completed: completedLessons,
                total: lessonIds.length,
                loading: _progressLoading,
                unavailable: _progressLoadFailed,
                onTap: _openGuide,
              ),
              const SizedBox(height: 28),
              Text(
                'Explora y aprende',
                style: GoogleFonts.poppins(
                  color: BrandColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 12) / 2;
                  final textScale = MediaQuery.textScalerOf(context).scale(14);
                  final cardHeight =
                      154.0 + (textScale - 14).clamp(0.0, 12.0).toDouble() * 4;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: _FeatureCard(
                          icon: Icons.menu_book_outlined,
                          title: 'Guía didáctica',
                          description: 'Lecciones paso a paso',
                          onTap: _openGuide,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: _FeatureCard(
                          icon: Icons.smart_toy_outlined,
                          title: 'Asistente de ciencias',
                          description: 'Pregunta lo que quieras',
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ChatScreen(),
                                ),
                              ),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: _FeatureCard(
                          icon: Icons.center_focus_strong_rounded,
                          title: 'Escáner inteligente',
                          description: 'Identifica plantas y animales',
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ScannerScreen(),
                                ),
                              ),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: _FeatureCard(
                          icon: Icons.view_in_ar_outlined,
                          title: 'Realidad aumentada',
                          description: 'Explora células en 3D',
                          onTap: _openARModeSelector,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.auto_stories_outlined,
                title: 'Glosario',
                description: 'Busca y aprende términos científicos',
                wide: true,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GlosarioScreen()),
                    ),
              ),
              const SizedBox(height: 12),
              const _ScienceTip(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.eco_rounded, color: BrandColors.forest, size: 30),
        const SizedBox(width: 7),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
            children: const [
              TextSpan(
                text: 'Edu',
                style: TextStyle(color: BrandColors.forest),
              ),
              TextSpan(text: 'RA', style: TextStyle(color: BrandColors.amber)),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: BrandColors.forest.withValues(alpha: 0.10)),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        color: BrandColors.forest,
        padding: EdgeInsets.zero,
        icon: child,
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.loading,
    required this.unavailable,
    required this.onTap,
  });

  final int completed;
  final int total;
  final bool loading;
  final bool unavailable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0.0 : completed / total;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: BrandColors.forest.withValues(alpha: 0.09),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _IconTile(icon: Icons.spa_outlined, large: true),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu progreso',
                          style: GoogleFonts.poppins(
                            color: BrandColors.forest,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          loading
                              ? 'Cargando tu avance…'
                              : unavailable
                              ? 'No pudimos sincronizar tu avance'
                              : '$completed de $total lecciones completadas',
                          style: GoogleFonts.poppins(
                            color: BrandColors.forestMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: BrandColors.forest,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value:
                            loading
                                ? null
                                : unavailable
                                ? 0
                                : percentage,
                        minHeight: 7,
                        backgroundColor: BrandColors.ivory,
                        valueColor: const AlwaysStoppedAnimation(
                          BrandColors.amber,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    loading
                        ? '…'
                        : unavailable
                        ? '—'
                        : '${(percentage * 100).round()}%',
                    style: GoogleFonts.poppins(
                      color: BrandColors.forest,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.wide = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: BrandColors.forest.withValues(alpha: 0.09),
            ),
          ),
          child: wide ? _buildWideContent() : _buildGridContent(),
        ),
      ),
    );
  }

  Widget _buildGridContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _IconTile(icon: icon),
            const Icon(
              Icons.arrow_outward_rounded,
              size: 18,
              color: BrandColors.forest,
            ),
          ],
        ),
        const Spacer(),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: BrandColors.forest,
            fontSize: 14,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: BrandColors.forestMuted,
            fontSize: 11,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildWideContent() {
    return Row(
      children: [
        _IconTile(icon: icon),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: BrandColors.forest,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  color: BrandColors.forestMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: BrandColors.forest),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, this.large = false});

  final IconData icon;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 52.0 : 44.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: BrandColors.amber.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(large ? 16 : 13),
      ),
      child: Icon(icon, color: BrandColors.forest, size: large ? 27 : 23),
    );
  }
}

class _ScienceTip extends StatelessWidget {
  const _ScienceTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.forest.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IconTile(icon: Icons.lightbulb_outline_rounded),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Sabías que?',
                  style: GoogleFonts.poppins(
                    color: BrandColors.forest,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Las plantas producen el oxígeno que respiramos mediante la fotosíntesis.',
                  style: GoogleFonts.poppins(
                    color: BrandColors.ink,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ARModeSelector extends StatelessWidget {
  const _ARModeSelector({required this.onSimple, required this.onImageTarget});

  final VoidCallback onSimple;
  final VoidCallback onImageTarget;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Realidad aumentada',
              style: GoogleFonts.poppins(
                color: BrandColors.forest,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Elige cómo quieres explorar las células',
              style: GoogleFonts.poppins(
                color: BrandColors.forestMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            _ModeOption(
              icon: Icons.qr_code_2_rounded,
              title: 'Marcadores de color',
              subtitle: 'Explora modelos con Unity y Vuforia',
              badge: 'Unity',
              onTap: onSimple,
            ),
            const SizedBox(height: 12),
            _ModeOption(
              icon: Icons.biotech_outlined,
              title: 'Imagen de célula',
              subtitle:
                  'Apunta a una imagen y descubre información superpuesta',
              badge: 'Nuevo',
              onTap: onImageTarget,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: BrandColors.forest.withValues(alpha: 0.1),
            ),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            children: [
              _IconTile(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              color: BrandColors.forest,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: BrandColors.amber.withValues(alpha: 0.21),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.poppins(
                              color: BrandColors.forest,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: BrandColors.forestMuted,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: BrandColors.forest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
