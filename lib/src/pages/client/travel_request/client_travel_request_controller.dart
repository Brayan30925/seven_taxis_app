import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seven_taxis_app/src/models/driver.dart';
import 'package:seven_taxis_app/src/models/travel_info.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/providers/geofire_provider.dart';
import 'package:seven_taxis_app/src/providers/push_notifications_provider.dart';
import 'package:seven_taxis_app/src/providers/travel_info_provider.dart';

class ClientTravelRequestController {
  late BuildContext context;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  late String from;
  late String to;
  late LatLng fromLatLng;
  late LatLng toLatLng;

  late TravelInfoProvider _travelInfoProvider;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late GeoFireProvider _geoFireProvider;
  late PushNotificationsProvider _pushNotificationsProvider;
  List<String> nearbyDrivers = List<String>.empty(growable: true);
  late StreamSubscription<List<DocumentSnapshot>> _streamSubscription;


  Future<void> init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    _travelInfoProvider = TravelInfoProvider();
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();
    _geoFireProvider = GeoFireProvider();
    _pushNotificationsProvider = PushNotificationsProvider();

    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments == null) {
      throw ArgumentError('No arguments found in the route');
    }

    from = arguments['from'] ?? '';
    to = arguments['to'] ?? '';
    fromLatLng = arguments['fromLatLng'] as LatLng;
    toLatLng = arguments['toLatLng'] as LatLng;

    await _createTravelInfo();
    _getNearbyDrivers();
  }
  void dispose(){
    _streamSubscription?.cancel();
  }

  void _getNearbyDrivers(){
    Stream<List<DocumentSnapshot>> stream=GeoFireProvider().getNearbyDrivers(
        fromLatLng.latitude,
        fromLatLng.longitude,
        5
    );
    _streamSubscription=stream.listen((List<DocumentSnapshot> documentList){
      for (DocumentSnapshot d in documentList){
        print('conductor encontrado ${d.id}');
        nearbyDrivers.add(d.id);
      }
      getDriverInfo(nearbyDrivers[0]);
      _streamSubscription?.cancel();


    });

  }
  Future<void> _createTravelInfo() async {
    final user = _authProvider.getUser();
    if (user == null) {
      throw StateError('No user found');
    }

    TravelInfo travelInfo = TravelInfo(
      id: user.uid,
      from: from,
      to: to,
      fromLat: fromLatLng.latitude,
      fromLng: fromLatLng.longitude,
      toLat: toLatLng.latitude,
      toLng: toLatLng.longitude,
      status: 'created',
      idDriver: '',  // O poner null si es opcional
      idTravelHistory: '',
      price: 0,
    );

    await _travelInfoProvider.create(travelInfo);
  }
  Future<void>getDriverInfo(String idDriver)async{
    Driver? driver =await _driverProvider.getById(idDriver);
    if (driver?.token != null) {
      _sendNotification(driver!.token!); // Forzamos el uso de '!' ya que hemos verificado que no es null
    } else {
      print('Token del conductor es null');
    }
  }
  void _sendNotification(String token){
    Map<String,dynamic>data={
      'click_action':'FLUTTER_NOTIFICATION_CLICK',
      'idClient':_authProvider.getUser()?.uid,
      'origin':from,
      'destination':to


    };
    _pushNotificationsProvider.sendMessage(token, data,'solicitud de servicio','un cliente esta solicitando un viaje');

  }
}
