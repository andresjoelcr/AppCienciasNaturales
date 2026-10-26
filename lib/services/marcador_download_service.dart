import 'package:flutter/services.dart';

import 'marcador_download_stub.dart'
    if (dart.library.html) 'marcador_download_web.dart' as platform;

/// Descarga un PDF incluido en los assets de la aplicación.
class MarcadorDownloadService {
  static Future<void> descargar(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await platform.save(bytes, assetPath.split('/').last);
  }
}
