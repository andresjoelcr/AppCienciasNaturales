import '../data/celula_data.dart';

/// Servicio para generar el contexto de la guía didáctica para el chatbot
class GuiaContextService {
  /// Obtiene la lista de temas disponibles en formato legible
  static String getTemasDisponibles() {
    final buffer = StringBuffer();
    buffer.writeln('TEMAS DISPONIBLES EN LA GUIA DIDACTICA INTERACTIVA:');
    buffer.writeln('');
    buffer.writeln('UNIDAD 1: ${CelulaData.nombreUnidad}');
    buffer.writeln('');

    for (final subtema in CelulaData.subtemas) {
      buffer.writeln('- Subtema ${subtema.numero}: ${subtema.titulo}');
      buffer.writeln('  ${subtema.descripcion}');
    }

    return buffer.toString();
  }

  /// Genera el contexto completo de la guía para el chatbot
  /// Incluye todo el contenido educativo para que pueda dar respuestas detalladas
  static String getContextoCompletoChatbot() {
    final buffer = StringBuffer();

    buffer.writeln('=== GUIA DIDACTICA INTERACTIVA DE CIENCIAS NATURALES ===');
    buffer.writeln('');
    buffer.writeln('UNIDAD 1: ${CelulaData.nombreUnidad}');
    buffer.writeln('');
    buffer.writeln('Esta guia contiene ${CelulaData.subtemas.length} subtemas con contenido educativo y quizzes.');
    buffer.writeln('');

    // Agregar contenido de cada subtema
    for (final subtema in CelulaData.subtemas) {
      buffer.writeln('--- SUBTEMA ${subtema.numero}: ${subtema.titulo.toUpperCase()} ---');
      buffer.writeln('Descripcion: ${subtema.descripcion}');
      buffer.writeln('');

      // Agregar contenido del subtema
      for (final seccion in subtema.contenido) {
        switch (seccion.tipo) {
          case 'titulo':
            buffer.writeln('## ${seccion.contenido}');
            break;
          case 'subtitulo':
            buffer.writeln('### ${seccion.contenido}');
            break;
          case 'texto':
            buffer.writeln(seccion.contenido);
            break;
          case 'lista':
            if (seccion.contenido.isNotEmpty) {
              buffer.writeln(seccion.contenido);
            }
            if (seccion.items != null) {
              for (final item in seccion.items!) {
                buffer.writeln('- $item');
              }
            }
            break;
          case 'destacado':
            buffer.writeln('IMPORTANTE: ${seccion.contenido}');
            break;
          case 'sabias_que':
            buffer.writeln('DATO CURIOSO: ${seccion.contenido}');
            break;
        }
        buffer.writeln('');
      }

      // Agregar info del quiz
      buffer.writeln('Quiz disponible: ${subtema.quiz.preguntas.length} preguntas');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// Obtiene información detallada de un subtema específico
  static String? getSubtemaInfo(String subtemaId) {
    final subtema = CelulaData.getSubtemaById(subtemaId);
    if (subtema == null) return null;

    final buffer = StringBuffer();
    buffer.writeln('SUBTEMA ${subtema.numero}: ${subtema.titulo}');
    buffer.writeln(subtema.descripcion);
    buffer.writeln('');

    for (final seccion in subtema.contenido) {
      if (seccion.tipo == 'titulo') continue;

      switch (seccion.tipo) {
        case 'subtitulo':
          buffer.writeln('${seccion.contenido}:');
          break;
        case 'texto':
          buffer.writeln(seccion.contenido);
          break;
        case 'lista':
          if (seccion.items != null) {
            for (final item in seccion.items!) {
              buffer.writeln('- $item');
            }
          }
          break;
        case 'destacado':
          buffer.writeln('> ${seccion.contenido}');
          break;
        case 'sabias_que':
          buffer.writeln('Sabias que: ${seccion.contenido}');
          break;
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// Genera el system prompt para el chatbot (version minima para respetar limites de tokens)
  static String getSystemPromptConGuia() {
    return 'Eres un asistente educativo de ciencias naturales para estudiantes. '
        'Solo respondes preguntas de biologia, botanica, zoologia, ecologia, celulas, '
        'fotosintesis, ecosistemas y temas relacionados con la naturaleza. '
        'Si preguntan de otro tema, diles amablemente que solo puedes ayudar con ciencias naturales. '
        'Responde en espanol, de forma clara y sencilla, sin formato especial ni asteriscos. '
        'Respuestas cortas y educativas.';
  }
}
