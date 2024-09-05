import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/utils/colors.dart' as utils;

class ButtonApp extends StatelessWidget {
  final Color color;
  final String text;
  final Color textColor;
  final IconData icon;
  final Color iconBackgroundColor;
  final VoidCallback onPressed; // Cambia Function a VoidCallback y hazlo requerido

  const ButtonApp({
    Key? key,
    required this.color,
    required this.text,
    required this.textColor,
    required this.onPressed, // Requiere que onPressed sea proporcionado
    this.icon = Icons.arrow_forward_ios,
    this.iconBackgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Usa onPressed directamente
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            right: -8, // Ajusta la distancia del ícono desde el borde derecho
            top: 0,
            bottom: 4,
            child: Container(
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4.0), // Ajusta el padding alrededor del ícono
              child: Icon(
                icon,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
