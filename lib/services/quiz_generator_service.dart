import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/quiz_model.dart';
import 'guia_context_service.dart';

/// Resultado de la generacion de quiz
class QuizGenerationResult {
  final Quiz? quiz;
  final String? error;
  final bool success;

  QuizGenerationResult.success(this.quiz)
      : error = null,
        success = true;

  QuizGenerationResult.failure(this.error)
      : quiz = null,
        success = false;
}

/// Servicio para generar quizzes dinamicos usando IA
class QuizGeneratorService {

  /// Genera un quiz basado en el contenido de un subtema
  ///
  /// [subtemaId] - ID del subtema (ej: "1.1", "1.2")
  /// [subtemaTitulo] - Titulo del subtema
  /// [numeroPreguntas] - Cantidad de preguntas a generar (default: 5)
  /// [dificultad] - Nivel de dificultad: "facil", "medio", "dificil"
  static Future<QuizGenerationResult> generarQuiz({
    required String subtemaId,
    required String subtemaTitulo,
    int numeroPreguntas = 5,
    String dificultad = 'medio',
  }) async {
    try {
      // Obtener el contenido del subtema
      final contenidoSubtema = GuiaContextService.getSubtemaInfo(subtemaId);

      if (contenidoSubtema == null) {
        return QuizGenerationResult.failure(
          'No se encontro el contenido del subtema $subtemaId',
        );
      }

      // Construir el prompt para la IA
      final prompt = _construirPrompt(
        contenido: contenidoSubtema,
        subtemaTitulo: subtemaTitulo,
        numeroPreguntas: numeroPreguntas,
        dificultad: dificultad,
      );

      // Llamar a la API de Groq
      final response = await http
          .post(
            Uri.parse(AppConfig.groqApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppConfig.groqApiKey}',
            },
            body: jsonEncode({
              'model': AppConfig.groqModel,
              'messages': [
                {
                  'role': 'system',
                  'content': _getSystemPrompt(),
                },
                {
                  'role': 'user',
                  'content': prompt,
                }
              ],
              'temperature': 0.7,
              'max_tokens': 2500,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Tiempo de espera agotado'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contenidoRespuesta = data['choices'][0]['message']['content'];

        // Parsear la respuesta JSON de la IA
        final quiz = _parsearRespuestaIA(contenidoRespuesta, subtemaTitulo);

        if (quiz != null) {
          return QuizGenerationResult.success(quiz);
        } else {
          return QuizGenerationResult.failure(
            'No se pudo procesar la respuesta de la IA',
          );
        }
      } else if (response.statusCode == 429) {
        return QuizGenerationResult.failure(
          'Demasiadas solicitudes. Intenta de nuevo en unos segundos.',
        );
      } else {
        return QuizGenerationResult.failure(
          'Error del servidor (${response.statusCode}). Intenta de nuevo.',
        );
      }
    } on FormatException {
      return QuizGenerationResult.failure(
        'Error al procesar la respuesta. Intenta de nuevo.',
      );
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        return QuizGenerationResult.failure(
          'Sin conexion a internet. Verifica tu conexion.',
        );
      }
      if (e.toString().contains('Tiempo de espera')) {
        return QuizGenerationResult.failure(
          'Tiempo de espera agotado. Intenta de nuevo.',
        );
      }
      return QuizGenerationResult.failure(
        'Error inesperado. Intenta de nuevo.',
      );
    }
  }

  /// Construye el system prompt para la IA
  static String _getSystemPrompt() {
    return '''Eres un experto en educacion y creacion de evaluaciones para estudiantes de primaria y secundaria.
Tu tarea es generar preguntas de opcion multiple de alta calidad basadas en contenido educativo sobre ciencias naturales.

REGLAS ESTRICTAS:
1. Las preguntas deben ser claras, educativas y apropiadas para estudiantes
2. Cada pregunta debe tener exactamente 4 opciones de respuesta
3. Solo UNA opcion debe ser correcta
4. Las opciones incorrectas deben ser plausibles pero claramente incorrectas
5. Incluye una explicacion educativa breve para cada respuesta correcta
6. Responde UNICAMENTE con JSON valido, sin texto adicional antes o despues
7. No uses caracteres especiales que puedan romper el JSON
8. Las preguntas deben variar en estilo: definiciones, funciones, comparaciones, aplicaciones
9. Mezcla el orden de las respuestas correctas (no siempre sea la opcion A)''';
  }

