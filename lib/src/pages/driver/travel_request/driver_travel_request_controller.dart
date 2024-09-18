import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';
import 'package:seven_taxis_app/src/providers/geofire_provider.dart';
import 'package:seven_taxis_app/src/providers/travel_info_provider.dart';
import 'package:seven_taxis_app/src/utils/shared_pref.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
class DriverTravelRequestController {
  late BuildContext context;
  GlobalKey<ScaffoldState> key = GlobalKey();
  late Function refresh;
  late SharedPref _sharedPref;

  String from = ''; // Asignación predeterminada
  String to = '';   // Asignación predeterminada
  late String idClient;
  Client? client;   // Sin `late` para permitir nulo



  ClientProvider _clientProvider = ClientProvider();
  late TravelInfoProvider _infoProvider ;
  late MyAuthProvider _authProvider;
  late GeoFireProvider _geoFireProvider;
  late Timer _timer;
  int seconds = 30;



  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _sharedPref = SharedPref();
    _clientProvider = ClientProvider();
    await _sharedPref.save('isNotification', 'false');
    _infoProvider = TravelInfoProvider();
    _authProvider = MyAuthProvider();
    _geoFireProvider = GeoFireProvider();

    Map<String, dynamic> arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    print('************************$arguments********************************');

    // Asignación segura con valores predeterminados
    from = arguments['origin'] ?? 'Origen desconocido';
    to = arguments['destination'] ?? 'Destino desconocido';
    idClient = arguments['idClient'] ?? '';

    getClientInfo();
    startTimer();
  }

  void dispose(){
    _timer?.cancel();
  }

  void startTimer(){
    _timer=Timer.periodic(Duration(seconds: 1), (timer){
      seconds=seconds-1;
      refresh();
      if(seconds==0){
        cancelTravel();
      }
    });

  }

  void acceptTravel(){
    Map<String,dynamic>data={
      'idDriver':_authProvider.getUser()!.uid,
      'status':'accepted'
    };

    _timer.cancel();
    _infoProvider.update(data, idClient);
    _geoFireProvider.delete(_authProvider.getUser()!.uid);
    Navigator.pushNamedAndRemoveUntil(context,'driver/travel/map',(route)=>false, arguments:idClient  );
      //Navigator.pushReplacementNamed(context, 'driver/travel/map', arguments:idClient);

  }

  void cancelTravel(){
    Map<String,dynamic>data={
      'status':'no_accepted'
    };
    _timer.cancel();
    _infoProvider.update(data, idClient);
    Navigator.pushNamedAndRemoveUntil(context,'driver/map',(route)=>false );
  }

  void getClientInfo() async {
    client = await _clientProvider.getById(idClient);
    refresh(); // Llamada para actualizar la vista después de obtener la información del cliente
  }
}
