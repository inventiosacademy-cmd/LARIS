import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Central place for auth helper methods (Google sign-in, etc.).
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      return _auth.signInWithPopup(googleProvider);
    }

    final googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'aborted-by-user',
        message: 'Login dibatalkan.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }
}
