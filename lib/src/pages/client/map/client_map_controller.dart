import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'as maps;
import 'package:location/location.dart' as location;
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:seven_taxis_app/src/api/environment.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/geofire_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';
import 'package:seven_taxis_app/src/providers/push_notifications_provider.dart';
import '../../../utils/my_progress_dialog.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:geocoding/geocoding.dart';




class ClientMapController {

  late BuildContext context;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<maps.GoogleMapController> _mapController = Completer();
  final FlutterGooglePlacesSdk places = FlutterGooglePlacesSdk(Environment.API_KEY_MAPS);
  final List<AutocompletePrediction> predictions = [];




  maps.CameraPosition initialPosition = maps.CameraPosition(
    target: maps.LatLng(1.2342774, -77.2645446),
    zoom: 14.0,
  );

  Map<maps.MarkerId, maps.Marker> markers = <maps.MarkerId, maps.Marker>{};

  late Position _position;
  late StreamSubscription<Position> _positionStream;
  late maps.BitmapDescriptor markerDriver;

  late GeoFireProvider _geofireProvider;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late ClientProvider _clientProvider;
  late PushNotificationsProvider _pushNotificationsProvider;

  bool isConnect = false;
  late ProgressDialog _progressDialog;

  late StreamSubscription<DocumentSnapshot> _statusSubscription;
  late StreamSubscription<DocumentSnapshot> _clientInfoSubscription;

  Client? client;
  String? from;
  late maps.LatLng fromLatLng;
  late maps.LatLng toLatLng;
  bool isFromSelected = true;
  String? to;

