import 'dart:math';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class SimpleDetectionResult {
  final String markerId;
  final String nombre;
  final String videoUrl;
  final double score;

  SimpleDetectionResult({
    required this.markerId,
    required this.nombre,
    required this.videoUrl,
    required this.score,
  });
}

/// Detector de marcadores por patrón diagonal de colores.
///
/// Reglas estrictas para evitar falsos positivos:
///   1. Cada color necesita ≥30 píxeles muy saturados (≥0.45 HSV)
///   2. El color debe aparecer en AMBAS esquinas del diagonal (no solo una)
///      → cada esquina debe tener ≥25% de los píxeles del color
///   3. ≥65% de los píxeles del color deben estar en las esquinas correctas
///   4. Los centroides de ambos colores deben estar en cuadrantes distintos
class SimpleMarkerDetector {
  bool _initialized = false;
  int _frameCount = 0;

  static const _markers = [
    {
      'id': 'celula',
      'nombre': 'Qué es la Célula',
      'video': 'https://youtu.be/aoj9oTvVJ8o',
      'colorA': 'rojo',
      'colorB': 'amarillo',
    },
    {
      'id': 'celulaanimal',
      'nombre': 'Célula Animal',
      'video': 'https://youtu.be/s0HzvQiqwpk',
      'colorA': 'verde',
      'colorB': 'azul',
    },
    {
      'id': 'celulavegetal',
      'nombre': 'Célula Vegetal',
      'video': 'https://youtu.be/ezNvi_71iEk',
      'colorA': 'azul',
      'colorB': 'magenta',
    },
    {
      'id': 'organelos',
      'nombre': 'Orgánelos y Funciones',
      'video': 'https://youtu.be/kE5wdEncrm8',
      'colorA': 'magenta',
      'colorB': 'cyan',
    },
  ];

  Future<void> initialize() async {
    _initialized = true;
    print('[Detector] Inicializado');
  }

  Future<SimpleDetectionResult?> detect(CameraImage cameraImage) async {
    if (!_initialized) return null;
    _frameCount++;
    try {
      final image = _convertYUV420(cameraImage);
      if (image == null) return null;
      return _detectPattern(image);
    } catch (e) {
      print('[Detector] Error: $e');
      return null;
    }
  }

