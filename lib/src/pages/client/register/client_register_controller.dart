import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';
import 'package:seven_taxis_app/src/utils/my_progress_dialog.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;

class ClientRegisterController {
  late BuildContext context; // Usa 'late' para indicar que se inicializará más tarde.

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;
  late ProgressDialog _progressDialog;

  Future<void> init(BuildContext context) async {
    this.context = context;
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();
    _progressDialog= MyProgressDialog.createprogressDialog(context, 'Espere Un Momento...');
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


    if (email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      print('Hay campos vacíos');
      utils.Snackbar.showSnackbar(context,'Hay campos vacíos');
      return;
    }

    if (password != confirmPassword) {
      print('Las contraseñas no coinciden');
      utils.Snackbar.showSnackbar(context,'Las contraseñas no coinciden');

      return;
    }

    if (password.length < 6) {
      print('La contraseña debe tener al menos 6 caracteres');
      utils.Snackbar.showSnackbar(context,'La contraseña debe tener al menos 6 caracteres');

      return;
    }
    _progressDialog.show();

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
          _progressDialog.hide();

          utils.Snackbar.showSnackbar(context,'usuario registrado...');
        } else {
          _progressDialog.hide();
          print("El usuario no está autenticado");
        }
      } else {
        _progressDialog.hide();
        print("No se pudo registrar el usuario");


      }
    } catch (error) {
      _progressDialog.hide();
      print("Error: $error");
      utils.Snackbar.showSnackbar(context,'Error $error');
      // Aquí puedes mostrar un mensaje de error al usuario.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error al registrar: $error')),
      // );
    }
  }
}
