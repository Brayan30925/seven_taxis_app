import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';
import 'package:seven_taxis_app/src/providers/travel_history_provider.dart';
import 'package:seven_taxis_app/src/widgets/bottom_sheet_driver_info.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:seven_taxis_app/src/models/prices.dart';
import 'package:seven_taxis_app/src/models/travel_info.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/geofire_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/providers/prices_provider.dart';
import 'package:seven_taxis_app/src/providers/push_notifications_provider.dart';
import 'package:seven_taxis_app/src/providers/travel_info_provider.dart';
import 'package:seven_taxis_app/src/utils/my_progress_dialog.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;
import 'package:seven_taxis_app/src/models/driver.dart';

import '../../../api/environment.dart';
import '../../../models/TravelHistory.dart';

class DriverTravelMapController {

  late BuildContext context;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
      target: LatLng(4.4005509, -75.1428627),
      zoom: 14.0
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late Position _position;
  late StreamSubscription<Position> _positionStream;

  late BitmapDescriptor markerDriver;

  late GeoFireProvider _geofireProvider;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late PushNotificationsProvider _pushNotificationsProvider;
  late TravelInfoProvider _travelInfoProvider;
  late PricesProvider _pricesProvider;
  late ClientProvider _clientProvider;
  late TravelHistoryProvider _travelHistoryProvider;

  bool isConnect = false;
  late ProgressDialog _progressDialog;
  late BitmapDescriptor fromMarker;
  late BitmapDescriptor toMarker;

  late StreamSubscription<DocumentSnapshot> _statusSuscription;
  late StreamSubscription<DocumentSnapshot> _driverInfoSuscription;

  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> points = [];

  Driver? driver;
  Client? _client;
  String? _idTravel;
  TravelInfo? travelInfo;

