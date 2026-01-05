import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    // 🔥 CRITICAL FOR FLUTTER WEB
    _auth.setPersistence(Persistence.NONE);
  }

  Future<User?> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print('SIGNUP ERROR: $e');
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print('LOGIN ERROR: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
