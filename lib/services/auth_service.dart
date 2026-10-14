import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthSignInException implements Exception {
  final String message;

  const AuthSignInException(this.message);
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('[AuthService] signInWithGoogle error: $e');
      if (e is PlatformException &&
          e.code == 'sign_in_failed' &&
          (e.message?.contains('ApiException: 10') ?? false)) {
        throw const AuthSignInException(
          'El acceso con Google no está configurado para esta versión de la app. '
          'Contacta al administrador.',
        );
      }
      if (e is FirebaseAuthException && e.code == 'network-request-failed') {
        throw const AuthSignInException(
          'No se pudo conectar con Firebase. Revisa tu conexión a Internet.',
        );
      }
      throw const AuthSignInException(
        'No se pudo iniciar sesión con Google. Inténtalo de nuevo.',
      );
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
