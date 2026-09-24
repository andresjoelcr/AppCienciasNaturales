import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/simple_marker_detector.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Modelo de datos para cada tipo de célula detectable
// ---------------------------------------------------------------------------
class _CellData {
  final String markerId;
  final String name;
  final String type;
  final String imagePath;
  final String description;
  final List<String> organelles;
  final Color color;
  final String funFact;

  const _CellData({
    required this.markerId,
    required this.name,
    required this.type,
    required this.imagePath,
    required this.description,
    required this.organelles,
    required this.color,
    required this.funFact,
  });
}

const _cellDatabase = <String, _CellData>{
  'celula': _CellData(
    markerId: 'celula',
    name: 'La Célula',
    type: 'Unidad básica de la vida',
    imagePath: 'assets/celula/celula.png',
    description:
        'La célula es la unidad estructural y funcional de todos los seres vivos. '
        'Contiene la información genética necesaria para reproducirse y llevar '
        'a cabo todas las funciones vitales.',
    organelles: [
      'Membrana celular',
      'Núcleo',
      'Citoplasma',
      'Mitocondria',
      'Ribosomas',
    ],
    color: Color(0xFF4CAF50),
    funFact:
        'El cuerpo humano contiene aproximadamente 37 billones de células.',
  ),
  'celulaanimal': _CellData(
    markerId: 'celulaanimal',
    name: 'Célula Animal',
    type: 'Célula eucariota',
    imagePath: 'assets/celula/celulaanimal.jpg',
    description:
        'La célula animal es eucariota, carece de pared celular y cloroplastos. '
        'Posee centriolos para la división celular y vacuolas pequeñas.',
    organelles: [
      'Membrana plasmática',
      'Núcleo con nucléolo',
      'Mitocondrias',
      'Aparato de Golgi',
      'Centriolos',
      'Retículo endoplasmático',
    ],
    color: Color(0xFFE91E63),
    funFact:
        'Las células animales tienen una forma irregular y pueden cambiarla.',
  ),
  'celulavegetal': _CellData(
    markerId: 'celulavegetal',
    name: 'Célula Vegetal',
    type: 'Célula eucariota',
    imagePath: 'assets/celula/celulavegetal.jpg',
    description:
        'La célula vegetal tiene pared celular de celulosa, cloroplastos para '
        'la fotosíntesis y una vacuola central grande que regula la presión osmótica.',
    organelles: [
      'Pared celular',
      'Cloroplastos',
      'Vacuola central',
      'Membrana plasmática',
      'Núcleo',
      'Mitocondrias',
    ],
    color: Color(0xFF2196F3),
    funFact:
        'Los cloroplastos tienen su propio ADN, evidencia de su origen bacteriano.',
  ),
  'organelos': _CellData(
    markerId: 'organelos',
    name: 'Orgánelos Celulares',
    type: 'Estructuras especializadas',
    imagePath: 'assets/celula/organelos.png',
    description:
        'Los orgánelos son compartimentos membranosos que realizan funciones '
        'especializadas dentro de la célula, permitiendo la división del trabajo '
        'celular.',
    organelles: [
      'Mitocondria: energía (ATP)',
      'Ribosoma: síntesis de proteínas',
      'Golgi: empaque y transporte',
      'Lisosoma: digestión celular',
      'Retículo endoplasmático',
    ],
    color: Color(0xFF9C27B0),
    funFact:
        'Las mitocondrias tienen su propio ADN y se dividen de forma independiente.',
  ),
};

// ---------------------------------------------------------------------------
// Pantalla AR Image Target
// ---------------------------------------------------------------------------
class ARImageTargetScreen extends StatefulWidget {
  const ARImageTargetScreen({super.key});

  @override
  State<ARImageTargetScreen> createState() => _ARImageTargetScreenState();
}

