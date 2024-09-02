import 'package:flutter/material.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/utils/shared_pref.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;

import '../../utils/my_progress_dialog.dart';

class LoginController {
  late BuildContext context;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late MyAuthProvider _authProvider;
  late ProgressDialog _progressDialog;
  late SharedPref _sharedPref;
  late String _typeUser;

  Future<void> init(BuildContext context) async {
    this.context = context;
    _authProvider = MyAuthProvider();
    _progressDialog = MyProgressDialog.createprogressDialog(context, 'Espere Un Momento...');
    _sharedPref = SharedPref();
    _typeUser= await _sharedPref.read('typeUser');
    
    print("************tipo de usuario***********");
    print(_typeUser);
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  void goToRegisterPage() {
    if (_typeUser == 'client') {
      Navigator.pushNamed(context, 'client/register');
    }
    else {
      Navigator.pushNamed(context, 'driver/register');
    }
  }
  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    _progressDialog.show();
    print('email: $email');
    print('pass: $password');

    try {
      bool isLogin = await _authProvider.login(email, password);
      if (isLogin) {
        utils.Snackbar.showSnackbar(context, 'El usuario está logueado');
        // Aquí puedes redirigir al usuario a la página principal o mostrar un mensaje.
        // Navigator.pushReplacementNamed(context, 'home'); // Ejemplo de navegación
      } else {
        utils.Snackbar.showSnackbar(context, 'Error no está logueado');
      }
    } catch (error) {
      print("Error: $error");
      utils.Snackbar.showSnackbar(context, 'Error al iniciar sesión: $error');
    } finally {
      _progressDialog.hide(); // Asegura que el diálogo se oculte siempre.
    }
  }
}
