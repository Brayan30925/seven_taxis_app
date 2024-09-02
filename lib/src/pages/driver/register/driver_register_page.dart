import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:seven_taxis_app/src/utils/colors.dart' as utils;
import 'package:seven_taxis_app/src/utils/otp_widget.dart';
import 'package:seven_taxis_app/src/widgets/buttom_app.dart';
import 'package:seven_taxis_app/src/pages/driver/register/driver_register_controller.dart';
class DriverRegisterPage extends StatefulWidget {
  const DriverRegisterPage({super.key});

  @override
  State<DriverRegisterPage> createState() => Driver_RegisterPageState();
}

class Driver_RegisterPageState extends State<DriverRegisterPage> {
  final DriverRegisterController _con = DriverRegisterController();

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
            _textLogin(),
            _textLicencePlate(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 25),
              child: OTPFields(
                pin1: _con.pin1Controller,
                pin2: _con.pin2Controller,
                pin3: _con.pin3Controller,
                pin4: _con.pin4Controller,
                pin5: _con.pin5Controller,
                pin6: _con.pin6Controller,
              ),
            ),
            _textFildUsername(),
            _textFildEmail(),
            _textFildPassword(),
            _textFildConfirmPassword(),
            _buttonRegister(),
          ],
        ),
      ),
    );
  }



  Widget _buttonRegister() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
        onPressed: _con.register,
        text: 'Registrar Ahora', // Corrección de error tipográfico
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
  Widget _textFildUsername() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
      child: TextField(
        controller: _con.usernameController,
        decoration: InputDecoration(
          hintText: 'Pepito Perez',
          labelText: 'Nombre De Usuario',
          suffixIcon: Icon(
            Icons.person_outlined,
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
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 18),
          suffixIcon: Icon(
            Icons.lock_open_outlined,
            color: utils.Colors.seven,
          ),
        ),
      ),
    );
  }
  Widget _textFildConfirmPassword() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: TextField(
        obscureText: true,
        controller: _con.confirmPasswordController,
        decoration: InputDecoration(
          labelText: 'Confirmar Contraseña',
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 18),
          suffixIcon: Icon(
            Icons.lock_open_outlined,
            color: utils.Colors.seven,
          ),
        ),
      ),
    );
  }
  Widget _textLicencePlate(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        'Placa Del Vehiculo',
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 17
        ),
      ),
    );
  }

  Widget _textLogin() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
      child: const Text(
        'REGISTRO ',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
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
