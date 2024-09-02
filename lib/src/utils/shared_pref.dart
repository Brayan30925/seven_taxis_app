import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {
  Future<void> save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(value)); // Añadir await para asegurar que la operación se complete.
  }

  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);

    if (jsonString == null) {
      return null; // Retorna null si la clave no existe o el valor es null.
    }

    try {
      return json.decode(jsonString); // Decodifica solo si el valor no es null.
    } catch (e) {
      print("Error decoding JSON: $e");
      return null; // Retorna null en caso de error de decodificación.
    }
  }

  Future<bool> contains(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
