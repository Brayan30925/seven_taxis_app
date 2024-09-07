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
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Ajusta el padding para el botón
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del botón al contenido
        mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido horizontalmente
        children: [
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis, // Agrega puntos suspensivos si el texto es muy largo
            ),
          ),
          SizedBox(width: 8), // Espacio entre el texto y el ícono
          Container(
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(4.0), // Ajusta el padding alrededor del ícono
            child: Icon(
              icon,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

}
