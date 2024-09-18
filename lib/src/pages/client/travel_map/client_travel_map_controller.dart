import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:seven_taxis_app/src/api/environment.dart';
import 'package:seven_taxis_app/src/models/travel_info.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/geofire_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/providers/push_notifications_provider.dart';
import 'package:seven_taxis_app/src/providers/travel_info_provider.dart';
import 'package:seven_taxis_app/src/utils/my_progress_dialog.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;
import 'package:seven_taxis_app/src/models/driver.dart';
import 'package:seven_taxis_app/src/widgets/bottom_sheet_client_info.dart';

import '../../../widgets/bottom_sheet_driver_info.dart';

class ClientTravelMapController {

  late BuildContext context;
  late Function refresh;

  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
      target: LatLng(4.4005509, -75.1428627),
      zoom: 14.0
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};



  late BitmapDescriptor markerDriver;
  late BitmapDescriptor fromMarker;
  late BitmapDescriptor toMarker;

  late GeoFireProvider _geofireProvider;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late PushNotificationsProvider _pushNotificationsProvider;
  late TravelInfoProvider _travelInfoProvider;

  bool isConnect = false;
  late ProgressDialog _progressDialog;

  late StreamSubscription<DocumentSnapshot> _statusSuscription;
  late StreamSubscription<DocumentSnapshot> _driverInfoSuscription;

  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> points = [];

  late Driver driver;
  late LatLng _driverLatLng;
  TravelInfo? travelInfo;

  bool isRouteReady = false;
  String currentStatus = '';
  Color colorStatus = Colors.white;
  bool isPickupTravel = false;
  bool isStartTravel = false;
  bool isFinishTravel= false;
  late StreamSubscription<DocumentSnapshot> _streamLocationController;
  late StreamSubscription<DocumentSnapshot> _streamTravelController;

    Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    _geofireProvider = GeoFireProvider();
    _authProvider =  MyAuthProvider();
    _driverProvider =  DriverProvider();
    _travelInfoProvider =  TravelInfoProvider();
    _pushNotificationsProvider =  PushNotificationsProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');

    markerDriver = await createMarkerImageFromAsset('assets/img/icon_taxi.png');
    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');

    checkGPS();
  }

  void getDriverLocation(String idDriver) {
    Stream<DocumentSnapshot> stream = _geofireProvider.getlocationByIdStream(idDriver);
    _streamLocationController= stream.listen((DocumentSnapshot document) {
      var data = document.data() as Map<String, dynamic>?; // Asegúrate de que el tipo es correcto y puede ser null

      if (data == null) {
        print('No se encontraron datos para el conductor.');
        return;
      }

      // Verifica si 'position' y 'geopoint' existen
      if (data.containsKey('position') && data['position'].containsKey('geopoint')) {
        GeoPoint geoPoint = data['position']['geopoint'];
        _driverLatLng = LatLng(geoPoint.latitude, geoPoint.longitude);

        addSimpleMarker(
            'driver',
            _driverLatLng.latitude,
            _driverLatLng.longitude,
            'Tu conductor',
            '',
            markerDriver
        );

        refresh();

        // Verifica que travelInfo no sea null antes de usarlo
        if (!isRouteReady && travelInfo != null) {
          isRouteReady = true;
          checkTravelStatus();

        } else if (travelInfo == null) {
          print('travelInfo es null. No se puede trazar la ruta.');
        }
      } else {
        print('Los datos de ubicación del conductor no están disponibles.');
      }
    });
  }

  void pickupTravel(){
    if(!isPickupTravel){
      isPickupTravel=false;
      LatLng from = LatLng(_driverLatLng.latitude, _driverLatLng.longitude);
      LatLng to = LatLng(travelInfo!.fromLat, travelInfo!.fromLng);
      addSimpleMarker('from', to.latitude, to.longitude, 'Recoger aquí', '', fromMarker);

      setPolyLines(from, to);
    }


  }

  void checkTravelStatus()async{
    Stream<DocumentSnapshot>stream =_travelInfoProvider.getByidStream(_authProvider.getUser()!.uid);
    _streamTravelController = stream.listen((DocumentSnapshot document){
      travelInfo = TravelInfo.fromJson(document.data() as Map<String, dynamic>);
      if(travelInfo?.status=='accepted'){
        currentStatus='viaje aceptado';
        colorStatus=Colors.white;
        pickupTravel();

      }else if(travelInfo?.status=='started'){
        currentStatus='viaje iniciado';
        colorStatus=Colors.amber;
        startTravel();

      }else if (travelInfo?.status=='finished'){
        currentStatus='viaje finalizado';
        colorStatus=Colors.cyan;
        finishTravel();

      }
      refresh();

    });
  }

  void finishTravel(){
      if(!isFinishTravel){
        isFinishTravel=true;
        Navigator.pushNamedAndRemoveUntil(context, 'client/travel/calification', (route)=>false,arguments: travelInfo?.idTravelHistory);
      }

  }

  void startTravel(){
    if(!isStartTravel){
      isStartTravel=true;
      polyLines={};
      points = [];
      //markers.remove(markers['from']);
      markers.removeWhere((key, marker) => marker.markerId.value == 'from');
      addSimpleMarker(
          'to',
          travelInfo!.toLat,
          travelInfo!.toLng,
          'Destino',
          '',
          toMarker
      );
      LatLng from = LatLng(_driverLatLng.latitude, _driverLatLng.longitude);
      LatLng to = LatLng(travelInfo!.toLat, travelInfo!.toLng);
      setPolyLines(from, to);
      refresh();
    }


  }

  void openButtonSheet() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => BottomSheetClientInfo(
        imageUrl: driver.image ?? 'no disponible',
        username: driver.username ?? 'Nombre no disponible',
        email: driver.email ?? 'Email no disponible',
        plate: driver.plate ?? 'placa no disponible',
      ),
    );
  }

  void getTravelInfo() async {
    try {
      // Verificar si el usuario está autenticado
      final user = _authProvider.getUser();
      if (user == null) {
        print('Usuario no autenticado');
        return;
      }

      // Obtener información del viaje
      travelInfo = await _travelInfoProvider.getById(user.uid);
      
      if (travelInfo == null) {
        print('No se encontró información de viaje');
        return;
      }

      print('Información de viaje encontrada: $travelInfo');

      // Verificar si idDriver no es nulo antes de usarlo
      if (travelInfo!.idDriver != null) {
        animateCameraToPosition(travelInfo!.fromLat, travelInfo!.fromLng);
        getDriverInfo(travelInfo!.idDriver);
        getDriverLocation(travelInfo!.idDriver);
      } else {
        print('El viaje no tiene conductor asignado');
      }

    } catch (error) {
      print('Error al obtener la información de viaje: $error');
    }
  }


  Future<void> setPolyLines(LatLng from,LatLng to) async {
    try {
      PolylineRequest request = PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: TravelMode.driving, // Puedes cambiar a 'walking', 'bicycling', o 'transit' si es necesario
      );

      PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        request: request,
        googleApiKey: Environment.API_KEY_MAPS,
      );

      if (result.points.isNotEmpty) {
        points.clear(); // Limpia los puntos anteriores
        for (PointLatLng point in result.points) {
          points.add(LatLng(point.latitude, point.longitude));
        }

        Polyline polyline = Polyline(
          polylineId: PolylineId('poly'),
          color: Colors.amber,
          points: points,
          width: 6,
        );

        polyLines[PolylineId('poly')] = polyline;

        //addMarker('to', toLatLng.latitude, toLatLng.longitude, 'Destino', '', toMarker);

        refresh();
      } else {
        utils.Snackbar.showSnackbar(context, 'No se encontró ninguna ruta');
      }
    } catch (e) {
      utils.Snackbar.showSnackbar(context, 'Error al obtener ruta: $e');
    }
  }


  void getDriverInfo(String id) async {
    driver = (await _driverProvider.getById(id))!;
    refresh();
  }

  void dispose() {
    _statusSuscription.cancel();
    _driverInfoSuscription.cancel();
    _streamLocationController.cancel();
    _streamTravelController.cancel();

  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]');
    _mapController.complete(controller);

    getTravelInfo();
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS ACTIVADO');
    }
    else {
      print('GPS DESACTIVADO');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        print('ACTIVO EL GPS');
      }
    }

  }

  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              bearing: 0,
              target: LatLng(latitude, longitude),
              zoom: 17
          )
      ));
    }
  }

  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }
  void addSimpleMarker(
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
    );

    markers[id] = marker;
  }

}