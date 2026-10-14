import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Resultado del escaneo inteligente.
///
/// Todo el proceso usa la API de Groq: `qwen/qwen3.8-27b` es el unico modelo
/// con vision de la plataforma, asi que realiza la deteccion, y despues se usa
/// el mismo servicio para redactar la ficha educativa.
class ScannerResult {
  final String nombreComun;
  final String nombreCientifico;
  final String descripcion;
  final String habitat;
  final String datoCurioso;
  final String clasificacion;
  final int confianza;
  final String tipo;

  /// false cuando lo escaneado no pertence al temario de ciencias naturales.
  final bool esDelTema;

  /// Explicacion de por que se considera fuera de tema.
  final String motivo;

  /// Cuando la confianza es baja se avisa al estudiante en vez de mostrar la
  /// ficha como si fuera certera.
  final bool confianzaBaja;

  ScannerResult({
    required this.nombreComun,
    required this.nombreCientifico,
    required this.descripcion,
    required this.habitat,
    required this.datoCurioso,
    required this.clasificacion,
    required this.confianza,
    required this.tipo,
    required this.esDelTema,
    this.motivo = '',
    this.confianzaBaja = false,
  });

  /// Umbral bajo el cual la deteccion se considera poco fiable.
  static const int umbralConfianzaBaja = 55;

  factory ScannerResult.fueraDeTema({
    required String nombre,
    required String tipo,
    required int confianza,
    required String motivo,
  }) {
    return ScannerResult(
      nombreComun: nombre,
      nombreCientifico: '',
      descripcion: '',
      habitat: '',
      datoCurioso: '',
      clasificacion: '',
      confianza: confianza,
      tipo: tipo,
      esDelTema: false,
      motivo: motivo,
    );
  }
}

/// Error de escaneo con un mensaje pensado para mostrarse al estudiante.
class ScannerException implements Exception {
  final String mensaje;
  const ScannerException(this.mensaje);

  @override
  String toString() => mensaje;
}

class ScannerService {
  /// El prompt de vision se mantiene corto a proposito. Con una lista larga de
  /// "que no es del temario" (muebles, vehiculos, juguetes...) el modelo se
  /// descentraba y respondia "ilustracion abstracta" con 100% de confianza
  /// ante una foto claramente reconocible. Las reglas negativas se resolvieron
  /// acortando el enunciado, no enumerando exclusiones.
  static const String _systemPromptDeteccion =
      'Eres un naturalista experto en ciencias naturales. Respondes '
      'exclusivamente con un objeto JSON valido.';

  static const String _promptDeteccion =
      'Identifica el elemento de la foto y responde con un objeto JSON con '
      'estas claves exactas: {"es_del_tema":booleano,"nombre_comun":texto,'
      '"nombre_cientifico":texto,"tipo":texto,"confianza":entero 0-100,'
      '"motivo":texto}. Esta guia trata sobre la celula y las ciencias '
      'naturales, asi que "es_del_tema" es true para seres vivos, elementos '
      'naturales y para TODO lo relacionado con la celula: celulas animales, '
      'celulas vegetales, microorganismos y organelos o partes celulares como '
      'nucleo, mitocondria, cloroplasto, membrana plasmatica, pared celular, '
      'citoplasma, vacuola, ribosomas, aparato de Golgi, lisosomas, centriolos '
      'o reticulo endoplasmatico. Cuenta tambien si es una foto de microscopio, '
      'un dibujo, un esquema, un diagrama, una maqueta o un modelo 3D de la '
      'celula o de un organelo. "es_del_tema" es false solo para objetos '
      'fabricados que no tienen que ver con la guia (muebles, vehiculos, '
      'juguetes, aparatos electronicos, ropa, etc.). Reglas: "tipo" debe ser '
      'celula, organelo, microorganismo, animal, planta, insecto, hongo, fruta, '
      'verdura, flor, mineral, roca u otro. "nombre_cientifico" va en latin, '
      'vacio si no aplica (para celula u organelo deja vacio). "motivo" explica '
      'en una frase breve por que no es del temario cuando "es_del_tema" es '
      'false, y queda vacio cuando es true. "confianza" es tu certeza real: una '
      'foto borrosa, lejana o con el elemento tapado debe tener confianza '
      'baja. No la inflas.';

  ScannerService();