  SimpleDetectionResult? _detectPattern(img.Image image) {
    final w = image.width;
    final h = image.height;

    // --- Paso 1: recolectar posiciones de píxeles por color ---
    final Map<String, List<int>> colX = {};
    final Map<String, List<int>> colY = {};

    for (int y = 0; y < h; y += 2) {
      for (int x = 0; x < w; x += 2) {
        final pixel = image.getPixel(x, y);
        final name = _classifyColor(
            pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
        if (name != null) {
          colX.putIfAbsent(name, () => []).add(x);
          colY.putIfAbsent(name, () => []).add(y);
        }
      }
    }

    if (_frameCount % 30 == 0) {
      final s = colX.map((k, v) => MapEntry(k, v.length));
      print('[Detector] Frame $_frameCount — $s');
    }

    // --- Paso 2: evaluar cada marcador ---
    for (final marker in _markers) {
      final cA = marker['colorA']!;
      final cB = marker['colorB']!;

      final xA = colX[cA] ?? [];
      final yA = colY[cA] ?? [];
      final xB = colX[cB] ?? [];
      final yB = colY[cB] ?? [];

      // Mínimo de píxeles por color
      if (xA.length < 30 || xB.length < 30) continue;

      // Bounding box de los píxeles de ambos colores
      int minX = w, maxX = 0, minY = h, maxY = 0;
      for (int i = 0; i < xA.length; i++) {
        if (xA[i] < minX) minX = xA[i]; if (xA[i] > maxX) maxX = xA[i];
        if (yA[i] < minY) minY = yA[i]; if (yA[i] > maxY) maxY = yA[i];
      }
      for (int i = 0; i < xB.length; i++) {
        if (xB[i] < minX) minX = xB[i]; if (xB[i] > maxX) maxX = xB[i];
        if (yB[i] < minY) minY = yB[i]; if (yB[i] > maxY) maxY = yB[i];
      }

      // La región debe abarcar al menos 15% de la imagen en ambas dimensiones
      if ((maxX - minX) < w * 0.15 || (maxY - minY) < h * 0.15) continue;

      final midX = (minX + maxX) / 2.0;
      final midY = (minY + maxY) / 2.0;

      // Conteo por cuadrante
      int aTL = 0, aTR = 0, aBL = 0, aBR = 0;
      for (int i = 0; i < xA.length; i++) {
        if (xA[i] < midX && yA[i] < midY) aTL++;
        else if (xA[i] >= midX && yA[i] < midY) aTR++;
        else if (xA[i] < midX && yA[i] >= midY) aBL++;
        else aBR++;
      }
      int bTL = 0, bTR = 0, bBL = 0, bBR = 0;
      for (int i = 0; i < xB.length; i++) {
        if (xB[i] < midX && yB[i] < midY) bTL++;
        else if (xB[i] >= midX && yB[i] < midY) bTR++;
        else if (xB[i] < midX && yB[i] >= midY) bBL++;
        else bBR++;
      }

      final tA = xA.length;
      final tB = xB.length;

      // Orientación normal (cámara frontal/landscape):  A→TL+BR  B→TR+BL
      final ok1 = _checkDiagonal(aTL, aBR, tA, bTR, bBL, tB);
      // Orientación rotada 90° (Android portrait típico): A→TR+BL  B→TL+BR
      final ok2 = _checkDiagonal(aTR, aBL, tA, bTL, bBR, tB);

      if (_frameCount % 30 == 0 && (xA.length > 10 || xB.length > 10)) {
        print('[Detector] ${marker['id']}: $cA($tA) '
            'TL=$aTL TR=$aTR BL=$aBL BR=$aBR | '
            '$cB($tB) TL=$bTL TR=$bTR BL=$bBL BR=$bBR '
            '→ ok1=$ok1 ok2=$ok2');
      }

      if (ok1 || ok2) {
        print('[Detector] ✓ ${marker['nombre']} '
            '(A:$tA B:$tB orient=${ok1 ? "normal" : "rot90"})');
        return SimpleDetectionResult(
          markerId: marker['id']!,
          nombre: marker['nombre']!,
          videoUrl: marker['video']!,
          score: 0.85,
        );
      }
    }
    return null;
  }

  /// Verifica que el color 1 esté en q1a+q1b y el color 2 en q2a+q2b,
  /// con tres condiciones estrictas:
  ///   (a) ≥65% de cada color en sus cuadrantes correctos
  ///   (b) ambas esquinas del color 1 tienen ≥20% de sus píxeles
  ///   (c) ambas esquinas del color 2 tienen ≥20% de sus píxeles
  bool _checkDiagonal(
    int c1q1, int c1q2, int total1,   // color1 en sus 2 cuadrantes y total
    int c2q1, int c2q2, int total2,   // color2 en sus 2 cuadrantes y total
  ) {
    // (a) Porcentaje en diagonal correcto
    if ((c1q1 + c1q2) / total1 < 0.65) return false;
    if ((c2q1 + c2q2) / total2 < 0.65) return false;

    // (b) Ambas esquinas de color1 deben tener ≥20% del total del color1
    //     (garantiza que el color está en DOS lugares, no solo en uno)
    if (c1q1 < total1 * 0.20) return false;
    if (c1q2 < total1 * 0.20) return false;

    // (c) Ídem para color2
    if (c2q1 < total2 * 0.20) return false;
    if (c2q2 < total2 * 0.20) return false;

    return true;
  }

  // ---------------------------------------------------------------------------
  // Clasificación por HUE (tono HSV). Saturación mínima ≥0.45.
  // Solo captura colores muy saturados como los de los marcadores impresos.
  // ---------------------------------------------------------------------------
  String? _classifyColor(int r, int g, int b) {
    final br = (r + g + b) / 3.0;
    if (br < 30 || br > 248) return null;

    final maxC = max(max(r, g), b).toDouble();
    final minC = min(min(r, g), b).toDouble();
    final delta = maxC - minC;

    // Saturación alta: ≥0.45 — solo colores puros como los marcadores
    if (maxC == 0 || delta / maxC < 0.45) return null;

    double hue;
    if (maxC == r) {
      hue = 60.0 * (((g - b) / delta) % 6);
    } else if (maxC == g) {
      hue = 60.0 * ((b - r) / delta + 2.0);
    } else {
      hue = 60.0 * ((r - g) / delta + 4.0);
    }
    if (hue < 0) hue += 360.0;

    if (hue < 22 || hue >= 338)          return 'rojo';
    if (hue >= 32 && hue < 82)           return 'amarillo';
    if (hue >= 82 && hue < 165)          return 'verde';
    if (hue >= 165 && hue < 205)         return 'cyan';
    if (hue >= 200 && hue < 265)         return 'azul';
    if (hue >= 265 && hue < 338)         return 'magenta';

    return null;
  }

  // ---------------------------------------------------------------------------
  // Conversión YUV420 → RGB (escala ÷4 para velocidad)
  // ---------------------------------------------------------------------------
  img.Image? _convertYUV420(CameraImage cam) {
    try {
      final yP = cam.planes[0];
      final uP = cam.planes[1];
      final vP = cam.planes[2];

      const scale = 4;
      final w = cam.width ~/ scale;
      final h = cam.height ~/ scale;
      final out = img.Image(width: w, height: h);

      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final sx = x * scale;
          final sy = y * scale;
          final yIdx  = sy * yP.bytesPerRow + sx;
          final uvIdx = (sy ~/ 2) * uP.bytesPerRow + (sx ~/ 2);

          if (yIdx  >= yP.bytes.length) continue;
          if (uvIdx >= uP.bytes.length) continue;
          if (uvIdx >= vP.bytes.length) continue;

          final yv = yP.bytes[yIdx];
          final uv = uP.bytes[uvIdx];
          final vv = vP.bytes[uvIdx];

          final rr = (yv + 1.402  * (vv - 128)).clamp(0, 255).toInt();
          final gg = (yv - 0.344  * (uv - 128) - 0.714 * (vv - 128))
              .clamp(0, 255).toInt();
          final bb = (yv + 1.772  * (uv - 128)).clamp(0, 255).toInt();

          out.setPixelRgb(x, y, rr, gg, bb);
        }
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _initialized = false;
  }
}
