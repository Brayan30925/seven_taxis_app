import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:seven_taxis_app/src/models/driver.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/utils/my_progress_dialog.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;

class DriverRegisterController {
  late BuildContext context; // Usa 'late' para indicar que se inicializará más tarde.

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  TextEditingController pin1Controller = TextEditingController();
  TextEditingController pin2Controller = TextEditingController();
  TextEditingController pin3Controller = TextEditingController();
  TextEditingController pin4Controller = TextEditingController();
  TextEditingController pin5Controller = TextEditingController();
  TextEditingController pin6Controller = TextEditingController();

  late MyAuthProvider _authProvider;
  late ProgressDialog _progressDialog;
  late DriverProvider _driverProvider;

  Future<void> init(BuildContext context) async {
    this.context = context;
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();
    _progressDialog= MyProgressDialog.createProgressDialog(context, 'Espere Un Momento...');
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

    String pin1 = pin1Controller.text.trim();
    String pin2 = pin2Controller.text.trim();
    String pin3 = pin3Controller.text.trim();
    String pin4 = pin4Controller.text.trim();
    String pin5 = pin5Controller.text.trim();
    String pin6 = pin6Controller.text.trim();

    String plate= '$pin1$pin2$pin3-$pin4$pin5$pin6';

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
          Driver driver = Driver(
            id: user.uid,
            email: user.email ?? '', // Asegúrate de proporcionar un valor predeterminado si user.email es null
            username: username,
            password: password,
            plate: plate
          );
          await _driverProvider.create(driver);
          _progressDialog.hide();
          Navigator.pushNamedAndRemoveUntil(context, 'driver/map',(route)=>false);

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
