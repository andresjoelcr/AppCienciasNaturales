import 'dart:typed_data';

import 'package:flutter/services.dart';

const _channel = MethodChannel('com.example.mi_app/marcador_download');

Future<void> save(Uint8List bytes, String fileName) async {
  await _channel.invokeMethod<void>('savePdf', {
    'bytes': bytes,
    'fileName': fileName,
  });
}
