import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/glosario_model.dart';

class TerminoDetalleScreen extends StatelessWidget {
  final TerminoGlosario termino;

  const TerminoDetalleScreen({super.key, required this.termino});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloudWhite,
      body: CustomScrollView(
        slivers: [
          // AppBar con gradiente
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      termino.categoria.color,
                      termino.categoria.color.withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // Imagen del termino
                      if (termino.imagenAsset != null)
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              termino.imagenAsset!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Icon(
                                    termino.categoria.icono,
                                    color: termino.categoria.color,
                                    size: 60,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            termino.categoria.icono,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titulo y categoria
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          termino.termino,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.darkText,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Badge de categoria
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: termino.categoria.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          termino.categoria.icono,
                          size: 16,
                          color: termino.categoria.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          termino.categoria.nombre,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: termino.categoria.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pronunciacion si existe
                  if (termino.pronunciacion != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.greyText,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/${termino.pronunciacion}/',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.greyText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Definicion
                  _buildSeccion(
                    icono: Icons.description_rounded,
                    titulo: 'Definicion',
                    color: AppColors.skyBlue,
                    child: Text(
                      termino.definicion,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.darkText,
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Dato curioso
                  if (termino.datoCurioso != null) ...[
                    const SizedBox(height: 20),
                    _buildSeccion(
                      icono: Icons.lightbulb_rounded,
                      titulo: 'Dato Curioso',
                      color: AppColors.sunOrange,
                      child: Text(
                        termino.datoCurioso!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkText,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion({
    required IconData icono,
    required String titulo,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                titulo,
                style: AppTextStyles.heading3.copyWith(
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
