import 'package:flutter/material.dart';

class LoginController {
  late BuildContext context; // Usa 'late' para indicar que se inicializará más tarde.

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Cambia el retorno a void ya que no hay nada asincrónico aquí.
  void init(BuildContext context) {
    this.context = context;
  }

  // Método para limpiar los controladores cuando el controlador se destruya.
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  void login() {
    String email = emailController.text;
    String password = passwordController.text;

    print('email: $email');
    print('pass: $password');

    // Aquí puedes añadir la lógica para el login, como la validación de credenciales.
  }
}