  /// Nombres de organelos y partes celulares que confirman que lo escaneado
  /// pertenece a la guia, aunque el modelo lo haya marcado como fuera de tema.
  static const List<String> _clavesOrganelo = [
    'organelo',
    'organelle',
    'nucleo',
    'nucleolo',
    'mitocondria',
    'cloroplasto',
    'membrana',
    'pared celular',
    'citoplasma',
    'vacuola',
    'ribosoma',
    'golgi',
    'lisosoma',
    'centriolo',
    'reticulo',
    'endoplasmatico',
    'citoesqueleto',
    'flagelo',
    'cilia',
  ];

  /// Palabras que indican contenido sobre la celula en general.
  static const List<String> _clavesCelula = [
    'celula',
    'cell',
    'microscopio',
    'microorganismo',
    'bacteria',
    'protozoo',
    'unicelular',
    'citologia',
  ];

  /// Quita acentos y normaliza para comparar nombres sin depender de tildes.
  static String _sinAcentos(String texto) => texto
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n');

  static String _textoDeteccion(Map<String, dynamic> deteccion) => _sinAcentos(
    '${deteccion['nombre_comun']} ${deteccion['nombre_cientifico']} '
            '${deteccion['motivo']} ${deteccion['tipo']}'
        .toLowerCase(),
  );

  bool _esContenidoCelular(Map<String, dynamic> deteccion) {
    final texto = _textoDeteccion(deteccion);
    return _clavesCelula.any(texto.contains) ||
        _clavesOrganelo.any(texto.contains);
  }

  bool _esOrganelo(Map<String, dynamic> deteccion) {
    final texto = _textoDeteccion(deteccion);
    return _clavesOrganelo.any(texto.contains);
  }

  /// Ejecuta el escaneo completo usando solo la API de Groq.
  ///
  /// [onEsperando] recibe un aviso para mostrar mientras la peticion espera a
  /// que se libere el limite de la API, que en clase se agota con facilidad.
  Future<ScannerResult> identificarImagen(
    File imageFile, {
    void Function(String mensaje)? onEsperando,
  }) async {
    final problema = AppConfig.groqApiKeyProblem;
    if (problema != null) {
      throw ScannerException('El escaner no esta configurado. $problema');
    }

    final deteccion = await _detectarConVision(imageFile, onEsperando);

    // Red de seguridad: la guia trata sobre la celula, asi que si la IA marco
    // contenido celular como "fuera de tema" (por ejemplo por ser un dibujo,
    // un esquema o un modelo) se corrige y se trata como parte de la guia.
    if (!deteccion['es_del_tema'] && _esContenidoCelular(deteccion)) {
      deteccion['es_del_tema'] = true;
      deteccion['tipo'] = _esOrganelo(deteccion) ? 'organelo' : 'celula';
      deteccion['motivo'] = '';
      deteccion['nombre_cientifico'] = '';
    }

    // Fuera de tema: se informa al estudiante y no se inventa informacion.
    if (!deteccion['es_del_tema']) {
      return ScannerResult.fueraDeTema(
        nombre: deteccion['nombre_comun'],
        tipo: deteccion['tipo'],
        confianza: deteccion['confianza'],
        motivo: deteccion['motivo'],
      );
    }

    final confianza = deteccion['confianza'];

    // Segunda llamada: el mismo servicio redacta la ficha educativa a partir de
    // lo que la vision ya detecto.
    Map<String, String> ficha = const {};
    try {
      ficha = await _redactarFicha(
        nombre: deteccion['nombre_comun'],
        nombreCientifico: deteccion['nombre_cientifico'],
        tipo: deteccion['tipo'],
        onEsperando: onEsperando,
      );
    } on ScannerException {
      rethrow;
    } catch (_) {
      // La ficha es un complemento: si falla, la deteccion sigue siendo valida.
    }

    return ScannerResult(
      nombreComun: deteccion['nombre_comun'],
      nombreCientifico: deteccion['nombre_cientifico'],
      descripcion:
          ficha['descripcion'] ??
          '${deteccion['nombre_comun']} es un elemento de ciencias naturales '
              'identificado en la imagen.',
      habitat: ficha['habitat'] ?? '',
      datoCurioso: ficha['dato_curioso'] ?? '',
      clasificacion: ficha['clasificacion'] ?? '',
      confianza: confianza,
      tipo: deteccion['tipo'],
      esDelTema: true,
      confianzaBaja: confianza < ScannerResult.umbralConfianzaBaja,
    );
  }

  /// Paso 1: deteccion visual con el modelo de vision de Groq.
  Future<Map<String, dynamic>> _detectarConVision(
    File imageFile,
    void Function(String mensaje)? onEsperando,
  ) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final content = await _groqJson(
      systemPrompt: _systemPromptDeteccion,
      userPrompt: _promptDeteccion,
      imageBase64: base64Image,
      maxTokens: 500,
      temperature: 0.1,
      onEsperando: onEsperando,
    );

