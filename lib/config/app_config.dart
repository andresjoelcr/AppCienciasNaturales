import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;

class AppConfig {
  /// Claves cargadas desde el `.env` empaquetado como asset.
  ///
  /// Flutter solo resuelve [String.fromEnvironment] al compilar, asi que sin
  /// `--dart-define-from-file=.env` el chat y el escaner quedan sin clave. Para
  /// que la app funcione siempre (F5, `flutter run` a secas o APK ya instalado)
  /// se lee tambien el `.env` empaquetado. El flag manda si se uso.
  static final Map<String, String> _vars = <String, String>{};

  static bool _cargado = false;

  /// Lee el `.env` empaquetado. Es idempotente y seguro de llamar varias veces.
  static Future<void> init() async {
    if (_cargado) return;
    _cargado = true;
    try {
      final contenido = await rootBundle.loadString('assets/groq.env');
      _vars.addAll(_parsearEnv(contenido));
    } catch (e) {
      // Sin asset empaquetado: solo queda el camino del --dart-define.
      debugPrint('[AppConfig] no se pudo leer assets/groq.env: $e');
    }
  }

  /// Interpreta un `.env` sencillo: `CLAVE=valor`, `#` comenta, comillas opcionales.
  static Map<String, String> _parsearEnv(String contenido) {
    final resultado = <String, String>{};
    for (final lineaCruda in contenido.split(RegExp(r'\r?\n'))) {
      final linea = lineaCruda.trim();
      if (linea.isEmpty || linea.startsWith('#')) continue;
      final indiceIgual = linea.indexOf('=');
      if (indiceIgual < 0) continue;
      resultado[linea.substring(0, indiceIgual).trim()] = linea
          .substring(indiceIgual + 1)
          .trim()
          .replaceAll(RegExp(r'''^["']|["']$'''), '');
    }
    return resultado;
  }

  /// Busca una variable en el flag de compilacion y, si no, en el asset.
  static String _leer(String nombre, {required String porDefecto}) {
    final desdeFlag = String.fromEnvironment(nombre);
    if (desdeFlag.isNotEmpty) return desdeFlag;
    return _vars[nombre] ?? porDefecto;
  }

  static String get groqApiKey => _leer('GROQ_API_KEY', porDefecto: '');

  static const String groqApiUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  /// Modelo de texto: redacta el chatbot, los quizzes y las fichas educativas.
  static String get groqModel =>
      _leer('GROQ_MODEL', porDefecto: 'openai/gpt-oss-20b');

  /// Modelo con vision que identifica el elemento en la foto del escaner.
  /// `qwen/qwen3.8-27b` es el unico de Groq que acepta imagenes; los gpt-oss y
  /// allam-2 son solo texto.
  static String get groqVisionModel =>
      _leer('GROQ_VISION_MODEL', porDefecto: 'qwen/qwen3.8-27b');

  /// Placeholders que aparecen en .env.example cuando la clave no fue rellenada.
  static const List<String> _placeholders = <String>[
    'tu_clave_de_groq',
    'TU_API_KEY_AQUI',
  ];

  static bool _isUsable(String value) =>
      value.isNotEmpty && !_placeholders.contains(value);

  static bool get hasGroqApiKey => _isUsable(groqApiKey);

  /// Motivo por el que Groq no esta disponible, o null si si lo esta.
  static String? get groqApiKeyProblem {
    if (hasGroqApiKey) return null;
    if (groqApiKey.isEmpty) {
      return 'GROQ_API_KEY no se encontro ni en la compilacion ni en el '
          '.env empaquetado.';
    }
    return 'GROQ_API_KEY sigue con el valor de ejemplo de .env.example';
  }
}
