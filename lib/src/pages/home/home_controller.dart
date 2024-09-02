import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/utils/shared_pref.dart';

class HomeController {
  late BuildContext context;
  late SharedPref _sharedPref;

  Future<void> init(BuildContext context) async {
    this.context = context;
    _sharedPref = SharedPref();
  }
  void goToLoginPage(String typeUser) {
    saveTypeUser(typeUser);
    Navigator.pushNamed(context, 'login');
  }

  Future<void> saveTypeUser(String typeUser) async {
    await _sharedPref.save('typeUser', typeUser);

  }



}