  /// Construye el prompt del usuario con el contenido del subtema
  static String _construirPrompt({
    required String contenido,
    required String subtemaTitulo,
    required int numeroPreguntas,
    required String dificultad,
  }) {
    String nivelDescripcion;
    switch (dificultad) {
      case 'facil':
        nivelDescripcion =
            'preguntas basicas de definiciones y conceptos simples, con respuestas obvias';
        break;
      case 'dificil':
        nivelDescripcion =
            'preguntas de analisis, comparacion, aplicacion de conceptos y relaciones complejas';
        break;
      default:
        nivelDescripcion =
            'preguntas de comprension y relacion de conceptos con dificultad moderada';
    }

    return '''Genera exactamente $numeroPreguntas preguntas de opcion multiple sobre el tema: "$subtemaTitulo"

CONTENIDO DEL TEMA PARA BASAR LAS PREGUNTAS:
$contenido

NIVEL DE DIFICULTAD: $dificultad ($nivelDescripcion)

FORMATO DE RESPUESTA REQUERIDO (JSON valido):
{
  "preguntas": [
    {
      "pregunta": "Texto completo de la pregunta terminando en signo de interrogacion",
      "opciones": ["Opcion A", "Opcion B", "Opcion C", "Opcion D"],
      "respuestaCorrecta": 0,
      "explicacion": "Explicacion breve y educativa de por que esta es la respuesta correcta"
    }
  ]
}

IMPORTANTE:
- respuestaCorrecta es el INDICE (0, 1, 2 o 3) de la opcion correcta en el array
- Varia el indice de la respuesta correcta entre las preguntas
- Las explicaciones deben ser educativas y ayudar al estudiante a entender
- Basa las preguntas SOLO en el contenido proporcionado
- Responde UNICAMENTE con el JSON, sin texto adicional''';
  }

  /// Parsea la respuesta de la IA al modelo Quiz
  static Quiz? _parsearRespuestaIA(String respuesta, String titulo) {
    try {
      // Limpiar la respuesta - remover posibles marcadores de codigo
      String jsonLimpio = respuesta.trim();

      // Remover marcadores de codigo markdown si existen
      if (jsonLimpio.startsWith('```json')) {
        jsonLimpio = jsonLimpio.substring(7);
      } else if (jsonLimpio.startsWith('```')) {
        jsonLimpio = jsonLimpio.substring(3);
      }
      if (jsonLimpio.endsWith('```')) {
        jsonLimpio = jsonLimpio.substring(0, jsonLimpio.length - 3);
      }
      jsonLimpio = jsonLimpio.trim();

      // Parsear el JSON
      final Map<String, dynamic> json = jsonDecode(jsonLimpio);
      final List<dynamic> preguntasJson = json['preguntas'];

      // Convertir a objetos Pregunta
      final List<Pregunta> preguntas = preguntasJson.map((p) {
        final opciones = List<String>.from(p['opciones']);
        final respuestaCorrecta = p['respuestaCorrecta'] as int;

        // Validar que la respuesta correcta este en rango
        if (respuestaCorrecta < 0 || respuestaCorrecta >= opciones.length) {
          throw FormatException('Indice de respuesta fuera de rango');
        }

        return Pregunta(
          pregunta: p['pregunta'] as String,
          opciones: opciones,
          respuestaCorrecta: respuestaCorrecta,
          explicacion: p['explicacion'] as String?,
        );
      }).toList();

      // Validar que haya al menos una pregunta
      if (preguntas.isEmpty) {
        return null;
      }

      // Validar que cada pregunta tenga exactamente 4 opciones
      for (final pregunta in preguntas) {
        if (pregunta.opciones.length != 4) {
          return null;
        }
      }

      return Quiz(
        titulo: 'Quiz IA: $titulo',
        preguntas: preguntas,
      );
    } catch (e) {
      return null;
    }
  }
}
