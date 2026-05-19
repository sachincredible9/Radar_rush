import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import '../service_locator.dart';
import 'persistence_service.dart';

class AuthService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }
  
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth?.currentUser;
  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? const Stream<User?>.empty();

  Future<User?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      debugPrint('Google Sign-In failed: Firebase Auth is unavailable.');
      return null;
    }
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<User?> signInWithApple() async {
    final auth = _auth;
    if (auth == null) {
      debugPrint('Apple Sign-In failed: Firebase Auth is unavailable.');
      return null;
    }
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');
      final UserCredential userCredential = await auth.signInWithProvider(appleProvider);
      return userCredential.user;
    } catch (e) {
      debugPrint('Error during Apple Sign-In: $e');
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      debugPrint('Email Sign-In failed: Firebase Auth is unavailable.');
      return null;
    }
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Error during Email Sign-In: $e');
      rethrow;
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      debugPrint('Email Registration failed: Firebase Auth is unavailable.');
      return null;
    }
    try {
      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Error during Email Registration: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await getIt<PersistenceService>().clearSavedCredentials();
      await _auth?.currentUser?.delete();
      await signOut();
    } catch (e) {
      debugPrint('Error during Account Deletion: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (_) {}
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
  }
}
