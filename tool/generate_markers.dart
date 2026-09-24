// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;

/// Configuracion de marcadores
class MarkerConfig {
  final String id;
  final String nombre;
  final int colorPrimarioR, colorPrimarioG, colorPrimarioB;
  final int colorSecundarioR, colorSecundarioG, colorSecundarioB;
  final int patronId;
  final String imagenOriginal;

  MarkerConfig({
    required this.id,
    required this.nombre,
    required this.colorPrimarioR,
    required this.colorPrimarioG,
    required this.colorPrimarioB,
    required this.colorSecundarioR,
    required this.colorSecundarioG,
    required this.colorSecundarioB,
    required this.patronId,
    required this.imagenOriginal,
  });
}

void main() async {
  final markers = [
    MarkerConfig(
      id: 'celula',
      nombre: 'La Celula',
      colorPrimarioR: 255, colorPrimarioG: 0, colorPrimarioB: 0, // Rojo
      colorSecundarioR: 255, colorSecundarioG: 255, colorSecundarioB: 0, // Amarillo
      patronId: 1,
      imagenOriginal: 'assets/celula/celula.png',
    ),
    MarkerConfig(
      id: 'celulaanimal',
      nombre: 'Celula Animal',
      colorPrimarioR: 0, colorPrimarioG: 255, colorPrimarioB: 0, // Verde
      colorSecundarioR: 0, colorSecundarioG: 0, colorSecundarioB: 255, // Azul
      patronId: 2,
      imagenOriginal: 'assets/celula/celulaanimal.jpg',
    ),
    MarkerConfig(
      id: 'celulavegetal',
      nombre: 'Celula Vegetal',
      colorPrimarioR: 0, colorPrimarioG: 0, colorPrimarioB: 255, // Azul
      colorSecundarioR: 255, colorSecundarioG: 0, colorSecundarioB: 255, // Magenta
      patronId: 3,
      imagenOriginal: 'assets/celula/celulavegetal.jpg',
    ),
    MarkerConfig(
      id: 'organelos',
      nombre: 'Organelos',
      colorPrimarioR: 255, colorPrimarioG: 0, colorPrimarioB: 255, // Magenta
      colorSecundarioR: 0, colorSecundarioG: 255, colorSecundarioB: 255, // Cyan
      patronId: 4,
      imagenOriginal: 'assets/celula/organelos.png',
    ),
  ];

  final outputDir = 'assets/marcadores';

  for (var marker in markers) {
    print('Generando marcador: ${marker.nombre}...');
    await generateMarker(marker, outputDir);
  }

  print('\nMarcadores generados exitosamente en: $outputDir');
}

