import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../theme/app_theme.dart';
import '../services/simple_marker_detector.dart';

/// Pantalla AR simplificada con detección directa
class ARScreenSimple extends StatefulWidget {
  const ARScreenSimple({super.key});

  @override
  State<ARScreenSimple> createState() => _ARScreenSimpleState();
}

class _ARScreenSimpleState extends State<ARScreenSimple> {
  CameraController? _camera;
  YoutubePlayerController? _youtube;
  final SimpleMarkerDetector _detector = SimpleMarkerDetector();

  bool _cameraReady = false;
  bool _scanning = true;
  bool _processing = false;

  String _status = 'Iniciando...';
  String _detectedName = '';
  int _confirmCount = 0;
  String _lastMarkerId = '';

  // 4 confirmaciones — más ágil sin sacrificar estabilidad
  static const _requiredConfirms = 4;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _camera?.dispose();
    _youtube?.dispose();
    _detector.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _detector.initialize();

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _status = 'No hay cámara disponible');
      return;
    }

    _camera = CameraController(
      cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      ),
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _camera!.initialize();
      setState(() {
        _cameraReady = true;
        _status = 'Apunta la cámara a un marcador';
      });

      // Esperar un momento antes de iniciar detección
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted && _scanning) {
        _camera!.startImageStream(_onFrame);
      }
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (!_scanning || _processing) return;
    _processing = true;

    try {
      final result = await _detector.detect(image);

      if (!mounted || !_scanning) {
        _processing = false;
        return;
      }

      if (result != null) {
        // Detección válida
        if (result.markerId == _lastMarkerId) {
          _confirmCount++;
        } else {
          // Marcador diferente - no reiniciar completamente, solo reducir
          if (_confirmCount > 2) {
            _confirmCount -= 2;
          } else {
            _lastMarkerId = result.markerId;
            _confirmCount = 1;
          }
        }

        // Actualizar nombre si es el marcador actual
        if (result.markerId == _lastMarkerId) {
          print('[AR] Confirma $_confirmCount/$_requiredConfirms para ${result.nombre}');

          setState(() {
            _detectedName = result.nombre;
            _status = 'Detectando: ${result.nombre} ($_confirmCount/$_requiredConfirms)';
          });

          // ¿Suficientes confirmaciones?
          if (_confirmCount >= _requiredConfirms) {
            print('[AR] >>> ABRIENDO VIDEO: ${result.nombre}');
            _openVideo(result);
          }
        }
      } else {
        // Sin detección, reducir contador gradualmente
        if (_confirmCount > 0) {
          _confirmCount--;
        }
        if (_confirmCount == 0 && _lastMarkerId.isNotEmpty) {
          _lastMarkerId = '';
          setState(() {
            _detectedName = '';
            _status = 'Apunta la cámara a un marcador';
          });
        }
      }
    } catch (e) {
      print('[AR] Error frame: $e');
    }

    _processing = false;
  }

  void _openVideo(SimpleDetectionResult result) {
    // Detener cámara
    try {
      _camera?.stopImageStream();
    } catch (_) {}

    final videoId = YoutubePlayer.convertUrlToId(result.videoUrl);
    if (videoId == null) {
      print('[AR] Error: No se pudo obtener videoId de ${result.videoUrl}');
      return;
    }

    _youtube = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    setState(() {
      _scanning = false;
      _status = 'Reproduciendo: ${result.nombre}';
    });
  }

  void _closeVideo() {
    _youtube?.pause();
    _youtube?.dispose();
    _youtube = null;

    setState(() {
      _scanning = true;
      _confirmCount = 0;
      _lastMarkerId = '';
      _detectedName = '';
      _status = 'Apunta la cámara a un marcador';
    });

    // Reiniciar stream
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _scanning && _camera != null) {
        try {
          _camera!.startImageStream(_onFrame);
        } catch (e) {
          print('[AR] Error reiniciando stream: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Cámara o Video
          if (_scanning)
            _buildCamera()
          else
            _buildVideo(),

          // Header
          _buildHeader(),

          // Status
          if (_scanning) _buildStatus(),

          // Progress
          if (_scanning && _confirmCount > 0) _buildProgress(),
        ],
      ),
    );
  }

  Widget _buildCamera() {
    if (!_cameraReady || _camera == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _camera!.value.previewSize?.height ?? 1,
          height: _camera!.value.previewSize?.width ?? 1,
          child: CameraPreview(_camera!),
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_youtube == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 80),

          // Info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _detectedName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Player
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: YoutubePlayer(
                  controller: _youtube!,
                  showVideoProgressIndicator: true,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Botón cerrar
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton.icon(
              onPressed: _closeVideo,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear otro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Realidad Aumentada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _confirmCount > 0 ? AppColors.primaryGreen : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.view_in_ar, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 70,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _confirmCount > 0
              ? AppColors.primaryGreen.withOpacity(0.9)
              : Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _status,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildProgress() {
    final progress = _confirmCount / _requiredConfirms;

    return Positioned(
      bottom: 100,
      left: 50,
      right: 50,
      child: Column(
        children: [
          Text(
            _detectedName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            minHeight: 8,
          ),
          const SizedBox(height: 5),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