  List<PlaceField> _placeFields = [
    PlaceField.Address,
    PlaceField.AddressComponents,
    PlaceField.Id,
    PlaceField.Location,
    PlaceField.Name,
    PlaceField.OpeningHours,
    PlaceField.PhoneNumber,
    PlaceField.PhotoMetadatas,
    PlaceField.PlusCode,
    PlaceField.PriceLevel,
    PlaceField.Rating,
    PlaceField.Types,
    PlaceField.UserRatingsTotal,
    PlaceField.UTCOffset,
    PlaceField.Viewport,
    PlaceField.WebsiteUri,
  ];


  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = GeoFireProvider();
    _authProvider = MyAuthProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');
    _driverProvider = DriverProvider();
    _clientProvider = ClientProvider();
    _pushNotificationsProvider = PushNotificationsProvider();
    markerDriver = await createMarkerImageFromAsset('assets/img/icon_taxi.png');
    checkGPS();
    saveToken();
    getClientInfo();
  }
  void changeFromTo() {
    isFromSelected = !isFromSelected;
    if (isFromSelected) {
      utils.Snackbar.showSnackbar(context, 'Estás seleccionando el lugar de recogida');
    } else {
      utils.Snackbar.showSnackbar(context, 'Estás seleccionando el lugar de destino');
    }
  }
  void requestDriver() {
    try {
      // Verificamos que ambas variables no sean nulas
      if (fromLatLng != null && toLatLng != null && from != null && to != null) {
        Navigator.pushNamed(context, 'client/travel/info', arguments: {
          'from': from,
          'to': to,
          'fromLatLng': fromLatLng,
          'toLatLng': toLatLng
        });
      } else {
        utils.Snackbar.showSnackbar(
            context, 'DEBE SELECCIONAR EL LUGAR DE RECOGIDA Y DESTINO');
      }
    } catch (e) {
      utils.Snackbar.showSnackbar(
          context, 'DEBE SELECCIONAR EL LUGAR DE RECOGIDA Y DESTINO');
    }
  }



  Future<Null>setLocationDraggableInfo()async{
    if(initialPosition != null){
      double lat = initialPosition.target.latitude;
      double lng = initialPosition.target.longitude;
      List<Placemark>addres = await placemarkFromCoordinates(
          lat,lng);
      if(addres != null){
        if(addres.isNotEmpty){
          String? direccion = addres[0].thoroughfare;
          String? street = addres[0].subThoroughfare;
          String? city = addres[0].locality;
          String? departament = addres[0].administrativeArea;
          String? country = addres[0].country;
          if(isFromSelected) {
            from = '$direccion #$street, $city, $departament';
            fromLatLng = maps.LatLng(lat, lng);
          }
          else{
            to = '$direccion #$street, $city, $departament';
            toLatLng = maps.LatLng(lat, lng);
          }
          refresh();
        }
      }
    }
  }
  void buscarCoordenadas(String id,bool consu) async {

    String placeId = id; // Ejemplo de Place ID
    LatLng? coordenadas = await getCoordinatesFromPlaceId(placeId);

    if (coordenadas != null) {
      print('Coordenadas ******************: ${coordenadas.lat}, ${coordenadas.lng}');
     if(consu) {
       fromLatLng = new maps.LatLng(coordenadas.lat, coordenadas.lng);
       print('guarde aquiiii');
       refresh();
     }else{
       print('guarde aquiiii toooooooooooo');
       toLatLng = new maps.LatLng(coordenadas.lat, coordenadas.lng);
       refresh();
     }
    } else {
      print('No se pudieron obtener las coordenadas.');
    }
  }

  Future<LatLng?> getCoordinatesFromPlaceId(String placeId) async {
    try {
      // Solicita los detalles del lugar usando el placeId
      final place = await places.fetchPlace(placeId, fields: [PlaceField.Location]);

      // Si el lugar tiene coordenadas, las retorna
      if (place.place?.latLng != null) {
        return place.place?.latLng;
      } else {
        return null; // Si no hay coordenadas, retorna null
      }
    } catch (e) {
      print('Error obteniendo coordenadas: $e');
      return null; // En caso de error, también retorna null
    }
  }


  Future<void> showAutocomplete(String query) async {
    print('Searching for: $query');
    try {
      final result = await places.findAutocompletePredictions(
        query,
        countries: ['CO'],
        locationBias: LatLngBounds(
            southwest: LatLng(lat: 4.4276, lng:-75.2489), // Coordenadas para el suroeste de Ibagué
            northeast: LatLng(lat: 4.4652, lng:-75.2003)  // Coordenadas para el noreste de Ibagué
        ),

      );

      if (result.predictions.isNotEmpty) {
        predictions.clear();
        predictions.addAll(result.predictions);
        refresh();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void goToEditPage(){
    Navigator.pushNamed(context, 'client/edit');
  }

  void goToHistoryPage(){
    Navigator.pushNamed(context, 'client/history');
  }

  void getClientInfo() {
    final user = _authProvider.getUser();
    if (user != null) {
      Stream<DocumentSnapshot> clientStream = _clientProvider.getByIdStream(user.uid);
      _clientInfoSubscription=clientStream.listen((DocumentSnapshot document) {
        if (document.data() != null) {
          final data = document.data() as Map<String, dynamic>;
          client = Client.fromJson(data);
          if(refresh != null) {
            refresh();
          }// Llama a refresh para actualizar la UI
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
    _statusSubscription.cancel();
    _clientInfoSubscription.cancel();
  }
  void openDrawer(){
    key.currentState?.openDrawer();
  }

  void onMapCreated(maps.GoogleMapController controller) {
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]');
    _mapController.complete(controller);
  }
  void updateLocation() async {
    try {
      await _determinePosition();
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        _position = lastKnownPosition;
        centerPosition();
        getNearbyDrivers();
      }
    } catch (error) {
      print('Error en la localizacion: $error');
    }
  }

  void getNearbyDrivers(){
    Stream<List<DocumentSnapshot>> stream = _geofireProvider.getNearbyDrivers(_position.latitude, _position.longitude, 10);
    stream.listen((List<DocumentSnapshot> documentList){

      for(maps.MarkerId m in markers.keys){
        bool remove = true;
        for (DocumentSnapshot d in documentList){
          print('conductores $d');
          if (m.value == d.id){
            remove = false;
          }
        }
        if(remove){
          markers.remove(m);
          refresh();
        }

      }

      for (DocumentSnapshot d in documentList) {
        Map<String, dynamic>? data = d.data() as Map<String, dynamic>?; // Casting necesario para evitar errores de tipo.

        if (data != null) {
          GeoPoint? point = data['position']?['geopoint'] as GeoPoint?; // Uso de operador de acceso seguro (?)

          if (point != null) {
            addMarker(d.id, point.latitude,
                point.longitude,
                'conductor disponible',
                d.id, markerDriver
            );
          } else {
            print('Geopoint no disponible en este documento.');
          }
        } else {
          print('Datos no disponibles en este documento.');
        }
      }
      refresh();


    });
  }
  void saveToken(){
    _pushNotificationsProvider.saveToken(_authProvider.getUser()!.uid, 'client');

  }




  void centerPosition() {
    if (_position != null) {
      animateCameraToPosition(_position.latitude, _position.longitude);
    }
    else {
      utils.Snackbar.showSnackbar(context,  'Activa el GPS para obtener la posicion');
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
    maps.GoogleMapController? controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(maps.CameraUpdate.newCameraPosition(
        maps.CameraPosition(
          bearing: 0,
          target: maps.LatLng(latitude, longitude),
          zoom: 14,
        ),
      ));
    } else {
      print('Error: El controlador del mapa no está disponible.');
    }
  }


  Future<maps.BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    maps.BitmapDescriptor bitmapDescriptor =
    await maps.BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarker(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      maps.BitmapDescriptor iconMarker
      ) {

    maps.MarkerId id = maps.MarkerId(markerId);
    maps.Marker marker = maps.Marker(
        markerId: id,
        icon: iconMarker,
        position: maps.LatLng(lat, lng),
        infoWindow: maps.InfoWindow(title: title, snippet: content),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        rotation: _position.heading
    );

    markers[id] = marker;

  }

  void clearPredictions() {
    predictions.clear();
  }

}