    return _normalizarDeteccion(_decodificar(content));
  }

  /// Paso 2: el mismo servicio redacta la ficha educativa del elemento ya
  /// detectado. Aqui solo hay texto, asi que puede usar el modelo de texto.
  Future<Map<String, String>> _redactarFicha({
    required String nombre,
    required String nombreCientifico,
    required String tipo,
    void Function(String mensaje)? onEsperando,
  }) async {
    final contexto = nombreCientifico.isNotEmpty ? ' ($nombreCientifico)' : '';

    final content = await _groqJson(
      systemPrompt:
          'Eres un naturalista que escribe fichas educativas breves para '
          'estudiantes de secundaria. Respondes solo en JSON valido.',
      userPrompt:
          '''Genera la ficha educativa de: "$nombre"$contexto (tipo: $tipo)

Devuelve un objeto JSON con exactamente estas claves:
{
  "descripcion": "2 o 3 oraciones educativas sobre que es y como se caracteriza",
  "habitat": "Donde vive, donde crece o donde se encuentra. Si no aplica, cadena vacia.",
  "dato_curioso": "Un dato curioso e interesante para estudiantes",
  "clasificacion": "Cadena de clasificacion taxonomica, por ejemplo: Reino; Orden; Familia; Genero; Especie. Si no aplica, cadena vacia."
}

Si el tipo es "celula" u "organelo", la descripcion debe explicar con claridad
que es y cual es su funcion dentro de la celula. En "habitat" NO hables de
habitat como si fuera un animal: para un "organelo" escribe en que parte de la
celula se encuentra y en que tipos de celulas esta presente; para una "celula"
escribe su tipo (procariota o eucariota, animal o vegetal) y donde se encuentra
ese tipo de celula. Deja "clasificacion" vacia.

Si no estas seguro de un dato cientifico, no lo inventes: escribe una
descripcion generica y correcta en lugar de un nombre especifico dudoso.''',
      maxTokens: 2048,
      temperature: 0.4,
      onEsperando: onEsperando,
    );

    final ficha = _decodificar(content) as Map<String, dynamic>;
    String leer(String clave) => (ficha[clave] as String?)?.trim() ?? '';
    return {
      'descripcion': leer('descripcion'),
      'habitat': leer('habitat'),
      'dato_curioso': leer('dato_curioso'),
      'clasificacion': leer('clasificacion'),
    };
  }

  /// Llamada JSON a Groq. Si [imageBase64] se envia, usa el modelo de vision.
  Future<String> _groqJson({
    required String systemPrompt,
    required String userPrompt,
    String? imageBase64,
    required int maxTokens,
    required double temperature,
    void Function(String mensaje)? onEsperando,
  }) async {
    final conImagen = imageBase64 != null;
    final modelo = conImagen ? AppConfig.groqVisionModel : AppConfig.groqModel;

    final List<Map<String, dynamic>> mensajeUsuario;
    if (conImagen) {
      mensajeUsuario = [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': userPrompt},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'},
            },
          ],
        },
      ];
    } else {
      mensajeUsuario = [
        {'role': 'user', 'content': userPrompt},
      ];
    }

    final http.Response response;
    try {
      response = await _groqPost(
        body: jsonEncode({
          'model': modelo,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...mensajeUsuario,
          ],
          'response_format': {'type': 'json_object'},
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
        conImagen: conImagen,
        onEsperando: onEsperando,
      );
    } on SocketException {
      throw const ScannerException(
        'Sin conexion a internet. Conectate e intenta de nuevo.',
      );
    } on http.ClientException {
      throw const ScannerException(
        'No se pudo completar la peticion. Intenta de nuevo.',
      );
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        throw const ScannerException(
          'La IA no genero respuesta. Intenta de nuevo.',
        );
      }
      return content;
    }

    switch (response.statusCode) {
      case 400:
        if (conImagen) {
          throw const ScannerException(
            'La IA no pudo procesar esa imagen. Prueba con una foto mas nitida '
            'o de menor tamano.',
          );
        }
        throw const ScannerException(
          'La IA no pudo generar la ficha. Intenta de nuevo.',
        );
      case 401:
      case 403:
        throw const ScannerException(
          'La clave de la IA no es valida o no tiene permisos. Revisa '
          'GROQ_API_KEY en el archivo .env.',
        );
      case 404:
        throw ScannerException(
          conImagen
              ? 'El modelo de vision "${AppConfig.groqVisionModel}" no esta '
                    'disponible en Groq. Revisa GROQ_VISION_MODEL en .env.'
              : 'El modelo "${AppConfig.groqModel}" ya no esta disponible. '
                    'Revisa GROQ_MODEL en el archivo .env.',
        );
      case 413:
        throw const ScannerException(
          'La imagen es demasiado grande. Intenta con una foto mas pequena.',
        );
      case 429:
        throw const ScannerException(
          'Muchos estudiantes estan escaneando al mismo tiempo y el servicio '
          'llego a su limite. Espera medio minuto e intenta de nuevo.',
        );
      case 500:
      case 503:
        throw const ScannerException(
          'El servicio de IA no esta disponible. Intenta mas tarde.',
        );
      default:
        throw ScannerException(
          conImagen
              ? 'No se pudo analizar la imagen. Intenta de nuevo.'
              : 'No se pudo generar la ficha. Intenta de nuevo.',
        );
    }
  }

  /// Envia la peticion a Groq y reintenta cuando el servicio esta saturado.
  ///
  /// El modelo de vision tiene un tope de tokens por minuto muy bajo (8000) y
  /// cada imagen consume alrededor de 1300, asi que en clase varios estudiantes
  /// escanean a la vez y se chocan contra el limite. El error 429 es transitorio:
  /// basta con esperar a que se libere la ventana del minuto.
  Future<http.Response> _groqPost({
    required String body,
    required bool conImagen,
    void Function(String mensaje)? onEsperando,
  }) async {
    const intentos = 3;
    const esperas = [Duration(seconds: 15), Duration(seconds: 30)];

    for (var intento = 1; intento <= intentos; intento++) {
      final response = await http
          .post(
            Uri.parse(AppConfig.groqApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppConfig.groqApiKey}',
            },
            body: body,
          )
          .timeout(Duration(seconds: conImagen ? 60 : 30));

      final saturado =
          response.statusCode == 429 ||
          response.statusCode == 500 ||
          response.statusCode == 503;
      if (!saturado || intento == intentos) return response;

      final segundos = esperas[intento - 1].inSeconds;
      onEsperando?.call(
        'El servicio de IA esta saturado. Reintento $intento de $intentos en '
        '$segundos s...',
      );
      await Future<void>.delayed(esperas[intento - 1]);
    }

    // El bucle siempre retorna; esta linea es inalcanzable.
    throw const ScannerException(
      'El servicio de IA esta ocupado. Intenta de nuevo en un momento.',
    );
  }

  /// Elimina las cercas de codigo que a veces anade el modelo.
  dynamic _decodificar(String content) {
    var limpio = content.trim();
    if (limpio.startsWith('```json')) {
      limpio = limpio.substring(7);
    } else if (limpio.startsWith('```')) {
      limpio = limpio.substring(3);
    }
    if (limpio.endsWith('```')) {
      limpio = limpio.substring(0, limpio.length - 3);
    }

    try {
      return jsonDecode(limpio.trim());
    } on FormatException {
      throw const ScannerException(
        'La IA respondio en un formato inesperado. Intenta de nuevo.',
      );
    }
  }

  /// Sanea la respuesta para que el resto del codigo no tenga que defenderse de
  /// tipos inesperados.
  Map<String, dynamic> _normalizarDeteccion(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const ScannerException(
        'La IA respondio en un formato inesperado. Intenta de nuevo.',
      );
    }

    const tiposValidos = {
      'celula',
      'organelo',
      'microorganismo',
      'animal',
      'planta',
      'insecto',
      'hongo',
      'fruta',
      'verdura',
      'flor',
      'mineral',
      'roca',
      'otro',
    };

    final nombre = (raw['nombre_comun'] as String?)?.trim() ?? '';
    if (nombre.isEmpty) {
      throw const ScannerException(
        'No se pudo identificar el contenido de la foto. Intenta con una '
        'imagen mas clara.',
      );
    }

    var tipo = (raw['tipo'] as String?)?.trim().toLowerCase() ?? 'otro';
    if (!tiposValidos.contains(tipo)) tipo = 'otro';

    final confianzaCruda = raw['confianza'];
    final confianza = switch (confianzaCruda) {
      final int v => v,
      final num v => v.round(),
      final String v => int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      _ => 0,
    };

    return {
      'es_del_tema': raw['es_del_tema'] == true,
      'nombre_comun': nombre,
      'nombre_cientifico': (raw['nombre_cientifico'] as String?)?.trim() ?? '',
      'tipo': tipo,
      'confianza': confianza.clamp(0, 100),
      'motivo': (raw['motivo'] as String?)?.trim() ?? '',
    };
  }
}
