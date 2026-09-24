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
  final String tipo; // 'texto', 'titulo', 'subtitulo', 'lista', 'destacado', 'sabias_que', 'video', 'imagen', 'imagen_comparativa', 'imagen_grid'
  final String contenido;
  final List<String>? items;

  const ContenidoSeccion({
    required this.tipo,
    required this.contenido,
    this.items,
  });
}
