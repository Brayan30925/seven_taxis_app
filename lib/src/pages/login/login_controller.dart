import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart'; // Asegúrate de que el import sea correcto.

class LoginController {
  late BuildContext context; // Usa 'late' para indicar que se inicializará más tarde.

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late MyAuthProvider _authProvider;

  Future<void> init(BuildContext context) async {
    this.context = context;
    _authProvider = MyAuthProvider();
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print('email: $email');
    print('pass: $password');

    try {
      bool isLogin = await _authProvider.login(email, password);
      if (isLogin) {
        print("El usuario está logueado");
        // Aquí puedes redirigir al usuario a la página principal o mostrar un mensaje.
        // Navigator.pushReplacementNamed(context, 'home'); // Ejemplo de navegación
      } else {
        print("No está logueado");
      }
    } catch (error) {
      print("Error: $error");
      // Aquí puedes mostrar un mensaje de error al usuario.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error al iniciar sesión: $error')),
      // );
    }
  }
}
