import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsProvider {

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  StreamController _streamController =
    StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get message => _streamController.stream;


  void initPushNotifications() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('Cuando estamos en primer plano');
        print('OnMessage: $message');
        _streamController.sink.add(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        print('OnLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('OnResume $message');
        _streamController.sink.add(message);
      }
    );

    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
        provisional: true
      )
    );

    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print('Coonfiguraciones para Ios fueron regustradas $settings');
    });

  }

  void dispose () {
    _streamController?.onCancel;
  }

}