import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String nombre;
  final String descripcion;
  final IconData icono;
  final Color color;
  final int puntos;
  final bool desbloqueado;
  final DateTime? desbloqueadoEn;

  const Achievement({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.puntos,
    required this.desbloqueado,
    this.desbloqueadoEn,
  });

  // Convertir a Map para Firestore (solo datos del logro desbloqueado)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'puntos': puntos,
      'desbloqueadoEn': desbloqueadoEn != null
          ? Timestamp.fromDate(desbloqueadoEn!)
          : Timestamp.now(),
    };
  }

  // Crear logro desbloqueado desde Firestore
  factory Achievement.fromFirestore(Map<String, dynamic> data) {
    final definition = AchievementDefinitions.getById(data['id'] ?? '');
    return Achievement(
      id: data['id'] ?? '',
      nombre: definition?.nombre ?? data['nombre'] ?? '',
      descripcion: definition?.descripcion ?? data['descripcion'] ?? '',
      icono: definition?.icono ?? Icons.star,
      color: definition?.color ?? Colors.amber,
      puntos: data['puntos'] ?? 0,
      desbloqueado: true,
      desbloqueadoEn: (data['desbloqueadoEn'] as Timestamp?)?.toDate(),
    );
  }

  // Crear copia desbloqueada
  Achievement unlock() {
    return Achievement(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      icono: icono,
      color: color,
      puntos: puntos,
      desbloqueado: true,
      desbloqueadoEn: DateTime.now(),
    );
  }
}

// Definiciones de todos los logros disponibles
class AchievementDefinitions {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_quiz',
      nombre: 'Primer Paso',
      descripcion: 'Completa tu primer quiz',
      icono: Icons.play_circle_filled,
      color: Color(0xFF4CAF50),
      puntos: 50,
      desbloqueado: false,
    ),
    Achievement(
      id: 'perfect_score',
      nombre: 'Perfeccion',
      descripcion: 'Obtiene 100% en un quiz',
      icono: Icons.star,
      color: Color(0xFFFFD700),
      puntos: 100,
      desbloqueado: false,
    ),
    Achievement(
      id: 'all_subtemas',
      nombre: 'Explorador',
      descripcion: 'Completa todos los subtemas de una unidad',
      icono: Icons.explore,
      color: Color(0xFF2196F3),
      puntos: 200,
      desbloqueado: false,
    ),
    Achievement(
      id: 'study_streak_3',
      nombre: 'Constante',
      descripcion: 'Estudia 3 dias seguidos',
      icono: Icons.local_fire_department,
      color: Color(0xFFFF5722),
      puntos: 75,
      desbloqueado: false,
    ),
    Achievement(
      id: 'chat_master',
      nombre: 'Curioso',
      descripcion: 'Haz 10 preguntas al chatbot',
      icono: Icons.chat_bubble,
      color: Color(0xFF9C27B0),
      puntos: 50,
      desbloqueado: false,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // Obtener lista con estado de desbloqueo actualizado
  static List<Achievement> withUnlocked(List<Achievement> unlockedList) {
    final unlockedIds = unlockedList.map((a) => a.id).toSet();
    return all.map((achievement) {
      if (unlockedIds.contains(achievement.id)) {
        final unlocked = unlockedList.firstWhere((a) => a.id == achievement.id);
        return Achievement(
          id: achievement.id,
          nombre: achievement.nombre,
          descripcion: achievement.descripcion,
          icono: achievement.icono,
          color: achievement.color,
          puntos: achievement.puntos,
          desbloqueado: true,
          desbloqueadoEn: unlocked.desbloqueadoEn,
        );
      }
      return achievement;
    }).toList();
  }
}
