import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:seven_taxis_app/src/pages/home/home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  HomeController _con = new HomeController();

  @override
  Widget build(BuildContext context) {
    _con.init(context);
    return Scaffold(
        body: SafeArea(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.yellow, Colors.green])),
        child: Column(
          children: [
            _bannerApp(context),
            SizedBox(height: 50),
            _textSeleccionaRol('SELECCIONA TU ROL'),
            SizedBox(height: 50),
            _imageTypeUser(context,'assets/img/pasajero.png','client'),
            SizedBox(height: 10),
            _textTypeuser('CLIENTE'),
            SizedBox(height: 50),
            _imageTypeUser(context,'assets/img/driver.png','driver'),
            SizedBox(height: 10),
            _textTypeuser('CONDUCTOR')
          ],
        ),
      ),
    ));
  }

  Widget _bannerApp(BuildContext context) {
    return ClipPath(
      clipper: DiagonalPathClipperTwo(),
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/img/logo_app.jpg',
              width: 150,
              height: 100,
            ),
            Text(
              'Agil Y Seguro \nAl Alcance \nDe Tu Mano',
              style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            )

          ],
        ),
      ),
    );
  }

  Widget _textSeleccionaRol(String rol) {
    return Text(
      rol,
      style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'OneDay'),
    );
  }

  Widget _imageTypeUser(BuildContext context, String image,String typeuser) {
    return GestureDetector(
      onTap:()=>_con.goToLoginPage(typeuser),
      child: CircleAvatar(
        backgroundImage: AssetImage(image),
        radius: 50,
        backgroundColor: Colors.black,
      ),
    );
  }

  Widget _textTypeuser(String typeUser) {
    return Text(
      typeUser,
      style: TextStyle(color: Colors.white, fontSize: 16),
    );
  }

}
