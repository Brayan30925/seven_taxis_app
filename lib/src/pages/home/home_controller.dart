import 'package:flutter/material.dart';

class HomeController {
  late BuildContext context;
  Future<void> init(BuildContext context) async {
    this.context = context;
  }
  void goToLoginPage(){
    Navigator.pushNamed(context, 'login');
  }
}
