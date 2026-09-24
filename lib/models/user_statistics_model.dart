import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatistics {
  final int totalSubtemasCompletados;
  final int totalQuizzesAprobados;
  final int totalQuizzesRealizados;
  final double promedioPuntajeQuiz;
  final int rachaEstudio;
  final int mejorRacha;
  final DateTime? ultimoDiaEstudio;
  final int tiempoEstudioMinutos;
  final int totalPreguntasChat;

  const UserStatistics({
    required this.totalSubtemasCompletados,
    required this.totalQuizzesAprobados,
    required this.totalQuizzesRealizados,
    required this.promedioPuntajeQuiz,
    required this.rachaEstudio,
    required this.mejorRacha,
    this.ultimoDiaEstudio,
    required this.tiempoEstudioMinutos,
    required this.totalPreguntasChat,
  });

  // Estadísticas iniciales para nuevo usuario
  factory UserStatistics.initial() {
    return const UserStatistics(
      totalSubtemasCompletados: 0,
      totalQuizzesAprobados: 0,
      totalQuizzesRealizados: 0,
      promedioPuntajeQuiz: 0.0,
      rachaEstudio: 0,
      mejorRacha: 0,
      ultimoDiaEstudio: null,
      tiempoEstudioMinutos: 0,
      totalPreguntasChat: 0,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'totalSubtemasCompletados': totalSubtemasCompletados,
      'totalQuizzesAprobados': totalQuizzesAprobados,
      'totalQuizzesRealizados': totalQuizzesRealizados,
      'promedioPuntajeQuiz': promedioPuntajeQuiz,
      'rachaEstudio': rachaEstudio,
      'mejorRacha': mejorRacha,
      'ultimoDiaEstudio': ultimoDiaEstudio != null
          ? Timestamp.fromDate(ultimoDiaEstudio!)
          : null,
      'tiempoEstudioMinutos': tiempoEstudioMinutos,
      'totalPreguntasChat': totalPreguntasChat,
    };
  }

  // Crear desde documento de Firestore
  factory UserStatistics.fromFirestore(Map<String, dynamic> data) {
    return UserStatistics(
      totalSubtemasCompletados: data['totalSubtemasCompletados'] ?? 0,
      totalQuizzesAprobados: data['totalQuizzesAprobados'] ?? 0,
      totalQuizzesRealizados: data['totalQuizzesRealizados'] ?? 0,
      promedioPuntajeQuiz: (data['promedioPuntajeQuiz'] ?? 0.0).toDouble(),
      rachaEstudio: data['rachaEstudio'] ?? 0,
      mejorRacha: data['mejorRacha'] ?? 0,
      ultimoDiaEstudio: (data['ultimoDiaEstudio'] as Timestamp?)?.toDate(),
      tiempoEstudioMinutos: data['tiempoEstudioMinutos'] ?? 0,
      totalPreguntasChat: data['totalPreguntasChat'] ?? 0,
    );
  }

  // Crear copia con cambios
  UserStatistics copyWith({
    int? totalSubtemasCompletados,
    int? totalQuizzesAprobados,
    int? totalQuizzesRealizados,
    double? promedioPuntajeQuiz,
    int? rachaEstudio,
    int? mejorRacha,
    DateTime? ultimoDiaEstudio,
    int? tiempoEstudioMinutos,
    int? totalPreguntasChat,
  }) {
    return UserStatistics(
      totalSubtemasCompletados: totalSubtemasCompletados ?? this.totalSubtemasCompletados,
      totalQuizzesAprobados: totalQuizzesAprobados ?? this.totalQuizzesAprobados,
      totalQuizzesRealizados: totalQuizzesRealizados ?? this.totalQuizzesRealizados,
      promedioPuntajeQuiz: promedioPuntajeQuiz ?? this.promedioPuntajeQuiz,
      rachaEstudio: rachaEstudio ?? this.rachaEstudio,
      mejorRacha: mejorRacha ?? this.mejorRacha,
      ultimoDiaEstudio: ultimoDiaEstudio ?? this.ultimoDiaEstudio,
      tiempoEstudioMinutos: tiempoEstudioMinutos ?? this.tiempoEstudioMinutos,
      totalPreguntasChat: totalPreguntasChat ?? this.totalPreguntasChat,
    );
  }
}
