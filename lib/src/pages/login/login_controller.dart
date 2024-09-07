import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/utils/shared_pref.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;

import '../../models/driver.dart';
import '../../utils/my_progress_dialog.dart';

class LoginController {
  late BuildContext context;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late MyAuthProvider _authProvider;
  late ProgressDialog _progressDialog;
  late DriverProvider _driverProvider;
  late ClientProvider _clientProvider;
  late SharedPref _sharedPref;
  late String _typeUser;


  Future<void> init(BuildContext context) async {
    this.context = context;
    _authProvider = MyAuthProvider();
    _clientProvider =ClientProvider();
    _driverProvider = DriverProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere Un Momento...');
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
  void login()async{
    String email= emailController.text.trim();
    String pass= passwordController.text.trim();
    print('este es email $email y este es paass $pass');
    var resul = await _authProvider.loginConPass(email,pass);

    print('este es el resultado de inicio de sesion $resul');
    if(resul==null){

      utils.Snackbar.showSnackbar(context,'usuario o contraseña incorrectos');
    }
    else if (resul != null){
      if(_typeUser=='client'){
        String collectionName = 'clients';
        String userId = resul;
        bool exists = await _authProvider.existsInCollection(collectionName, userId);
        print('miramos si existe en la coleccion $exists');
        if(exists){
          Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route)=> false);
        }else{
          utils.Snackbar.showSnackbar(context,'error no tienes permisos ');
          _authProvider.signOut();
        }
      }else if(_typeUser == 'driver'){
        String collectionName = 'Drivers';
        String userId = resul;
        bool exists = await _authProvider.existsInCollection(collectionName, userId);
        print('miramos si existe en la coleccion $exists');
        if(exists){
          Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route)=> false);
        }else{
          utils.Snackbar.showSnackbar(context,'error no tienes permisos ');
          _authProvider.signOut();
        }
      }


    }
  }

}
