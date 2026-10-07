import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/scanner_service.dart';
import 'scanner_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  bool _isLoading = false;
  File? _selectedImage;

  /// Aviso mostrado mientras la API espera por limite de peticiones.
  String? _esperando;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isLoading = true;
        });

        await _analizarImagen(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error al obtener la imagen: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _analizarImagen(File imageFile) async {
    try {
      final service = ScannerService();
      final result = await service.identificarImagen(
        imageFile,
        onEsperando: (mensaje) {
          if (mounted && _isLoading) {
            setState(() => _esperando = mensaje);
          }
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _esperando = null;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ScannerResultScreen(result: result, imageFile: imageFile),
          ),
        );
      }
    } on ScannerException catch (e) {
      if (mounted) _mostrarError(e.mensaje);
    } catch (e) {
      if (mounted) {
        _mostrarError('No se pudo analizar la imagen. Intenta de nuevo.');
      }
      debugPrint('[Scanner] Excepcion inesperada: $e');
    }
  }

  void _mostrarError(String mensaje) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloudWhite,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escáner',
              style: AppTextStyles.heading3.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Text(
              'Identifica seres vivos',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading ? _buildLoadingView() : _buildMainView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mostrar imagen seleccionada
          if (_selectedImage != null)
            Container(
              width: 200,
              height: 200,
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),

          // Indicador de carga
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analizando imagen...',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryGreen,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Identificando objeto...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyText),
            textAlign: TextAlign.center,
          ),

          // Aviso de espera cuando la API agota su limite de tokens por minuto.
          if (_esperando != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _esperando!,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.orange.shade900,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header ilustrativo
            FadeTransition(
              opacity: _animationController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.lightGreen,
                      AppColors.lightGreen.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: AppColors.primaryGreen,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Escaner Inteligente',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primaryGreen,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toma una foto o selecciona una imagen\npara identificar animales, plantas,\n'
                      'hongos y otros seres vivos',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkText,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Botón cámara
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
                ),
              ),
              child: _buildOptionCard(
                icon: Icons.camera_alt_rounded,
                title: 'Tomar Foto',
                description: 'Usa la camara para capturar una imagen',
                color: AppColors.primaryGreen,
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),

            const SizedBox(height: 16),

            // Botón galería
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
                ),
              ),
              child: _buildOptionCard(
                icon: Icons.photo_library_rounded,
                title: 'Subir Imagen',
                description: 'Selecciona una foto de tu galeria',
                color: AppColors.oceanBlue,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),

            const SizedBox(height: 28),

            // Tips
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sandBeige,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.sunOrange.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates_rounded,
                          color: AppColors.sunOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Consejos para mejores resultados',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.sunOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      'Asegurate de que la imagen sea clara y bien iluminada',
                    ),
                    _buildTip('Enfoca directamente al animal o planta'),
                    _buildTip('Evita fotos borrosas o con mucho fondo'),
                    _buildTip('Funciona mejor con una sola especie por foto'),
                    _buildTip(
                      'Solo detecta seres vivos y elementos naturales: el escaner '
                      'te avisara si la foto no pertenece a la guia',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 17,
                        color: AppColors.darkText,
                      ),
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
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.sunOrange.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.darkText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
