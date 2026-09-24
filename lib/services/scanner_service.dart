import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../config/app_config.dart';

class ScannerResult {
  final String nombreComun;
  final String nombreCientifico;
  final String descripcion;
  final String habitat;
  final String datoCurioso;
  final int confianza;
  final String tipo;

  ScannerResult({
    required this.nombreComun,
    required this.nombreCientifico,
    required this.descripcion,
    required this.habitat,
    required this.datoCurioso,
    required this.confianza,
    required this.tipo,
  });

  factory ScannerResult.error() {
    return ScannerResult(
      nombreComun: 'No identificado',
      nombreCientifico: '',
      descripcion:
          'No se pudo identificar el contenido de la imagen. Intenta con una foto mas clara.',
      habitat: '',
      datoCurioso: '',
      confianza: 0,
      tipo: 'desconocido',
    );
  }
}

class ScannerService {
  final String _geminiApiKey;
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  final String _groqApiKey = AppConfig.groqApiKey;

  ScannerService(this._geminiApiKey);

  Future<void> _initTFLite() async {
    if (_isInitialized) return;

    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/mobilenet_v2.tflite',
      );
      final labelsData = await rootBundle.loadString(
        'assets/models/labels.txt',
      );
      _labels =
          labelsData.split('\n').where((l) => l.trim().isNotEmpty).toList();
      _isInitialized = true;
    } catch (e) {}
  }

  Future<ScannerResult> identificarImagen(File imageFile) async {
    // PASO 1: Intentar con Gemini Vision (mas preciso)
    try {
      final geminiResult = await _identificarConGemini(imageFile);
      if (geminiResult != null) {
        return ScannerResult(
          nombreComun: geminiResult['nombre'] ?? 'Objeto',
          nombreCientifico: geminiResult['cientifico'] ?? '',
          descripcion: geminiResult['descripcion'] ?? '',
          habitat: geminiResult['habitat'] ?? '',
          datoCurioso: geminiResult['dato'] ?? '',
          confianza: geminiResult['confianza'] ?? 85,
          tipo: geminiResult['tipo'] ?? 'objeto',
        );
      }
    } catch (e) {}

    // PASO 2: Fallback a TFLite
    await _initTFLite();

    String objetoIdentificado = '';
    double confianza = 0.0;
    String tipo = 'objeto';

    if (_interpreter != null) {
      try {
        final result = await _classifyWithTFLite(imageFile);
        if (result != null && result['confidence'] > 0.1) {
          objetoIdentificado = result['label'] as String;
          confianza = result['confidence'] as double;
          tipo = _detectTipo(objetoIdentificado);
        }
      } catch (e) {}
    }

    // PASO 3: Generar descripcion con Groq
    if (objetoIdentificado.isNotEmpty) {
      final nombreEs = _traducirAlEspanol(objetoIdentificado);

      try {
        final descripcion = await _generarDescripcionConGroq(nombreEs, tipo);
        if (descripcion != null) {
          return ScannerResult(
            nombreComun: descripcion['nombre'] ?? nombreEs,
            nombreCientifico: descripcion['cientifico'] ?? '',
            descripcion:
                descripcion['descripcion'] ?? 'Objeto identificado: $nombreEs',
            habitat: descripcion['habitat'] ?? '',
            datoCurioso: descripcion['dato'] ?? '',
            confianza: (confianza * 100).round().clamp(0, 100),
            tipo: tipo,
          );
        }
      } catch (e) {}

      return ScannerResult(
        nombreComun: nombreEs,
        nombreCientifico: '',
        descripcion: _getDescripcionBasica(nombreEs, tipo),
        habitat: '',
        datoCurioso: '',
        confianza: (confianza * 100).round().clamp(0, 100),
        tipo: tipo,
      );
    }

    return ScannerResult.error();
  }

  /// Identificar usando Gemini Vision API
  Future<Map<String, dynamic>?> _identificarConGemini(File imageFile) async {
    if (_geminiApiKey.isEmpty || _geminiApiKey == 'TU_API_KEY_DE_GEMINI_AQUI') {
      return null;
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final prompt =
        '''Analiza esta imagen e identifica el objeto, animal, planta o ser vivo principal.

Responde EXACTAMENTE en este formato (una linea por campo):
NOMBRE: [nombre comun en espanol]
CIENTIFICO: [nombre cientifico si aplica, o "No aplica"]
TIPO: [animal/planta/insecto/hongo/objeto]
DESCRIPCION: [2-3 oraciones educativas para estudiantes de primaria]
HABITAT: [donde vive o se encuentra, o "No aplica" si es objeto]
DATO: [un dato curioso e interesante]
CONFIANZA: [numero del 1 al 100 indicando que tan seguro estas]

Solo responde con esas 7 lineas, nada mas.''';

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                    {
                      'inline_data': {
                        'mime_type': 'image/jpeg',
                        'data': base64Image,
                      },
                    },
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 500},
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text']
                as String?;

        if (text != null) {
          return _parseGeminiResponse(text);
        }
      } else {}
    } catch (e) {}

    return null;
  }

  Map<String, dynamic>? _parseGeminiResponse(String text) {
    final result = <String, dynamic>{};
    final lines = text.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('NOMBRE:')) {
        result['nombre'] = line.substring(7).trim();
      } else if (line.startsWith('CIENTIFICO:')) {
        final val = line.substring(11).trim();
        result['cientifico'] = val.toLowerCase() == 'no aplica' ? '' : val;
      } else if (line.startsWith('TIPO:')) {
        result['tipo'] = line.substring(5).trim().toLowerCase();
      } else if (line.startsWith('DESCRIPCION:')) {
        result['descripcion'] = line.substring(12).trim();
      } else if (line.startsWith('HABITAT:')) {
        final val = line.substring(8).trim();
        result['habitat'] = val.toLowerCase() == 'no aplica' ? '' : val;
      } else if (line.startsWith('DATO:')) {
        result['dato'] = line.substring(5).trim();
      } else if (line.startsWith('CONFIANZA:')) {
        final val = line.substring(10).trim().replaceAll(RegExp(r'[^0-9]'), '');
        result['confianza'] = int.tryParse(val) ?? 80;
      }
    }

    if (result['nombre'] != null && result['nombre'].toString().isNotEmpty) {
      return result;
    }
    return null;
  }

  Future<Map<String, dynamic>?> _classifyWithTFLite(File imageFile) async {
    if (_interpreter == null) return null;

    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    final resized = img.copyResize(image, width: 224, height: 224);
    final input = Float32List(1 * 224 * 224 * 3);
    int idx = 0;

    // Normalizacion correcta para MobileNet V2: (pixel/127.5) - 1.0 = rango [-1, 1]
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input[idx++] = (pixel.r / 127.5) - 1.0;
        input[idx++] = (pixel.g / 127.5) - 1.0;
        input[idx++] = (pixel.b / 127.5) - 1.0;
      }
    }

    final inputTensor = input.reshape([1, 224, 224, 3]);
    final output = List.filled(
      1 * _labels.length,
      0.0,
    ).reshape([1, _labels.length]);

    _interpreter!.run(inputTensor, output);

    final scores = output[0] as List<double>;

    // Encontrar top 3 para mejor precision
    List<MapEntry<int, double>> indexed = [];
    for (int i = 0; i < scores.length; i++) {
      indexed.add(MapEntry(i, scores[i]));
    }
    indexed.sort((a, b) => b.value.compareTo(a.value));

    if (indexed.isNotEmpty && indexed[0].key < _labels.length) {
      final topLabel = _labels[indexed[0].key].trim();
      final topScore = indexed[0].value;

      // Log top 3 para debug
      for (int i = 0; i < 3 && i < indexed.length; i++) {
        if (indexed[i].key < _labels.length) {}
      }

      return {'label': topLabel, 'confidence': topScore};
    }

    return null;
  }

  Future<Map<String, String>?> _generarDescripcionConGroq(
    String objeto,
    String tipo,
  ) async {
    try {
      final prompt =
          '''Genera informacion educativa breve sobre: "$objeto" (tipo: $tipo)

Responde EXACTAMENTE en este formato (una linea por campo):
NOMBRE: [nombre en espanol]
CIENTIFICO: [nombre cientifico si es ser vivo, o "No aplica"]
DESCRIPCION: [2 oraciones educativas para estudiantes]
HABITAT: [donde se encuentra, o "No aplica" si es objeto]
DATO: [un dato curioso]

Solo responde con esas 5 lineas, nada mas.''';

      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_groqApiKey',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              'max_tokens': 300,
              'temperature': 0.3,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'] as String;
        return _parseGroqResponse(text);
      }
    } catch (e) {}
    return null;
  }

  Map<String, String> _parseGroqResponse(String text) {
    final result = <String, String>{};
    final lines = text.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('NOMBRE:')) {
        result['nombre'] = line.substring(7).trim();
      } else if (line.startsWith('CIENTIFICO:')) {
        final val = line.substring(11).trim();
        result['cientifico'] = val.toLowerCase() == 'no aplica' ? '' : val;
      } else if (line.startsWith('DESCRIPCION:')) {
        result['descripcion'] = line.substring(12).trim();
      } else if (line.startsWith('HABITAT:')) {
        final val = line.substring(8).trim();
        result['habitat'] = val.toLowerCase() == 'no aplica' ? '' : val;
      } else if (line.startsWith('DATO:')) {
        result['dato'] = line.substring(5).trim();
      }
    }

    return result;
  }

  String _detectTipo(String label) {
    final l = label.toLowerCase();

    final animales = [
      'dog',
      'cat',
      'bird',
      'fish',
      'horse',
      'cow',
      'elephant',
      'lion',
      'tiger',
      'bear',
      'monkey',
      'rabbit',
      'deer',
      'wolf',
      'fox',
      'whale',
      'dolphin',
      'shark',
      'frog',
      'snake',
      'turtle',
      'panda',
    ];
    final plantas = [
      'flower',
      'tree',
      'plant',
      'rose',
      'sunflower',
      'tulip',
      'cactus',
      'grass',
      'leaf',
    ];
    final insectos = [
      'butterfly',
      'bee',
      'ant',
      'spider',
      'beetle',
      'dragonfly',
      'mosquito',
      'fly',
    ];
    final hongos = ['mushroom', 'fungus'];

    if (animales.any((a) => l.contains(a))) return 'animal';
    if (plantas.any((p) => l.contains(p))) return 'planta';
    if (insectos.any((i) => l.contains(i))) return 'insecto';
    if (hongos.any((h) => l.contains(h))) return 'hongo';

    return 'objeto';
  }

  String _traducirAlEspanol(String label) {
    final traducciones = {
      'dog': 'Perro',
      'cat': 'Gato',
      'bird': 'Ave',
      'fish': 'Pez',
      'horse': 'Caballo',
      'cow': 'Vaca',
      'elephant': 'Elefante',
      'lion': 'Leon',
      'tiger': 'Tigre',
      'bear': 'Oso',
      'panda': 'Oso Panda',
      'giant panda': 'Oso Panda Gigante',
      'monkey': 'Mono',
      'rabbit': 'Conejo',
      'deer': 'Ciervo',
      'wolf': 'Lobo',
      'fox': 'Zorro',
      'whale': 'Ballena',
      'dolphin': 'Delfin',
      'shark': 'Tiburon',
      'frog': 'Rana',
      'snake': 'Serpiente',
      'turtle': 'Tortuga',
      'flower': 'Flor',
      'tree': 'Arbol',
      'plant': 'Planta',
      'rose': 'Rosa',
      'sunflower': 'Girasol',
      'butterfly': 'Mariposa',
      'bee': 'Abeja',
      'ant': 'Hormiga',
      'spider': 'Arana',
      'mushroom': 'Hongo',
      'apple': 'Manzana',
      'banana': 'Platano',
      'orange': 'Naranja',
      'car': 'Carro',
      'phone': 'Telefono',
      'book': 'Libro',
      'chair': 'Silla',
      'table': 'Mesa',
      'computer': 'Computadora',
      'cup': 'Taza',
      'bottle': 'Botella',
      'keyboard': 'Teclado',
      'mouse': 'Raton',
      'pen': 'Boligrafo',
      'television': 'Television',
      'lamp': 'Lampara',
      'clock': 'Reloj',
    };

    final l = label.toLowerCase().trim();
    for (var entry in traducciones.entries) {
      if (l.contains(entry.key)) {
        return entry.value;
      }
    }

    // Capitalizar si no hay traduccion
    return label
        .split(' ')
        .map(
          (w) =>
              w.isNotEmpty
                  ? w[0].toUpperCase() + w.substring(1).toLowerCase()
                  : w,
        )
        .join(' ');
  }

  String _getDescripcionBasica(String nombre, String tipo) {
    switch (tipo) {
      case 'animal':
        return '$nombre es un animal. Forma parte del reino animal y tiene caracteristicas propias de su especie.';
      case 'planta':
        return '$nombre es una planta. Las plantas son seres vivos que realizan la fotosintesis.';
      case 'insecto':
        return '$nombre es un insecto. Los insectos son invertebrados con seis patas.';
      case 'hongo':
        return '$nombre es un hongo. Los hongos son organismos que no realizan fotosintesis.';
      default:
        return 'Objeto identificado: $nombre.';
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
