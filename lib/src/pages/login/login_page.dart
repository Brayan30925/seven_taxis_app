import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:seven_taxis_app/src/pages/login/login_controller.dart';
import 'package:seven_taxis_app/src/utils/colors.dart' as utils;
import 'package:seven_taxis_app/src/widgets/buttom_app.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _con = LoginController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });
  }

  @override
  void dispose() {
    // Asegúrate de limpiar los controladores cuando el widget se destruya.
    _con.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _bannerApp(),
            _textDescripcion(),
            _textLogin(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.11),
            _textFildEmail(),
            _textFildPassword(),
            _buttonLogin(),
            _textDontHaveAccount(),
          ],
        ),
      ),
    );
  }

  Widget _textDontHaveAccount() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: const Text(
        'No Tienes Cuenta?',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buttonLogin() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
        onPressed: _con.login,
        text: 'Iniciar Sesión', // Corrección de error tipográfico
        color: utils.Colors.seven,
        textColor: Colors.white,
      ),
    );
  }

  Widget _textFildEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _con.emailController,
        decoration: InputDecoration(
          hintText: 'Correo@gmail.com',
          labelText: 'Correo Electrónico',
          suffixIcon: Icon(
            Icons.email_outlined,
            color: utils.Colors.seven,
          ),
        ),
      ),
    );
  }

  Widget _textFildPassword() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: TextField(
        obscureText: true,
        controller: _con.passwordController,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 23),
          suffixIcon: Icon(
            Icons.lock_open_outlined,
            color: utils.Colors.seven,
          ),
        ),
      ),
    );
  }

  Widget _textLogin() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: const Text(
        'Login',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
      ),
    );
  }

  Widget _textDescripcion() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: const Text(
        'Continua Con Tu ',
        style: TextStyle(color: Colors.black54, fontSize: 24, fontFamily: 'NinbusSans'),
      ),
    );
  }

  Widget _bannerApp() {
    return ClipPath(
      clipper: WaveClipperTwo(),
      child: Container(
        color: utils.Colors.seven,
        height: MediaQuery.of(context).size.height * 0.22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/img/logo_app.jpg',
              width: 150,
              height: 100,
            ),
            const Text(
              'Agil Y Seguro \nAl Alcance \nDe Tu Mano',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
