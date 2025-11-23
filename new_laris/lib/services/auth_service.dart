import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/services.dart';
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

  Future<UserCredential> signInWithFacebook() async {
    if (kIsWeb) {
      final facebookProvider = FacebookAuthProvider();
      return _auth.signInWithPopup(facebookProvider);
    }

    try {
      final result = await FacebookAuth.instance
          .login(permissions: const ['email', 'public_profile']);

      if (result.status != LoginStatus.success || result.accessToken == null) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Login Facebook dibatalkan.',
        );
      }

      final credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      return _auth.signInWithCredential(credential);
    } on MissingPluginException {
      // Desktop platforms are not supported by flutter_facebook_auth.
      throw FirebaseAuthException(
        code: 'facebook-not-available',
        message: 'Login Facebook belum tersedia di platform ini.',
      );
    }
  }
}
