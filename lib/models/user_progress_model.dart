import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final String subtemaId;
  final String subtemaTitulo;
  final bool contenidoVisto;
  final bool quizCompletado;
  final bool quizAprobado;
  final int quizScore;
  final int intentos;
  final DateTime? fechaCompletado;
  final DateTime? ultimoAcceso;

  const UserProgress({
    required this.subtemaId,
    required this.subtemaTitulo,
    required this.contenidoVisto,
    required this.quizCompletado,
    required this.quizAprobado,
    required this.quizScore,
    required this.intentos,
    this.fechaCompletado,
    this.ultimoAcceso,
  });

  // Progreso inicial para un subtema
  factory UserProgress.initial({
    required String subtemaId,
    required String subtemaTitulo,
  }) {
    return UserProgress(
      subtemaId: subtemaId,
      subtemaTitulo: subtemaTitulo,
      contenidoVisto: false,
      quizCompletado: false,
      quizAprobado: false,
      quizScore: 0,
      intentos: 0,
      fechaCompletado: null,
      ultimoAcceso: DateTime.now(),
    );
  }

  // Verificar si el subtema está completado (contenido visto Y quiz aprobado)
  bool get completado => contenidoVisto && quizAprobado;

  // Porcentaje de completitud del subtema
  double get porcentajeCompletado {
    int pasos = 0;
    if (contenidoVisto) pasos++;
    if (quizAprobado) pasos++;
    return pasos / 2;
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'subtemaId': subtemaId,
      'subtemaTitulo': subtemaTitulo,
      'contenidoVisto': contenidoVisto,
      'quizCompletado': quizCompletado,
      'quizAprobado': quizAprobado,
      'quizScore': quizScore,
      'intentos': intentos,
      'fechaCompletado': fechaCompletado != null
          ? Timestamp.fromDate(fechaCompletado!)
          : null,
      'ultimoAcceso': ultimoAcceso != null
          ? Timestamp.fromDate(ultimoAcceso!)
          : null,
    };
  }

  // Crear desde documento de Firestore
  factory UserProgress.fromFirestore(Map<String, dynamic> data) {
    return UserProgress(
      subtemaId: data['subtemaId'] ?? '',
      subtemaTitulo: data['subtemaTitulo'] ?? '',
      contenidoVisto: data['contenidoVisto'] ?? false,
      quizCompletado: data['quizCompletado'] ?? false,
      quizAprobado: data['quizAprobado'] ?? false,
      quizScore: data['quizScore'] ?? 0,
      intentos: data['intentos'] ?? 0,
      fechaCompletado: (data['fechaCompletado'] as Timestamp?)?.toDate(),
      ultimoAcceso: (data['ultimoAcceso'] as Timestamp?)?.toDate(),
    );
  }

  // Crear copia con cambios
  UserProgress copyWith({
    bool? contenidoVisto,
    bool? quizCompletado,
    bool? quizAprobado,
    int? quizScore,
    int? intentos,
    DateTime? fechaCompletado,
    DateTime? ultimoAcceso,
  }) {
    return UserProgress(
      subtemaId: subtemaId,
      subtemaTitulo: subtemaTitulo,
      contenidoVisto: contenidoVisto ?? this.contenidoVisto,
      quizCompletado: quizCompletado ?? this.quizCompletado,
      quizAprobado: quizAprobado ?? this.quizAprobado,
      quizScore: quizScore ?? this.quizScore,
      intentos: intentos ?? this.intentos,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
    );
  }
}
