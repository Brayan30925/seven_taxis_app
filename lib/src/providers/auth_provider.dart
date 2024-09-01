import 'package:firebase_auth/firebase_auth.dart';

class MyAuthProvider {
  final FirebaseAuth _firebaseAuth;

  MyAuthProvider() : _firebaseAuth = FirebaseAuth.instance;

  Future<bool> login(String email, String password) async {
    String? errorMessage;

    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      print(error);
      errorMessage = (error as FirebaseAuthException).code;
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }

    return true;
  }
}