  String currentStatus='INICIAR VIAJE ';
  Color colorStatus= Colors.amber;
  double? distanceBetween;
  late Timer _timer;
  int seconds=0;
  double mt=0;
  double km=0;
  int minutos=0;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _idTravel=ModalRoute.of(context)?.settings.arguments as String;
    _geofireProvider =GeoFireProvider();
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();
    _travelInfoProvider = TravelInfoProvider();
    _pricesProvider=PricesProvider();
    _clientProvider = ClientProvider();
    _travelHistoryProvider = TravelHistoryProvider();
    _pushNotificationsProvider = PushNotificationsProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');
    markerDriver = await createMarkerImageFromAsset('assets/img/taxi_icon.png');
    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');
    checkGPS();
    getDriverInfo();
  }

  void getClientInfo()async{
    _client = await _clientProvider.getById(_idTravel!);

  }

  Future<double> calculatePrice()async{
    Prices prices = await _pricesProvider.getAll();
    if(seconds<60)seconds=60;
    if(km==0)km=1;
    double priceMIn= minutos * prices.min;
    double priceKm = km * prices.km;
    double total = priceMIn+priceKm;

    if(total< prices.minValue){
      total=prices.minValue;
    }

    return total;
  }

  void openButtonSheet() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => BottomSheetDriverInfo(
        imageUrl: _client?.image ?? 'no disponible',
        username: _client?.username ?? 'Nombre no disponible',
        email: _client?.email ?? 'Email no disponible',
      ),
    );
  }


  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      seconds++;

      // Incrementar los minutos cuando los segundos llegan a 60
      if (seconds == 60) {
        minutos++;
        seconds = 0;  // Reiniciar los segundos a 0
      }

      refresh();  // Actualiza la UI o lo que necesites actualizar
    });
  }

  void isCloseToPickupPosition(LatLng from,LatLng to){
    distanceBetween=Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude
    );
    print('distance: $distanceBetween *******************************************************');

  }

  void updateStatus(){
    if(travelInfo?.status=='accepted'){
      startTravel();
    }
   else if(travelInfo?.status=='started'){
     finishTravel();
    }
  }
  void startTravel()async{
    if(distanceBetween! <= 300){
      Map<String,dynamic>data=
      {
        'status':'started'
      };
      await _travelInfoProvider.update(data, _idTravel!);
      travelInfo?.status='started';
      currentStatus='Finalizar viaje ';
      colorStatus=Colors.cyan;
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
      LatLng from = LatLng(_position.latitude, _position.longitude);
      LatLng to = LatLng(travelInfo!.toLat, travelInfo!.toLng);
      setPolyLines(from, to);
      startTimer();
      refresh();
    }
    else{
      utils.Snackbar.showSnackbar(context,'Debes estar cerca a la posicion del cliente para iniciar viaje ');
    }

   refresh();

  }
  void finishTravel() async {
    try {
      // Cancelar el temporizador si existe
      _timer.cancel();

      // Calcular el precio del viaje
      double total = await calculatePrice();

      // Validar que _idTravel no sea null antes de actualizar
      if (_idTravel == null) {
        print('Error: El ID del viaje es nulo');
        return;
      }


      // Guardar el historial del viaje
      await saveTravelHistory(total);

      // Navegar a la pantalla de calificación y eliminar las anteriores


      // Refrescar la interfaz si es necesario
      refresh();
    } catch (e) {
      print('Error en finishTravel: $e');
    }
  }

  Future<void> saveTravelHistory(double price) async {
    try {
      // Validar que travelInfo y el usuario no sean nulos
      if (travelInfo == null || _authProvider.getUser() == null || _idTravel == null) {
        print('Error: Información del viaje o usuario es nula');
        return;
      }

      // Crear el historial del viaje
      TravelHistory travelHistory = TravelHistory(
        from: travelInfo?.from,
        to: travelInfo?.to,
        idDriver: _authProvider.getUser()!.uid,
        idClient: _idTravel,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        price: price,
      );

      // Guardar el historial en la base de datos
      String id = await _travelHistoryProvider.create(travelHistory);

      // Actualizar el estado del viaje a "finished"
      Map<String, dynamic> data = {
        'status': 'finished',
        'idTravelHistory': id,
        'price': price

      };
      await _travelInfoProvider.update(data, _idTravel!);

      // Actualizar el estado local del viaje
      travelInfo?.status = 'finished';


      // Navegar a la pantalla de calificación con el argumento del historial del viaje
      Navigator.pushNamedAndRemoveUntil(
        context,
        'driver/travel/calification',
            (route) => false,
        arguments: id, // Pasar el ID del historial de viaje como argumento
      );
    } catch (e) {
      print('Error en saveTravelHistory: $e');
    }
  }


  void getDriverInfo() {
    Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(_authProvider.getUser()!.uid);
    _driverInfoSuscription = driverStream.listen((DocumentSnapshot document) {
      if (document.data() != null) {
        // Asegurarte de que el dato es del tipo correcto
        final data = document.data() as Map<String, dynamic>;
        driver = Driver.fromJson(data);
        refresh();
      } else {
        print('Error: El documento no contiene datos');
      }
    });
  }

  void getTravelInfo() async {
    try {
      print('Buscando información de viaje para el ID: $_idTravel');
      travelInfo = await _travelInfoProvider.getById(_idTravel!);

      if (travelInfo == null) {
        print('No se encontró información de viaje');
        return;
      }

      print('Información de viaje encontrada: $travelInfo');

      LatLng from = LatLng(_position.latitude, _position.longitude);
      LatLng to = LatLng(travelInfo!.fromLat, travelInfo!.fromLng);
      addSimpleMarker('from', to.latitude, to.longitude, 'Recoger aquí', '', fromMarker);
      setPolyLines(from, to);
      getClientInfo();

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



  void dispose() {
    _positionStream.cancel();
    _statusSuscription.cancel();
    _driverInfoSuscription.cancel();
    _timer.cancel();
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]');
    _mapController.complete(controller);
  }

  void saveLocation() async {
    await _geofireProvider.createWorking(
        _authProvider.getUser()!.uid,
        _position.latitude,
        _position.longitude
    );
    _progressDialog.hide();
  }

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = (await Geolocator.getLastKnownPosition())!;
      getTravelInfo();
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

      // Utiliza LocationSettings para definir desiredAccuracy y distanceFilter
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best, // Configura la precisión
        distanceFilter: 1, // Filtro de distancia en metros
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {

        if(travelInfo?.status=='started'){
          mt= mt+Geolocator.distanceBetween(
              _position.latitude,
              _position.longitude,
              position.latitude,
              position.longitude
          );
          km=mt/1000;
        }

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
        if(travelInfo?.fromLat != null && travelInfo?.fromLng != null){
          LatLng from = LatLng(_position.latitude,_position.longitude);
          LatLng to = LatLng(travelInfo!.fromLat,travelInfo!.fromLng);
          isCloseToPickupPosition(from, to);
        }
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
      utils.Snackbar.showSnackbar(context, 'Activa el GPS para obtener la posicion');
    }
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS ACTIVADO');
      updateLocation();
    }
    else {
      print('GPS DESACTIVADO');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
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

  }void addSimpleMarker(
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