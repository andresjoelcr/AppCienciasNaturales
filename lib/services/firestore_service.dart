import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';
import '../models/user_progress_model.dart';
import '../models/achievement_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentSessionId;

  String? get currentUserId => _auth.currentUser?.uid;

  // Crear nueva sesion de chat
  Future<String?> createChatSession() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final docRef = await _firestore.collection('chat_sessions').add({
        'userId': userId,
        'userEmail': _auth.currentUser?.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'messageCount': 0,
      });

      _currentSessionId = docRef.id;
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Guardar mensaje en la sesion actual
  Future<void> saveMessage({
    required String userMessage,
    required String botResponse,
    String? sessionId,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final activeSessionId = sessionId ?? _currentSessionId;

      if (activeSessionId == null) {
        await createChatSession();
      }

      final finalSessionId = sessionId ?? _currentSessionId;
      if (finalSessionId == null) return;

      // Guardar el mensaje
      await _firestore
          .collection('chat_sessions')
          .doc(finalSessionId)
          .collection('messages')
          .add({
        'userMessage': userMessage,
        'botResponse': botResponse,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Actualizar la sesion
      await _firestore.collection('chat_sessions').doc(finalSessionId).update({
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': userMessage.length > 50
            ? '${userMessage.substring(0, 50)}...'
            : userMessage,
        'messageCount': FieldValue.increment(1),
      });

    } catch (e) {
      debugPrint('[FirestoreService] saveMessage error: $e');
    }
  }

  // Obtener todas las sesiones del usuario
  Stream<QuerySnapshot> getChatSessions() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _firestore
        .collection('chat_sessions')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Obtener mensajes de una sesion especifica
  Stream<QuerySnapshot> getSessionMessages(String sessionId) {
    return _firestore
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Obtener mensajes de una sesion (una sola vez)
  Future<List<Map<String, dynamic>>> getSessionMessagesOnce(String sessionId) async {
    try {
      final snapshot = await _firestore
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // Eliminar una sesion de chat
  Future<void> deleteChatSession(String sessionId) async {
    try {
      // Eliminar todos los mensajes de la sesion
      final messages = await _firestore
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }

      // Eliminar la sesion
      await _firestore.collection('chat_sessions').doc(sessionId).delete();
    } catch (e) {
      debugPrint('[FirestoreService] deleteChatSession error: $e');
    }
  }

  // Establecer sesion actual
  void setCurrentSession(String? sessionId) {
    _currentSessionId = sessionId;
  }

  // Obtener sesion actual
  String? get currentSessionId => _currentSessionId;

  // Limpiar sesion actual (para nuevo chat)
  void clearCurrentSession() {
    _currentSessionId = null;
  }

  // ==================== PERFIL DE USUARIO ====================

  // Crear o obtener perfil de usuario
  Future<UserProfile?> getOrCreateUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        return UserProfile.fromFirestore(user.uid, doc.data()!);
      } else {
        // Crear perfil inicial
        final profile = UserProfile.initial(
          odlUserId: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Usuario',
          photoURL: user.photoURL,
        );
        await docRef.set(profile.toFirestore());
        return profile;
      }
    } catch (e) {
      debugPrint('[FirestoreService] getOrCreateUserProfile error: $e');
      return null;
    }
  }

  // Obtener perfil de usuario
  Future<UserProfile?> getUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(userId, doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('[FirestoreService] getUserProfile error: $e');
      return null;
    }
  }

  // Stream del perfil de usuario
  Stream<UserProfile?> getUserProfileStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists
            ? UserProfile.fromFirestore(userId, doc.data()!)
            : null);
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      debugPrint('[FirestoreService] updateUserProfile error: $e');
    }
  }

  // ==================== PROGRESO ====================

  // Guardar progreso de un subtema
  Future<void> saveSubtemaProgress(UserProgress progress) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(progress.subtemaId)
          .set(progress.toFirestore());
    } catch (e) {
      debugPrint('[FirestoreService] saveSubtemaProgress error: $e');
    }
  }

  // Obtener progreso de un subtema
  Future<UserProgress?> getSubtemaProgress(String subtemaId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(subtemaId)
          .get();

      if (doc.exists) {
        return UserProgress.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('[FirestoreService] getSubtemaProgress error: $e');
      return null;
    }
  }

  // Obtener todo el progreso del usuario
  Future<List<UserProgress>> getAllProgress() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .get();

      return snapshot.docs
          .map((doc) => UserProgress.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[FirestoreService] getAllProgress error: $e');
      return [];
    }
  }

  // Marcar contenido como visto
  Future<void> markContenidoVisto(String subtemaId, String subtemaTitulo) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(subtemaId);

      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'contenidoVisto': true,
          'ultimoAcceso': FieldValue.serverTimestamp(),
        });
      } else {
        final progress = UserProgress.initial(
          subtemaId: subtemaId,
          subtemaTitulo: subtemaTitulo,
        ).copyWith(contenidoVisto: true);
        await docRef.set(progress.toFirestore());
      }

      // Actualizar racha de estudio
      await _updateStudyStreak();
    } catch (e) {
      debugPrint('[FirestoreService] markContenidoVisto error: $e');
    }
  }

  // Guardar resultado de quiz
  Future<Map<String, dynamic>> saveQuizResult({
    required String subtemaId,
    required String subtemaTitulo,
    required int score,
    required int totalPreguntas,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {'success': false};

      final porcentaje = ((score / totalPreguntas) * 100).round();
      final aprobado = porcentaje >= 60;

      // Actualizar progreso del subtema
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(subtemaId);

      final doc = await docRef.get();
      int intentos = 1;

      if (doc.exists) {
        final current = UserProgress.fromFirestore(doc.data()!);
        intentos = current.intentos + 1;

        // Solo actualizar si es mejor score o primer intento
        if (porcentaje > current.quizScore || current.quizScore == 0) {
          await docRef.update({
            'quizCompletado': true,
            'quizAprobado': aprobado,
            'quizScore': porcentaje,
            'intentos': intentos,
            'fechaCompletado': aprobado ? FieldValue.serverTimestamp() : null,
            'ultimoAcceso': FieldValue.serverTimestamp(),
          });
        } else {
          await docRef.update({
            'intentos': intentos,
            'ultimoAcceso': FieldValue.serverTimestamp(),
          });
        }
      } else {
        final progress = UserProgress(
          subtemaId: subtemaId,
          subtemaTitulo: subtemaTitulo,
          contenidoVisto: true,
          quizCompletado: true,
          quizAprobado: aprobado,
          quizScore: porcentaje,
          intentos: 1,
          fechaCompletado: aprobado ? DateTime.now() : null,
          ultimoAcceso: DateTime.now(),
        );
        await docRef.set(progress.toFirestore());
      }

      // Calcular XP ganado
      int xpGanado = _calculateXP(porcentaje);

      // Actualizar estadísticas y XP
      await _updateStatsAfterQuiz(porcentaje, aprobado, xpGanado);

      // Verificar logros
      List<Achievement> nuevosLogros = await _checkAchievements(
        quizScore: porcentaje,
        isFirstQuiz: intentos == 1,
      );

      return {
        'success': true,
        'porcentaje': porcentaje,
        'aprobado': aprobado,
        'xpGanado': xpGanado,
        'nuevosLogros': nuevosLogros,
      };
    } catch (e) {
      debugPrint('[FirestoreService] saveQuizResult error: $e');
      return {'success': false};
    }
  }

  // Calcular XP basado en puntaje
  int _calculateXP(int porcentaje) {
    if (porcentaje == 100) return 50;
    if (porcentaje >= 80) return 35;
    if (porcentaje >= 60) return 20;
    return 10;
  }

  // Actualizar estadísticas después de quiz
  Future<void> _updateStatsAfterQuiz(int porcentaje, bool aprobado, int xp) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final userDoc = _firestore.collection('users').doc(userId);
      final doc = await userDoc.get();

      if (doc.exists) {
        final data = doc.data()!;
        final stats = data['statistics'] as Map<String, dynamic>? ?? {};

        int totalQuizzes = (stats['totalQuizzesRealizados'] ?? 0) + 1;
        int quizzesAprobados = (stats['totalQuizzesAprobados'] ?? 0) + (aprobado ? 1 : 0);
        double promedioActual = (stats['promedioPuntajeQuiz'] ?? 0.0).toDouble();
        double nuevoPromedio = ((promedioActual * (totalQuizzes - 1)) + porcentaje) / totalQuizzes;

        int currentXP = data['experiencePoints'] ?? 0;
        int newXP = currentXP + xp;
        int currentLevel = data['level'] ?? 1;
        int xpParaNivel = currentLevel * 100;

        // Subir de nivel si corresponde
        while (newXP >= xpParaNivel) {
          newXP -= xpParaNivel;
          currentLevel++;
          xpParaNivel = currentLevel * 100;
        }

        await userDoc.update({
          'experiencePoints': newXP,
          'level': currentLevel,
          'totalPoints': FieldValue.increment(xp),
          'updatedAt': FieldValue.serverTimestamp(),
          'statistics.totalQuizzesRealizados': totalQuizzes,
          'statistics.totalQuizzesAprobados': quizzesAprobados,
          'statistics.promedioPuntajeQuiz': nuevoPromedio,
        });
      }
    } catch (e) {
      debugPrint('[FirestoreService] _updateStatsAfterQuiz error: $e');
    }
  }

  // Actualizar racha de estudio
  Future<void> _updateStudyStreak() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final userDoc = _firestore.collection('users').doc(userId);
      final doc = await userDoc.get();

      if (doc.exists) {
        final data = doc.data()!;
        final stats = data['statistics'] as Map<String, dynamic>? ?? {};

        final ultimoDia = (stats['ultimoDiaEstudio'] as Timestamp?)?.toDate();
        final hoy = DateTime.now();
        final hoyDate = DateTime(hoy.year, hoy.month, hoy.day);

        int rachaActual = stats['rachaEstudio'] ?? 0;
        int mejorRacha = stats['mejorRacha'] ?? 0;

        if (ultimoDia != null) {
          final ultimaDate = DateTime(ultimoDia.year, ultimoDia.month, ultimoDia.day);
          final diferencia = hoyDate.difference(ultimaDate).inDays;

          if (diferencia == 0) {
            // Mismo día, no hacer nada
            return;
          } else if (diferencia == 1) {
            // Día consecutivo
            rachaActual++;
          } else {
            // Se rompió la racha
            rachaActual = 1;
          }
        } else {
          rachaActual = 1;
        }

        if (rachaActual > mejorRacha) {
          mejorRacha = rachaActual;
        }

        await userDoc.update({
          'statistics.rachaEstudio': rachaActual,
          'statistics.mejorRacha': mejorRacha,
          'statistics.ultimoDiaEstudio': FieldValue.serverTimestamp(),
        });

        // Verificar logro de racha
        if (rachaActual >= 3) {
          await _unlockAchievementIfNew('study_streak_3');
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] _updateStudyStreak error: $e');
    }
  }

  // ==================== LOGROS ====================

  // Obtener logros del usuario
  Future<List<Achievement>> getUserAchievements() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[FirestoreService] getUserAchievements error: $e');
      return [];
    }
  }

  // Desbloquear logro
  Future<Achievement?> unlockAchievement(Achievement achievement) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievement.id);

      final doc = await docRef.get();
      if (doc.exists) return null; // Ya desbloqueado

      final unlocked = achievement.unlock();
      await docRef.set(unlocked.toFirestore());

      // Agregar puntos al usuario
      await _firestore.collection('users').doc(userId).update({
        'totalPoints': FieldValue.increment(achievement.puntos),
      });

      return unlocked;
    } catch (e) {
      debugPrint('[FirestoreService] unlockAchievement error: $e');
      return null;
    }
  }

  // Desbloquear logro si es nuevo (por ID)
  Future<Achievement?> _unlockAchievementIfNew(String achievementId) async {
    final achievement = AchievementDefinitions.getById(achievementId);
    if (achievement == null) return null;
    return await unlockAchievement(achievement);
  }

  // Verificar logros después de acciones
  Future<List<Achievement>> _checkAchievements({
    int? quizScore,
    bool isFirstQuiz = false,
  }) async {
    List<Achievement> nuevos = [];

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return nuevos;

      // Primer quiz
      if (isFirstQuiz) {
        final a = await _unlockAchievementIfNew('first_quiz');
        if (a != null) nuevos.add(a);
      }

      // Puntaje perfecto
      if (quizScore == 100) {
        final a = await _unlockAchievementIfNew('perfect_score');
        if (a != null) nuevos.add(a);
      }

      // Verificar si completó todos los subtemas
      final progress = await getAllProgress();
      final completados = progress.where((p) => p.completado).length;
      if (completados >= 4) { // 4 subtemas en la unidad
        final a = await _unlockAchievementIfNew('all_subtemas');
        if (a != null) nuevos.add(a);
      }
    } catch (e) {
      debugPrint('[FirestoreService] _checkAchievements error: $e');
    }

    return nuevos;
  }

  // Incrementar contador de preguntas del chat
  Future<void> incrementChatQuestions() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update({
        'statistics.totalPreguntasChat': FieldValue.increment(1),
      });

      // Verificar logro de chat
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final stats = doc.data()?['statistics'] as Map<String, dynamic>? ?? {};
        final total = stats['totalPreguntasChat'] ?? 0;
        if (total >= 10) {
          await _unlockAchievementIfNew('chat_master');
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] incrementChatQuestions error: $e');
    }
  }
}
