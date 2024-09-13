import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/pages/client/map/client_map_page.dart';
import 'package:seven_taxis_app/src/pages/client/travel_info/client_travel_info_page.dart';
import 'package:seven_taxis_app/src/pages/client/travel_request/client_travel_request_page.dart';
import 'package:seven_taxis_app/src/pages/driver/map/driver_map_page.dart';
import 'package:seven_taxis_app/src/pages/driver/register/driver_register_page.dart';
import 'package:seven_taxis_app/src/pages/driver/travel_request/driver_travel_request_page.dart';
import 'package:seven_taxis_app/src/pages/home/home_page.dart';
import 'package:seven_taxis_app/src/pages/login/login_page.dart';
import 'package:seven_taxis_app/src/providers/push_notifications_provider.dart';
import 'package:seven_taxis_app/src/utils/colors.dart' as utils;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:seven_taxis_app/src/pages/client/register/client_register_page.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
   MyApp({super.key});

   @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PushNotificationsProvider pushNotificationsProvider = PushNotificationsProvider();
    pushNotificationsProvider.initPushNotifications();
    pushNotificationsProvider.message.listen((data){
      print('**********************NOTIFICACION NUEVA *********************************');
      print(data);
      navigatorKey.currentState?.pushNamed('driver/travel/request',arguments: data);


    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SevenApp',
      navigatorKey: navigatorKey,
      initialRoute: 'home',
      theme: ThemeData(
        fontFamily: 'NimbusSans',
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: utils.Colors.seven,
        ),
        primaryColor: utils.Colors.seven,
      ),
      routes: {
        'home': (BuildContext context) => HomePage(),
        'login': (BuildContext context) => LoginPage(),
        'client/register': (BuildContext context) => ClientRegisterPage(),
        'driver/register': (BuildContext context) => DriverRegisterPage(),
        'driver/map': (BuildContext context) => DriverMapPage(),
        'client/map': (BuildContext context) => ClientMapPage(),
        'client/travel/info': (BuildContext context) => ClientTravelInfoPage(),
        'client/travel/request': (BuildContext context) => ClientTravelRequestPage(),
        'driver/travel/request': (BuildContext context) => DriverTravelRequestPage(),
      },
    );
  }
}
