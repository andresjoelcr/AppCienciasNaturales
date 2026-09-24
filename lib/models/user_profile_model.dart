import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_statistics_model.dart';

class UserProfile {
  final String odlUserId;
  final String email;
  final String displayName;
  final String? photoURL;
  final int totalPoints;
  final int level;
  final int experiencePoints;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserStatistics statistics;

  const UserProfile({
    required this.odlUserId,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.totalPoints,
    required this.level,
    required this.experiencePoints,
    required this.createdAt,
    required this.updatedAt,
    required this.statistics,
  });

  // XP necesario para subir de nivel (fórmula simple)
  int get xpParaSiguienteNivel => level * 100;

  // Porcentaje de progreso hacia el siguiente nivel
  double get progresoNivel => experiencePoints / xpParaSiguienteNivel;

  // Crear perfil inicial para nuevo usuario
  factory UserProfile.initial({
    required String odlUserId,
    required String email,
    required String displayName,
    String? photoURL,
  }) {
    final now = DateTime.now();
    return UserProfile(
      odlUserId: odlUserId,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      totalPoints: 0,
      level: 1,
      experiencePoints: 0,
      createdAt: now,
      updatedAt: now,
      statistics: UserStatistics.initial(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'totalPoints': totalPoints,
      'level': level,
      'experiencePoints': experiencePoints,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'statistics': statistics.toFirestore(),
    };
  }

  // Crear desde documento de Firestore
  factory UserProfile.fromFirestore(String odlUserId, Map<String, dynamic> data) {
    return UserProfile(
      odlUserId: odlUserId,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      totalPoints: data['totalPoints'] ?? 0,
      level: data['level'] ?? 1,
      experiencePoints: data['experiencePoints'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      statistics: data['statistics'] != null
          ? UserStatistics.fromFirestore(data['statistics'])
          : UserStatistics.initial(),
    );
  }

  // Crear copia con cambios
  UserProfile copyWith({
    String? email,
    String? displayName,
    String? photoURL,
    int? totalPoints,
    int? level,
    int? experiencePoints,
    DateTime? updatedAt,
    UserStatistics? statistics,
  }) {
    return UserProfile(
      odlUserId: odlUserId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      statistics: statistics ?? this.statistics,
    );
  }
}
