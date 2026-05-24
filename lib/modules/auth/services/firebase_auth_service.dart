import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

  FirebaseAuthService._unavailable();

  FirebaseAuthService() {
    try {
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
    } catch (_) {}
  }

  bool get _isAvailable => _auth != null && _googleSignIn != null;

  Future<User?> signInWithGoogle() async {
    if (!_isAvailable) return null;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth!.signInWithCredential(credential);
      return userCredential.user;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    if (!_isAvailable) return;
    try {
      await _googleSignIn!.signIn();
      await _auth!.signOut();
    } catch (_) {}
  }

  bool isSignedIn() {
    if (!_isAvailable) return false;
    try {
      return _auth!.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  String? getUserEmail() {
    if (!_isAvailable) return null;
    try {
      return _auth!.currentUser?.email;
    } catch (_) {
      return null;
    }
  }
}

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  try {
    return FirebaseAuthService();
  } catch (_) {
    return FirebaseAuthService._unavailable();
  }
});
