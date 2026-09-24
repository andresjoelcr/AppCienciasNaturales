import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/scanner_service.dart';

class ScannerResultScreen extends StatelessWidget {
  final ScannerResult result;
  final File imageFile;

  const ScannerResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  // Nombre sobre la imagen
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge tipo
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(result.tipo),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTypeIcon(result.tipo),
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getTypeLabel(result.tipo),
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.nombreComun,
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 28,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        if (result.nombreCientifico.isNotEmpty)
                          Text(
                            result.nombreCientifico,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de confianza
                  _buildConfianzaCard(),

                  const SizedBox(height: 20),

                  // Descripcion
                  _buildInfoCard(
                    icon: Icons.description_rounded,
                    title: 'Descripcion',
                    content: result.descripcion,
                    color: AppColors.primaryGreen,
                  ),

                  const SizedBox(height: 16),

                  // Habitat
                  if (result.habitat.isNotEmpty &&
                      result.habitat != 'No disponible')
                    _buildInfoCard(
                      icon: Icons.location_on_rounded,
                      title: 'Habitat',
                      content: result.habitat,
                      color: AppColors.oceanBlue,
                    ),

                  if (result.habitat.isNotEmpty &&
                      result.habitat != 'No disponible')
                    const SizedBox(height: 16),

                  // Dato curioso
                  if (result.datoCurioso.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.sunOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lightbulb_rounded,
                              color: AppColors.sunOrange,
                              size: 22,
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
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.sunOrange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  result.datoCurioso,
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
                    ),

                  const SizedBox(height: 24),

                  // Botón escanear de nuevo
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(
                        'Escanear otra imagen',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
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

                  const SizedBox(height: 16),

                  // Powered by
                  Center(
                    child: Text(
                      'Identificado con IA',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.greyText.withOpacity(0.6),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfianzaCard() {
    final color = result.confianza >= 75
        ? AppColors.primaryGreen
        : result.confianza >= 50
            ? AppColors.sunOrange
            : Colors.red.shade600;

    final label = result.confianza >= 75
        ? 'Alta confianza'
        : result.confianza >= 50
            ? 'Confianza media'
            : 'Baja confianza';

    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_rounded, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              Text(
                '${result.confianza}%',
                style: AppTextStyles.heading3.copyWith(
                  color: color,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: result.confianza / 100,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String tipo) {
    switch (tipo) {
      case 'animal':
        return AppColors.sunOrange;
      case 'planta':
        return AppColors.primaryGreen;
      case 'insecto':
        return AppColors.earthBrown;
      case 'hongo':
        return Colors.purple.shade400;
      case 'celula':
        return AppColors.oceanBlue;
      case 'microorganismo':
        return Colors.teal.shade400;
      case 'objeto':
        return AppColors.skyBlue;
      default:
        return AppColors.greyText;
    }
  }

  IconData _getTypeIcon(String tipo) {
    switch (tipo) {
      case 'animal':
        return Icons.pets_rounded;
      case 'planta':
        return Icons.eco_rounded;
      case 'insecto':
        return Icons.bug_report_rounded;
      case 'hongo':
        return Icons.forest_rounded;
      case 'celula':
        return Icons.blur_circular_rounded;
      case 'microorganismo':
        return Icons.coronavirus_rounded;
      case 'objeto':
        return Icons.category_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getTypeLabel(String tipo) {
    switch (tipo) {
      case 'animal':
        return 'Animal';
      case 'planta':
        return 'Planta';
      case 'insecto':
        return 'Insecto';
      case 'hongo':
        return 'Hongo';
      case 'celula':
        return 'Celula';
      case 'microorganismo':
        return 'Microorganismo';
      case 'objeto':
        return 'Objeto';
      default:
        return 'No identificado';
    }
  }
}