class _ARImageTargetScreenState extends State<ARImageTargetScreen>
    with TickerProviderStateMixin {
  // Cámara
  CameraController? _camera;
  bool _cameraReady = false;

  // Detección de marcadores
  final SimpleMarkerDetector _detector = SimpleMarkerDetector();
  bool _detecting = true;
  bool _processing = false;
  int _confirmCount = 0;
  String _lastMarkerId = '';
  static const _requiredConfirms = 4;

  // Estado UI
  _CellData? _detectedCell;
  bool _showOverlay = false;
  String _statusText = 'Apunta la cámara a un marcador de célula';

  // Animaciones
  late AnimationController _scanController;
  late AnimationController _overlayController;
  late AnimationController _pulseController;
  late Animation<double> _scanAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initCamera();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _overlayController.dispose();
    _pulseController.dispose();
    _camera?.dispose();
    _detector.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Animaciones
  // -------------------------------------------------------------------------
  void _initAnimations() {
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  // -------------------------------------------------------------------------
  // Inicialización de cámara
  // -------------------------------------------------------------------------
  Future<void> _initCamera() async {
    await _detector.initialize();
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _statusText = 'No hay cámara disponible');
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
      setState(() => _cameraReady = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted && _detecting) {
        _camera!.startImageStream(_onFrame);
      }
    } catch (e) {
      setState(() => _statusText = 'Error de cámara: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Detección frame a frame
  // -------------------------------------------------------------------------
  Future<void> _onFrame(CameraImage image) async {
    if (!_detecting || _processing) return;
    _processing = true;

    try {
      final result = await _detector.detect(image);
      if (!mounted || !_detecting) {
        _processing = false;
        return;
      }

      if (result != null) {
        if (result.markerId == _lastMarkerId) {
          _confirmCount++;
        } else {
          _lastMarkerId = result.markerId;
          _confirmCount = 1;
        }

        final cell = _cellDatabase[result.markerId];
        if (cell != null) {
          setState(() {
            _statusText =
                'Detectando: ${cell.name} ($_confirmCount/$_requiredConfirms)';
          });
          if (_confirmCount >= _requiredConfirms) {
            _onCellConfirmed(cell);
          }
        }
      } else {
        if (_confirmCount > 0) _confirmCount--;
        if (_confirmCount == 0 && _lastMarkerId.isNotEmpty) {
          _lastMarkerId = '';
          setState(
            () => _statusText = 'Apunta la cámara a un marcador de célula',
          );
        }
      }
    } catch (_) {}

    _processing = false;
  }

  // -------------------------------------------------------------------------
  // Célula confirmada → mostrar overlay AR
  // -------------------------------------------------------------------------
  void _onCellConfirmed(_CellData cell) {
    _detecting = false;
    try {
      _camera?.stopImageStream();
    } catch (_) {}

    setState(() {
      _detectedCell = cell;
      _showOverlay = true;
      _statusText = cell.name;
    });

    _scanController.stop();
    _overlayController.forward();
  }

  // -------------------------------------------------------------------------
  // Reiniciar escaneo
  // -------------------------------------------------------------------------
  void _resetScan() {
    _overlayController.reverse();
    setState(() {
      _detectedCell = null;
      _showOverlay = false;
      _confirmCount = 0;
      _lastMarkerId = '';
      _detecting = true;
      _statusText = 'Apunta la cámara a un marcador de célula';
    });
    _scanController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _detecting && _camera != null) {
        try {
          _camera!.startImageStream(_onFrame);
        } catch (_) {}
      }
    });
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 1. Preview de cámara (fondo completo) ────────────────────
          _buildCameraPreview(),

          // ── 2. Marco de escaneo animado ───────────────────────────────
          if (!_showOverlay) _buildScanFrame(),

          // ── 3. Header ─────────────────────────────────────────────────
          _buildHeader(),

          // ── 4. Barra de estado inferior ───────────────────────────────
          if (!_showOverlay) _buildStatusBar(),

          // ── 5. Panel informativo superpuesto (overlay AR) ─────────────
          if (_showOverlay && _detectedCell != null)
            _buildCellOverlay(_detectedCell!),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Widgets de UI
  // -------------------------------------------------------------------------

  Widget _buildCameraPreview() {
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

  Widget _buildScanFrame() {
    return Center(
      child: AnimatedBuilder(
        animation: _scanAnim,
        builder: (_, __) => Transform.scale(
          scale: _scanAnim.value,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.85),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                ..._buildCorners(),
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Opacity(
                      opacity: _pulseAnim.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.biotech,
                            color: AppColors.primaryGreen,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ESCANEANDO',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const s = 22.0;
    const t = 3.0;
    final c = AppColors.primaryGreen;
    return [
      Positioned(top: 0, left: 0,
          child: _Corner(size: s, thick: t, color: c, top: true, left: true)),
      Positioned(top: 0, right: 0,
          child: _Corner(size: s, thick: t, color: c, top: true, left: false)),
      Positioned(bottom: 0, left: 0,
          child: _Corner(size: s, thick: t, color: c, top: false, left: true)),
      Positioned(bottom: 0, right: 0,
          child: _Corner(size: s, thick: t, color: c, top: false, left: false)),
    ];
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12, right: 16, bottom: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.75), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AR Células',
                  style: TextStyle(
                    color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Image Target',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 11,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _showOverlay ? AppColors.primaryGreen : Colors.black54,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showOverlay
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: Colors.white, size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _showOverlay ? 'DETECTADO' : 'BUSCANDO',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.bold, letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final progress =
        _confirmCount > 0 ? _confirmCount / _requiredConfirms : 0.0;

    return Positioned(
      bottom: 40, left: 24, right: 24,
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _statusText,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          if (_confirmCount > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _detectedCell?.color ?? AppColors.primaryGreen,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.white54, size: 14),
              const SizedBox(width: 6),
              const Text(
                'Usa los marcadores de la guía didáctica',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Panel de información superpuesto sobre la cámara (el efecto AR)
  Widget _buildCellOverlay(_CellData cell) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: cell.color.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Imagen + título ───────────────────────────────
                    Row(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cell.color.withOpacity(0.4), width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              cell.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: cell.color.withOpacity(0.1),
                                child: Icon(Icons.biotech,
                                    color: cell.color, size: 36),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cell.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  cell.type,
                                  style: TextStyle(
                                    color: cell.color, fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cell.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // ── Descripción ───────────────────────────────────
                    Text(
                      cell.description,
                      style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade700, height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Orgánulos ──────────────────────────────────────
                    Row(
                      children: [
                        Icon(Icons.circle, color: cell.color, size: 10),
                        const SizedBox(width: 8),
                        Text(
                          'Orgánulos principales',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold,
                            color: cell.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: cell.organelles
                          .map((o) => _OrganelleChip(
                                label: o, color: cell.color))
                          .toList(),
                    ),

                    const SizedBox(height: 16),

                    // ── Dato curioso ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cell.color.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: cell.color.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cell.funFact,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Botón escanear otro ───────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _resetScan,
                        icon: const Icon(Icons.qr_code_scanner, size: 20),
                        label: const Text('Escanear otro marcador'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cell.color,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chip de orgánulo
// ---------------------------------------------------------------------------
class _OrganelleChip extends StatelessWidget {
  final String label;
  final Color color;
  const _OrganelleChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withOpacity(0.85),
          fontSize: 11, fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Esquinas decorativas del marco de escaneo
// ---------------------------------------------------------------------------
class _Corner extends StatelessWidget {
  final double size;
  final double thick;
  final Color color;
  final bool top;
  final bool left;

  const _Corner({
    required this.size, required this.thick,
    required this.color, required this.top, required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _CornerPainter(
            color: color, thick: thick, top: top, left: left),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thick;
  final bool top;
  final bool left;

  _CornerPainter(
      {required this.color, required this.thick,
       required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    if (top && left) {
      canvas.drawLine(Offset(0, h), Offset(0, 0), p);
      canvas.drawLine(Offset(0, 0), Offset(w, 0), p);
    } else if (top && !left) {
      canvas.drawLine(Offset(0, 0), Offset(w, 0), p);
      canvas.drawLine(Offset(w, 0), Offset(w, h), p);
    } else if (!top && left) {
      canvas.drawLine(Offset(0, 0), Offset(0, h), p);
      canvas.drawLine(Offset(0, h), Offset(w, h), p);
    } else {
      canvas.drawLine(Offset(w, 0), Offset(w, h), p);
      canvas.drawLine(Offset(0, h), Offset(w, h), p);
    }
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
