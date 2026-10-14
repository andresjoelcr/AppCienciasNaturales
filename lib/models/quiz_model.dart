class Pregunta {
  final String pregunta;
  final List<String> opciones;
  final int respuestaCorrecta;
  final String? explicacion;

  const Pregunta({
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrecta,
    this.explicacion,
  });
}

class Quiz {
  final String titulo;
  final List<Pregunta> preguntas;

  const Quiz({
    required this.titulo,
    required this.preguntas,
  });
}
