import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/utils/colors.dart' as utils;

class Snackbar {
  static void showSnackbar(BuildContext context, String text) {
    if (context == null) return; // Verificación de contexto nulo.

    // Esto elimina el enfoque de cualquier campo de texto.
    FocusScope.of(context).requestFocus(FocusNode());

    // Elimina el Snackbar actual (si lo hay).
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    // Muestra un nuevo Snackbar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
