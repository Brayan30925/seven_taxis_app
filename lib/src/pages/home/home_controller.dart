import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/utils/shared_pref.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';

class HomeController {
  late BuildContext context;
  late SharedPref _sharedPref;
  late MyAuthProvider _authProvider;
  late String _typeUser;
  late String isNotification;


  Future<void> init(BuildContext context) async {
    this.context = context;
    _sharedPref = SharedPref();
    _authProvider = MyAuthProvider();
    isNotification = await _sharedPref.read('isNotification') ?? 'false' ;


    // Verifica si es necesario chequear si el usuario está logueado
    if (await _shouldCheckUserLogged()) {
      // Asegura que typeUser no sea null
      _typeUser = await _sharedPref.read('typeUser') ?? ''; // Proporciónalo con un valor predeterminado
      _authProvider.checkIfUserIsLogged(context, _typeUser,isNotification);


    }
  }


  Future<bool> _shouldCheckUserLogged() async {
    // Aquí decides si realmente necesitas verificar si el usuario está logueado
    // Podrías usar una lógica adicional para determinar si la app recién se inicia
    // Por ahora devuelve true siempre que se necesite la verificación
    // Cambia esta lógica según lo que necesites
    return true;
  }

  void goToLoginPage(String typeUser) {
    saveTypeUser(typeUser);
    Navigator.pushNamed(context, 'login');
  }

  Future<void> saveTypeUser(String typeUser) async {
    await _sharedPref.save('typeUser', typeUser);
  }
}
