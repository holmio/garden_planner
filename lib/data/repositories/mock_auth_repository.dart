import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  bool _isSignedIn = false;

  @override
  Future<AppUser?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_isSignedIn) {
      return const AppUser(id: '123', email: 'gardener@example.com', displayName: 'Green Thumb');
    }
    return null;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    _isSignedIn = true;
    return const AppUser(id: '123', email: 'gardener@example.com', displayName: 'Green Thumb');
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isSignedIn = false;
  }
}
