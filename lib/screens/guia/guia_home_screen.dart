import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/brand_colors.dart';
import '../../data/celula_data.dart';
import '../../models/subtema_model.dart';
import '../../models/user_progress_model.dart';
import '../../services/firestore_service.dart';
import 'subtema_screen.dart';

class GuiaHomeScreen extends StatefulWidget {
  final String? initialSubtemaId;

  const GuiaHomeScreen({super.key, this.initialSubtemaId});

  @override
  State<GuiaHomeScreen> createState() => _GuiaHomeScreenState();
}

class _GuiaHomeScreenState extends State<GuiaHomeScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();

  late AnimationController _animationController;

  final Map<String, UserProgress> _progressPorSubtema = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
    _cargarProgreso();

    if (widget.initialSubtemaId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _abrirSubtemaInicial();
      });
    }
  }

  Future<void> _abrirSubtemaInicial() async {
    final subtema = CelulaData.getSubtemaById(widget.initialSubtemaId!);
    if (subtema == null || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubtemaScreen(subtema: subtema)),
    );
    if (mounted) await _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    final progress = await _firestoreService.getAllProgress();
    if (!mounted) return;
    setState(() {
      _progressPorSubtema
        ..clear()
        ..addEntries(progress.map((p) => MapEntry(p.subtemaId, p)));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloudWhite,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guía interactiva',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'La célula · Unidad básica de la vida',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header informativo
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
                      ),
                    ),
                child: FadeTransition(
                  opacity: _animationController,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.skyBlue.withOpacity(0.2),
                          AppColors.lightBlue,
                        ],
                      ),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.skyBlue.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.science_rounded,
                            color: AppColors.oceanBlue,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unidad 1',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.oceanBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'La célula',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.oceanBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${subtemascelula.length} subtemas con quiz interactivo',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.greyText,
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

              const SizedBox(height: 24),

              // Titulo de contenidos
              Text('Contenidos', style: AppTextStyles.heading2),

              const SizedBox(height: 16),

              // Lista de subtemas
              ...List.generate(subtemascelula.length, (index) {
                final subtema = subtemascelula[index];
                return _buildSubtemaCard(index: index, subtema: subtema);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtemaCard({required int index, required Subtema subtema}) {
    final colors = [
      AppColors.primaryGreen,
      AppColors.skyBlue,
      AppColors.primaryGreen,
      AppColors.oceanBlue,
    ];

    final icons = [
      Icons.biotech_rounded,
      Icons.compare_rounded,
      Icons.hub_rounded,
      Icons.auto_awesome_rounded,
    ];

    final color = colors[index % colors.length];
    final icon = icons[index % icons.length];

    final progress = _progressPorSubtema[subtema.id];
    final completado = progress?.completado ?? false;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.2 + (index * 0.1),
                0.6 + (index * 0.1),
                curve: Curves.easeOut,
              ),
            ),
          ),
      child: FadeTransition(
        opacity: _animationController,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubtemaScreen(subtema: subtema),
                  ),
                );
                if (mounted) await _cargarProgreso();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: completado
                        ? AppColors.primaryGreen.withOpacity(0.45)
                        : color.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Etiqueta de estado / nota mas alta (esquina superior derecha)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: completado
                              ? AppColors.sunYellow
                              : BrandColors.amber.withValues(alpha: 0.25),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              completado
                                  ? Icons.star_rounded
                                  : Icons.schedule_rounded,
                              size: 13,
                              color: completado
                                  ? AppColors.sunOrange
                                  : BrandColors.amberDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              completado
                                  ? 'Nota más alta: ${progress?.quizScore ?? 0}%'
                                  : 'Pendiente',
                              style: AppTextStyles.caption.copyWith(
                                color: completado
                                    ? AppColors.sunOrange
                                    : BrandColors.amberDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Numero del subtema
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(icon, color: color, size: 24),
                                const SizedBox(height: 2),
                                Text(
                                  subtema.numero,
                                  style: AppTextStyles.caption.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Contenido
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  subtema.titulo,
                                  style: AppTextStyles.heading3.copyWith(
                                    fontSize: 16,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtema.descripcion,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.greyText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.leafGreen.withOpacity(
                                          0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.quiz_rounded,
                                            size: 14,
                                            color: AppColors.leafGreen,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${subtema.quiz.preguntas.length} preguntas',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color: AppColors.leafGreen,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (completado)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen
                                              .withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              size: 14,
                                              color: AppColors.primaryGreen,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Completado',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color:
                                                        AppColors.primaryGreen,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Indicador de estado / flecha
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: completado
                                  ? AppColors.primaryGreen
                                  : color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              completado
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              color: completado ? Colors.white : color,
                              size: 16,
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
        ),
      ),
    );
  }
}
