// Script para mejorar los marcadores con esquinas de colores más grandes
// Ejecutar con: dart run bin/improve_markers.dart

import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  print('=== Mejorando marcadores con esquinas de colores grandes ===\n');

  final markers = [
    {
      'file': 'assets/marcadores/marcador_celula.png',
      'colors': {
        'topLeft': [255, 0, 0],      // Rojo
        'topRight': [255, 255, 0],   // Amarillo
        'bottomLeft': [255, 255, 0], // Amarillo
        'bottomRight': [255, 0, 0],  // Rojo
      },
    },
    {
      'file': 'assets/marcadores/marcador_celulaanimal.png',
      'colors': {
        'topLeft': [0, 255, 0],      // Verde
        'topRight': [0, 0, 255],     // Azul
        'bottomLeft': [0, 0, 255],   // Azul
        'bottomRight': [0, 255, 0],  // Verde
      },
    },
    {
      'file': 'assets/marcadores/marcador_celulavegetal.png',
      'colors': {
        'topLeft': [0, 0, 255],      // Azul
        'topRight': [255, 0, 255],   // Magenta
        'bottomLeft': [255, 0, 255], // Magenta
        'bottomRight': [0, 0, 255],  // Azul
      },
    },
    {
      'file': 'assets/marcadores/marcador_organelos.png',
      'colors': {
        'topLeft': [255, 0, 255],    // Magenta
        'topRight': [0, 255, 255],   // Cyan
        'bottomLeft': [0, 255, 255], // Cyan
        'bottomRight': [255, 0, 255],// Magenta
      },
    },
  ];

  for (final marker in markers) {
    final filePath = marker['file'] as String;
    final colors = marker['colors'] as Map<String, List<int>>;

    print('Procesando: $filePath');

    final file = File(filePath);
    if (!file.existsSync()) {
      print('  ERROR: Archivo no encontrado');
      continue;
    }

    // Hacer backup
    final backupPath = filePath.replaceAll('.png', '_backup.png');
    if (!File(backupPath).existsSync()) {
      file.copySync(backupPath);
      print('  Backup creado: $backupPath');
    }

    // Cargar imagen
    final bytes = file.readAsBytesSync();
    final image = img.decodePng(bytes);
    if (image == null) {
      print('  ERROR: No se pudo decodificar la imagen');
      continue;
    }

    final w = image.width;
    final h = image.height;

    // Tamaño de esquina: 22% del lado menor
    final cornerSize = (w < h ? w : h) * 0.22;
    final cs = cornerSize.toInt();

    print('  Dimensiones: ${w}x$h, esquinas: ${cs}px');

    // Dibujar esquinas de colores sólidos
    _drawCorner(image, 0, 0, cs, colors['topLeft']!);
    _drawCorner(image, w - cs, 0, cs, colors['topRight']!);
    _drawCorner(image, 0, h - cs, cs, colors['bottomLeft']!);
    _drawCorner(image, w - cs, h - cs, cs, colors['bottomRight']!);

    // Guardar imagen
    final output = img.encodePng(image);
    file.writeAsBytesSync(output);
    print('  LISTO: Marcador actualizado\n');
  }

  print('=== Proceso completado ===');
  print('Ahora puedes probar la app con los marcadores mejorados.');
}

void _drawCorner(img.Image image, int startX, int startY, int size, List<int> rgb) {
  final color = img.ColorRgb8(rgb[0], rgb[1], rgb[2]);

  for (int y = startY; y < startY + size && y < image.height; y++) {
    for (int x = startX; x < startX + size && x < image.width; x++) {
      image.setPixel(x, y, color);
    }
  }
}
