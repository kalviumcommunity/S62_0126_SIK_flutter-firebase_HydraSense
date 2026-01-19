import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  /// LOGIN
  Future<bool> login(String email, String password) async {
    final user = await _authService.login(
      email.trim(),
      password.trim(),
    );

    return user != null;
  }

  /// SIGN UP
  Future<bool> signup(String email, String password) async {
    final user = await _authService.signUp(
      email.trim(),
      password.trim(),
    );

    if (user == null) {
      return false;
    }

    try {
      // ✅ ensure Firestore user is created
      await _firestoreService.createUser(
        user.uid,
        email.trim(),
      );
      return true;
    } catch (e) {
      // ❌ rollback auth if Firestore fails (important!)
      await _authService.logout();
      return false;
    }
  }
}
