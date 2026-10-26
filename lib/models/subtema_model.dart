import 'quiz_model.dart';

class Subtema {
  final String id;
  final String numero;
  final String titulo;
  final String descripcion;
  final List<ContenidoSeccion> contenido;
  final Quiz quiz;
  final String? imagenUrl;

  const Subtema({
    required this.id,
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.contenido,
    required this.quiz,
    this.imagenUrl,
  });
}

class ContenidoSeccion {
  // 'texto', 'titulo', 'subtitulo', 'lista', 'destacado', 'sabias_que',
  // 'video', 'imagen', 'imagen_comparativa', 'imagen_grid', 'tarjeta_funcion'
  final String tipo;
  final String contenido;
  final List<String>? items;
  final String? titulo;
  final String? notaImportante;

  /// Bloques internos usados por las tarjetas interactivas
  /// ('comparativo', 'mapa_conceptual', 'pasos', 'texto' y 'video').
  final List<ContenidoSeccion>? bloques;

  const ContenidoSeccion({
    required this.tipo,
    required this.contenido,
    this.items,
    this.titulo,
    this.notaImportante,
    this.bloques,
  });
}
