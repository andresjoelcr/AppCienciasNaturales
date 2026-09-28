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
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(imageFile, fit: BoxFit.cover),
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

                  // Lo escaneado no pertenece al temario
                  if (!result.esDelTema) ...[
                    _buildFueraDeTemaCard(),
                    _buildEscanearDeNuevo(context),
                  ] else ...[
                    if (result.confianzaBaja) _buildAvisoConfianzaBaja(),

                    // Descripcion
                    _buildInfoCard(
                      icon: Icons.description_rounded,
                      title: 'Descripcion',
                      content: result.descripcion,
                      color: AppColors.primaryGreen,
                    ),

                    const SizedBox(height: 16),

                    // Clasificacion
                    if (result.clasificacion.isNotEmpty) ...[
                      _buildInfoCard(
                        icon: Icons.account_tree_rounded,
                        title: 'Clasificacion cientifica',
                        content: result.clasificacion,
                        color: Colors.indigo.shade400,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Habitat
                    if (result.habitat.isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.location_on_rounded,
                        title: 'Habitat',
                        content: result.habitat,
                        color: AppColors.oceanBlue,
                      ),

                    if (result.habitat.isNotEmpty) const SizedBox(height: 16),

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
                    _buildEscanearDeNuevo(context),
                  ],

                  const SizedBox(height: 16),

                  // Origen de la identificacion
                  Center(
                    child: Text(
                      result.esDelTema
                          ? 'Deteccion con Groq Vision + ficha de Groq'
                          : 'Detectado con Groq Vision',
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

  Widget _buildEscanearDeNuevo(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.camera_alt_rounded),
        label: Text(
          'Escanear otra imagen',
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
    );
  }

  Widget _buildConfianzaCard() {
    final color =
        result.confianza >= 75
            ? AppColors.primaryGreen
            : result.confianza >= ScannerResult.umbralConfianzaBaja
            ? AppColors.sunOrange
            : Colors.red.shade600;

    final label =
        result.confianza >= 75
            ? 'Identificacion segura'
            : result.confianza >= ScannerResult.umbralConfianzaBaja
            ? 'Confianza media'
            : 'Identificacion dudosa';

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
          const SizedBox(height: 6),
          Text(
            'Estimacion de la IA sobre su propia certeza. No es una medida '
            'exacta: si el nombre o la descripcion te parecen raros, es probable '
            'que la foto no sea suficiente.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.greyText,
              height: 1.4,
            ),
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
      case 'fruta':
        return Colors.red.shade400;
      case 'verdura':
        return Colors.green.shade600;
      case 'flor':
        return Colors.pink.shade400;
      case 'mineral':
        return Colors.indigo.shade300;
      case 'roca':
        return Colors.blueGrey.shade400;
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
      case 'fruta':
        return Icons.apple_rounded;
      case 'verdura':
        return Icons.eco_outlined;
      case 'flor':
        return Icons.local_florist_rounded;
      case 'mineral':
        return Icons.diamond_rounded;
      case 'roca':
        return Icons.terrain_rounded;
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
      case 'fruta':
        return 'Fruta';
      case 'verdura':
        return 'Verdura';
      case 'flor':
        return 'Flor';
      case 'mineral':
        return 'Mineral';
      case 'roca':
        return 'Roca';
      case 'celula':
        return 'Celula';
      case 'microorganismo':
        return 'Microorganismo';
      case 'objeto':
        return 'Objeto';
      default:
        return 'Elemento';
    }
  }

  /// Panel que se muestra cuando lo escaneado no pertenece al temario.
  Widget _buildFueraDeTemaCard() {
    final motivo =
        result.motivo.isNotEmpty
            ? result.motivo
            : 'No corresponde a los temas de ciencias naturales que trabaja esta guia.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.sunOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sunOrange.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.sunOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: AppColors.sunOrange,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No es parte de nuestra guia',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 18,
                        color: AppColors.earthBrown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Escaneaste: ${result.nombreComun}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            motivo,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: AppColors.oceanBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Prueba con una foto de cerca de un animal, planta, hongo, '
                    'insecto, fruta, verdura, flor, roca o mineral. Puedes ver '
                    'de que trata la guia en la seccion Guia.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkText,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Aviso de deteccion dudosa: se muestra junto a la ficha, no la reemplaza.
  Widget _buildAvisoConfianzaBaja() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade600.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade600.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 22,
            color: Colors.red.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'La IA no esta segura de esta identificacion y podria equivocarse. '
              'Verifica que la foto sea nitida, que el elemento este centrado '
              'y que no haya otros objetos tapandolo.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
