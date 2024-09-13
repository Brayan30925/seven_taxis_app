import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:seven_taxis_app/src/models/driver.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/providers/geofire_provider.dart';
import 'package:seven_taxis_app/src/providers/push_notifications_provider.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;
import 'package:seven_taxis_app/src/providers/auth_provider.dart';

import '../../../utils/my_progress_dialog.dart';

class DriverMapController {

  late BuildContext context;
  late Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
      target: LatLng(1.2342774, -77.2645446),
      zoom: 14.0
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late Position _position;
  late StreamSubscription<Position> _positionStream;

  late BitmapDescriptor markerDriver;

  late GeoFireProvider _geofireProvider;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;

  bool isConnect = false;
  late ProgressDialog _progressDialog;
  late PushNotificationsProvider _pushNotificationsProvider;


  late StreamSubscription<DocumentSnapshot> _statusSuscription;
  late StreamSubscription<DocumentSnapshot> _driverInfoSuscription;

  Driver? driver;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = new GeoFireProvider();
    _authProvider = new MyAuthProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'conectandose....');
    _driverProvider = DriverProvider();
    _pushNotificationsProvider=PushNotificationsProvider();
    markerDriver = await createMarkerImageFromAsset('assets/img/taxi_icon.png');
    checkGPS();
    saveToken();
    getDriverInfo();
  }

  void getDriverInfo() {
    final user = _authProvider.getUser();
    if (user != null) {
      Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(user.uid);
      _driverInfoSuscription=driverStream.listen((DocumentSnapshot document) {
        if (document.data() != null) {
          final data = document.data() as Map<String, dynamic>;
          driver = Driver.fromJson(data);
          print('esta es la informacion ....$driver');
          refresh(); // Llama a refresh para actualizar la UI
        } else {
          print('Error: El documento no contiene datos');
        }
      });
    } else {
      print('No hay usuario autenticado');
    }
  }
  void signOut()async{
    await _authProvider.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route)=>false);

  }

  void dispose() {
    _positionStream.cancel();
    _statusSuscription.cancel();
    _driverInfoSuscription.cancel();
  }
  void openDrawer(){
    key.currentState?.openDrawer();
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]');
    _mapController.complete(controller);
  }

  void saveLocation() async {
    await _geofireProvider.create(
        _authProvider.getUser()!.uid,
        _position.latitude,
        _position.longitude
    );
    _progressDialog.hide();

  }

  void connect() {
    if (isConnect) {
      disconnect();
    }
    else {
      _progressDialog.show();
      updateLocation();
    }
  }

  void disconnect() {
    _positionStream.cancel();
    _geofireProvider.delete(_authProvider.getUser()!.uid);
  }

  void checkIfIsConnect() {
    Stream<DocumentSnapshot> status =
    _geofireProvider.getlocationByIdStream(_authProvider.getUser()!.uid);

    _statusSuscription = status.listen((DocumentSnapshot document) {
      if (document.exists) {
        isConnect = true;
      }
      else {
        isConnect = false;
      }

      refresh();
    });

  }

  void updateLocation() async {
    try {
      await _determinePosition();
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        _position = lastKnownPosition;
        centerPosition();
        saveLocation();

        addMarker(
            'driver',
            _position.latitude,
            _position.longitude,
            'Tu posicion',
            '',
            markerDriver
        );
        refresh();
      } else {
        print('No se encontró una posición conocida');
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 1,
        ),
      ).listen((Position position) {
        _position = position;
        addMarker(
            'driver',
            _position.latitude,
            _position.longitude,
            'Tu posicion',
            '',
            markerDriver
        );
        animateCameraToPosition(_position.latitude, _position.longitude);
        saveLocation();
        refresh();
      });

    } catch (error) {
      print('Error en la localizacion: $error');
    }
  }


  void centerPosition() {
    if (_position != null) {
      animateCameraToPosition(_position.latitude, _position.longitude);
    }
    else {
      utils.Snackbar.showSnackbar(context,  'Activa el GPS para obtener la posicion');
    }
  }

  void saveToken(){
    _pushNotificationsProvider.saveToken(_authProvider.getUser()!.uid, 'driver');

  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS ACTIVADO');
      updateLocation();
      checkIfIsConnect();
    }
    else {
      print('GPS DESACTIVADO');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
        checkIfIsConnect();
        print('ACTIVO EL GPS');
      }
    }

  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController? controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(latitude, longitude),
          zoom: 17,
        ),
      ));
    } else {
      print('Error: El controlador del mapa no está disponible.');
    }
  }


  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarker(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker
      ) {

    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
        markerId: id,
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        rotation: _position.heading
    );

    markers[id] = marker;

  }


}