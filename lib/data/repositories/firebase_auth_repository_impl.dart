import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final GoogleSignIn _googleSignIn;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    GoogleSignIn? googleSignIn,
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _authDataSource = authDataSource,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Future<AppUser?> getCurrentUser() async {
    return _authDataSource.currentUser;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final firebase_auth.OAuthCredential credential = firebase_auth
          .GoogleAuthProvider.credential(idToken: googleAuth.idToken);

      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        return AppUser(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _authDataSource.signOut();
  }
}
