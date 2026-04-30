import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';

class FirebaseAuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({firebase_auth.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  Stream<firebase_auth.User?> get user => _firebaseAuth.authStateChanges();

  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      );
    }
    return null;
  }

  Future<AppUser?> signInWithGoogle() async {
    // In a real implementation you would use GoogleSignIn to get the credential
    // and then sign in with _firebaseAuth.signInWithCredential(credential)
    // For now we will return an unimplemented error to prompt the user or just mock it temporarily
    // if the GoogleSignIn flow is not fully requested yet.
    throw UnimplementedError(
      'Google Sign-In is not fully implemented in data source yet. Use GoogleSignIn package.',
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
