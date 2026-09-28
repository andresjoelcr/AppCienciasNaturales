import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'guia/guia_home_screen.dart';
import 'scanner_screen.dart';
import 'ar_image_target_screen.dart';
import 'unity_escaneo_screen.dart';
import 'glosario/glosario_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    // Crear perfil del usuario si no existe
    _firestoreService.getOrCreateUserProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
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
                Icons.eco,
                color: AppColors.primaryGreen,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ciencias Naturales',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Explora el mundo natural',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_rounded, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              tooltip: 'Mi Perfil',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () async {
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              tooltip: 'Cerrar sesion',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de bienvenida
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.5, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                  ),
                ),
                child: FadeTransition(
                  opacity: _animationController,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                user?.photoURL != null
                                    ? NetworkImage(user!.photoURL!)
                                    : null,
                            child:
                                user?.photoURL == null
                                    ? const Icon(
                                      Icons.person,
                                      color: AppColors.primaryGreen,
                                      size: 28,
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Hola, ',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      user?.displayName?.split(' ').first ??
                                          'Estudiante',
                                      style: AppTextStyles.heading3.copyWith(
                                        color: AppColors.primaryGreen,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.waving_hand,
                                    color: AppColors.sunOrange,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Que quieres aprender hoy?',
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
                ),
              ),

              const SizedBox(height: 28),

              // Titulo de herramientas
              Text(
                'Herramientas de Aprendizaje',
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: 16),

              // Cards de herramientas
              _buildToolCard(
                index: 0,
                icon: Icons.menu_book_rounded,
                title: 'Guia Didactica Interactiva',
                description: 'Aprende con lecciones paso a paso',
                color: AppColors.skyBlue,
                isAvailable: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GuiaHomeScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildToolCard(
                index: 1,
                icon: Icons.smart_toy_rounded,
                title: 'Chatbot de Ciencias',
                description: 'Pregunta lo que quieras sobre ciencias',
                color: AppColors.leafGreen,
                isAvailable: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildToolCard(
                index: 2,
                icon: Icons.camera_alt_rounded,
                title: 'Escaner Inteligente',
                description: 'Identifica plantas y animales con IA',
                color: AppColors.sunOrange,
                isAvailable: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScannerScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildToolCard(
                index: 3,
                icon: Icons.view_in_ar_rounded,
                title: 'Realidad Aumentada',
                description: 'Superpone información 3D sobre células reales',
                color: Colors.purple,
                isAvailable: true,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder:
                        (_) => _ARModeSelector(
                          onSimple: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Unity embebido: arranca en la escena indice 0,
                                // que es EscanearTarjetas.
                                builder: (_) => const UnityEscaneoScreen(),
                              ),
                            );
                          },
                          onImageTarget: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ARImageTargetScreen(),
                              ),
                            );
                          },
                        ),
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildToolCard(
                index: 4,
                icon: Icons.menu_book_rounded,
                title: 'Diccionario',
                description: 'Busca y aprende terminos cientificos',
                color: Colors.teal,
                isAvailable: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GlosarioScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Tip del dia
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.skyBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.sunOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sabias que?',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.oceanBlue,
                              ),
                            ),
                            Text(
                              'Las plantas producen el oxigeno que respiramos mediante la fotosintesis.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (0.1 + index * 0.1).clamp(0.0, 0.6),
            (0.5 + index * 0.1).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 0.6),
            (0.4 + index * 0.1).clamp(0.0, 1.0),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize: 16,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                            if (!isAvailable) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.sunOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Pronto',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.sunOrange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isAvailable
                              ? color.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isAvailable ? color : Colors.grey,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet para seleccionar modo AR
// ---------------------------------------------------------------------------
class _ARModeSelector extends StatelessWidget {
  final VoidCallback onSimple;
  final VoidCallback onImageTarget;

  const _ARModeSelector({required this.onSimple, required this.onImageTarget});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Text(
            'Modo de Realidad Aumentada',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Elige cómo quieres explorar las células',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // Opción 1: marcadores de color
          _ModeOption(
            icon: Icons.qr_code_2,
            title: 'Marcadores de color',
            subtitle: 'Detecta marcadores impresos y abre videos educativos',
            color: Colors.orange,
            badge: 'Clásico',
            onTap: onSimple,
          ),

          const SizedBox(height: 12),

          // Opción 2: image target AR
          _ModeOption(
            icon: Icons.biotech,
            title: 'AR Image Target',
            subtitle:
                'Apunta a una imagen de célula y ve información superpuesta',
            color: Colors.purple,
            badge: 'Nuevo',
            onTap: onImageTarget,
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String badge;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