Future<void> generateMarker(MarkerConfig config, String outputDir) async {
  // Dimensiones del marcador
  const int width = 800;
  const int height = 1000;
  const int barHeight = 80;
  const int cornerWidth = 120;
  const int borderWidth = 4;

  // Crear imagen
  final image = img.Image(width: width, height: height);

  // Fondo blanco
  img.fill(image, color: img.ColorRgb8(255, 255, 255));

  // Borde negro exterior
  _drawRect(image, 0, 0, width, height, 0, 0, 0, borderWidth);

  // === BARRA SUPERIOR ===
  // Esquina izquierda - Color primario
  _fillRect(image, borderWidth, borderWidth, cornerWidth, barHeight,
      config.colorPrimarioR, config.colorPrimarioG, config.colorPrimarioB);
  // Circulo blanco en esquina primaria superior
  _fillCircle(image, borderWidth + cornerWidth ~/ 2, borderWidth + barHeight ~/ 2, 20,
      255, 255, 255);

  // Esquina derecha - Color secundario
  _fillRect(image, width - cornerWidth - borderWidth, borderWidth, cornerWidth, barHeight,
      config.colorSecundarioR, config.colorSecundarioG, config.colorSecundarioB);
  // Cuadrado negro en esquina secundaria superior
  _fillRect(image, width - cornerWidth ~/ 2 - 20 - borderWidth, borderWidth + barHeight ~/ 2 - 20,
      40, 40, 0, 0, 0);

  // Patron de barras central superior
  _drawPatternBars(image, config.patronId, width ~/ 2, borderWidth + barHeight ~/ 2, true);

  // === BARRA INFERIOR ===
  final bottomY = height - barHeight - borderWidth;

  // Esquina izquierda - Color primario
  _fillRect(image, borderWidth, bottomY, cornerWidth, barHeight,
      config.colorPrimarioR, config.colorPrimarioG, config.colorPrimarioB);
  // Cuadrado blanco en esquina primaria inferior
  _fillRect(image, borderWidth + cornerWidth ~/ 2 - 20, bottomY + barHeight ~/ 2 - 20,
      40, 40, 255, 255, 255);

  // Esquina derecha - Color secundario
  _fillRect(image, width - cornerWidth - borderWidth, bottomY, cornerWidth, barHeight,
      config.colorSecundarioR, config.colorSecundarioG, config.colorSecundarioB);
  // Circulo negro en esquina secundaria inferior
  _fillCircle(image, width - cornerWidth ~/ 2 - borderWidth, bottomY + barHeight ~/ 2, 20,
      0, 0, 0);

  // Patron de barras central inferior
  _drawPatternBars(image, config.patronId, width ~/ 2, bottomY + barHeight ~/ 2, false);

  // === CARGAR IMAGEN ORIGINAL ===
  final originalPath = config.imagenOriginal;
  final originalFile = File(originalPath);

  if (await originalFile.exists()) {
    final originalBytes = await originalFile.readAsBytes();
    final originalImage = img.decodeImage(originalBytes);

    if (originalImage != null) {
      // Calcular area disponible para la imagen
      final imageAreaX = borderWidth + 20;
      final imageAreaY = borderWidth + barHeight + 20;
      final imageAreaWidth = width - 2 * (borderWidth + 20);
      final imageAreaHeight = height - 2 * (borderWidth + barHeight + 20) - 60; // Espacio para texto

      // Redimensionar manteniendo proporcion
      final scale = (imageAreaWidth / originalImage.width).clamp(0.0,
          imageAreaHeight / originalImage.height);
      final newWidth = (originalImage.width * scale).toInt();
      final newHeight = (originalImage.height * scale).toInt();

      final resized = img.copyResize(originalImage, width: newWidth, height: newHeight);

      // Centrar imagen
      final offsetX = imageAreaX + (imageAreaWidth - newWidth) ~/ 2;
      final offsetY = imageAreaY + (imageAreaHeight - newHeight) ~/ 2;

      // Copiar imagen
      img.compositeImage(image, resized, dstX: offsetX, dstY: offsetY);
    }
  } else {
    // Si no existe la imagen, mostrar texto placeholder
    print('  Imagen no encontrada: $originalPath');
  }

  // === TEXTO DEL NOMBRE ===
  // Dibujar rectangulo para el nombre
  final textY = height - borderWidth - barHeight - 50;
  _fillRect(image, width ~/ 4, textY, width ~/ 2, 40, 240, 240, 240);
  _drawRect(image, width ~/ 4, textY, width ~/ 2, 40, 0, 0, 0, 2);

  // Guardar imagen
  final outputPath = '$outputDir/marcador_${config.id}.png';
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(img.encodePng(image));
  print('  Guardado: $outputPath');
}

void _fillRect(img.Image image, int x, int y, int w, int h, int r, int g, int b) {
  for (int py = y; py < y + h && py < image.height; py++) {
    for (int px = x; px < x + w && px < image.width; px++) {
      if (px >= 0 && py >= 0) {
        image.setPixelRgb(px, py, r, g, b);
      }
    }
  }
}

void _drawRect(img.Image image, int x, int y, int w, int h, int r, int g, int b, int thickness) {
  // Top
  _fillRect(image, x, y, w, thickness, r, g, b);
  // Bottom
  _fillRect(image, x, y + h - thickness, w, thickness, r, g, b);
  // Left
  _fillRect(image, x, y, thickness, h, r, g, b);
  // Right
  _fillRect(image, x + w - thickness, y, thickness, h, r, g, b);
}

void _fillCircle(img.Image image, int cx, int cy, int radius, int r, int g, int b) {
  for (int py = cy - radius; py <= cy + radius; py++) {
    for (int px = cx - radius; px <= cx + radius; px++) {
      final dx = px - cx;
      final dy = py - cy;
      if (dx * dx + dy * dy <= radius * radius) {
        if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
          image.setPixelRgb(px, py, r, g, b);
        }
      }
    }
  }
}

void _drawPatternBars(img.Image image, int patronId, int centerX, int centerY, bool isTop) {
  final binary = patronId.toRadixString(2).padLeft(4, '0');
  const barWidth = 30;
  const barHeight = 50;
  const gap = 10;
  final totalWidth = 4 * barWidth + 3 * gap;
  var startX = centerX - totalWidth ~/ 2;

  for (int i = 0; i < 4; i++) {
    final isBlack = binary[i] == '1';
    final x = startX + i * (barWidth + gap);
    final y = centerY - barHeight ~/ 2;

    // Fondo de la barra
    _fillRect(image, x, y, barWidth, barHeight,
        isBlack ? 0 : 255, isBlack ? 0 : 255, isBlack ? 0 : 255);
    // Borde de la barra
    _drawRect(image, x, y, barWidth, barHeight, 0, 0, 0, 2);
  }
}
