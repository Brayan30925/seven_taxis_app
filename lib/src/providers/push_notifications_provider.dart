import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/utils/shared_pref.dart';

// Scopes necesarios para la API de Google
const _scopes = ['https://www.googleapis.com/auth/cloud-platform'];

// Handler de mensajes en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Aquí puedes manejar la lógica del mensaje de fondo
}

class PushNotificationsProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final StreamController<Map<String, dynamic>> _streamController =
  StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get message => _streamController.stream;

  void initPushNotifications() async {
    // Configuración para recibir mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Recibido en primer plano');
      print('Datos del mensaje: ${message.data}');
      if (message.data.isNotEmpty) {
        _streamController.sink.add(message.data);
      } else {
        print('No hay datos en el mensaje.');
      }
    });

    // Configuración para recibir mensajes cuando la aplicación está en segundo plano o terminada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      print('Recibido cuando estamos en segundo plano o aplicación terminada');
      print('Datos del mensaje: ${message.data}');
      _streamController.sink.add(message.data);
      SharedPref sharedPref = SharedPref();
      await sharedPref.save('isNotification', 'true');
    });

    // Configuración para recibir mensajes cuando la aplicación se lanza desde un estado cerrado
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Solicitar permisos en iOS
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false, // Cambiado a false para solicitar permisos completos
      );
      print('Permisos de notificación otorgados: ${settings.authorizationStatus}');
    } catch (e) {
      print('Error solicitando permisos de notificación: $e');
    }

    // Obtener el token de dispositivo para enviar notificaciones
  }

  Future<String> getAccessToken() async {
    // Cargar el archivo JSON de las credenciales
    final jsonString = await rootBundle.loadString('assets/conseven.json');
    final accountCredentials = ServiceAccountCredentials.fromJson(jsonDecode(jsonString));

    final client = await clientViaServiceAccount(accountCredentials, _scopes);
    return client.credentials.accessToken.data;
  }

  void saveToken(String idUser, String typeUser) async {
    String? token = await _firebaseMessaging.getToken();
    print('Token del dispositivo: $token');
    Map<String, dynamic> data = {
      'token': token
    };

    if (typeUser == 'client') {
      ClientProvider clientProvider = ClientProvider();
      clientProvider.update(data, idUser);
    } else {
      DriverProvider driverProvider = DriverProvider();
      driverProvider.update(data, idUser);
    }
  }

  Future<void> sendMessage(String to, Map<String, dynamic> data,String title,String body) async {
    final accessToken = await getAccessToken();

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/seven-taxis/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message': {
            'token': to,
            'notification': {
              'body': body,
              'title': title,
            },
            'data': data,
          },
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Mensaje enviado correctamente');
    } else {
      print('Error al enviar mensaje: ${response.statusCode}');
      print('Respuesta: ${response.body}');
    }
  }

  void dispose() {
    _streamController.close();
  }
}
