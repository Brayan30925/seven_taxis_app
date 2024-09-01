import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';

class RegisterController {
  late BuildContext context; // Usa 'late' para indicar que se inicializará más tarde.

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;

  Future<void> init(BuildContext context) async {
    this.context = context;
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();
  }

  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  void register() async {
    String email = emailController.text.trim();
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    print('email: $email');
    print('username: $username');
    print('password: $password');
    print('confirmPassword: $confirmPassword');

    if (email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      print('Hay campos vacíos');
      return;
    }

    if (password != confirmPassword) {
      print('Las contraseñas no coinciden');
      return;
    }

    if (password.length < 6) {
      print('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    try {
      bool isRegister = await _authProvider.register(email, password);
      if (isRegister) {
        User? user = _authProvider.getUser();
        if (user != null) {
          Client client = Client(
            id: user.uid,
            email: user.email ?? '', // Asegúrate de proporcionar un valor predeterminado si user.email es null
            username: username,
            password: password,
          );
          await _clientProvider.create(client);
          print("El usuario está registrado");
        } else {
          print("El usuario no está autenticado");
        }
      } else {
        print("No se pudo registrar el usuario");
      }
    } catch (error) {
      print("Error: $error");
      // Aquí puedes mostrar un mensaje de error al usuario.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error al registrar: $error')),
      // );
    }
  }
}
