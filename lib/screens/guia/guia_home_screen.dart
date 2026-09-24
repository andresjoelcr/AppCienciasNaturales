import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/celula_data.dart';
import '../../models/subtema_model.dart';
import 'subtema_screen.dart';

class GuiaHomeScreen extends StatefulWidget {
  const GuiaHomeScreen({super.key});

  @override
  State<GuiaHomeScreen> createState() => _GuiaHomeScreenState();
}

class _GuiaHomeScreenState extends State<GuiaHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
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
                    'Guia Interactiva',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'La Celula - Unidad Basica de la Vida',
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
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
                )),
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
                                'La Celula',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.oceanBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '4 subtemas con quiz interactivo',
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
              Text(
                'Contenidos',
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: 16),

              // Lista de subtemas
              ...List.generate(subtemascelula.length, (index) {
                final subtema = subtemascelula[index];
                return _buildSubtemaCard(
                  index: index,
                  subtema: subtema,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtemaCard({
    required int index,
    required Subtema subtema,
  }) {
    final colors = [
      AppColors.primaryGreen,
      AppColors.skyBlue,
      AppColors.sunOrange,
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

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.5, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.2 + (index * 0.1),
          0.6 + (index * 0.1),
          curve: Curves.easeOut,
        ),
      )),
      child: FadeTransition(
        opacity: _animationController,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubtemaScreen(subtema: subtema),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
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
                          Icon(
                            icon,
                            color: color,
                            size: 24,
                          ),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.leafGreen.withOpacity(0.15),
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
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.leafGreen,
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
                    // Flecha
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: color,
                        size: 16,
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
