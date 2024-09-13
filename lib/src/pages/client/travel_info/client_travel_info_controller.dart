import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seven_taxis_app/src/models/directions.dart';
import 'package:seven_taxis_app/src/providers/google_provider.dart';
import 'package:seven_taxis_app/src/providers/prices_provider.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;
import '../../../api/environment.dart';
import '../../../models/prices.dart';

class ClientTravelInfoController {
  late BuildContext context;
  late GoogleProvider _googleProvider;
  late PricesProvider _pricesProvider;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
    target: LatLng(4.4390727, -75.2259059),
    zoom: 14.0,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  String? from;
  String? to;
  late LatLng fromLatLng;
  late LatLng toLatLng;

  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> points = [];

  late BitmapDescriptor fromMarker;
  late BitmapDescriptor toMarker;
  late Direction _direction;
  String? min;
  String? km;
  double? minTotal;
  double? maxTotal;


  Future<void> init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    // Verificar y asignar argumentos
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      from = arguments['from'] ?? '';
      to = arguments['to'] ?? '';
      fromLatLng = arguments['fromLatLng'] ?? LatLng(0, 0);
      toLatLng = arguments['toLatLng'] ?? LatLng(0, 0);
    } else {
      utils.Snackbar.showSnackbar(context, 'No se recibieron argumentos de la ubicación');
      return; // Detener la ejecución si no hay argumentos válidos
    }

    _googleProvider = GoogleProvider();
    _pricesProvider = PricesProvider();
    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');

    // Mover la cámara a la posición inicial después de asegurarnos de que fromLatLng y toLatLng no son nulos
    await animateCameraToPosition(fromLatLng.latitude, fromLatLng.longitude);
    getGoogleMapsDirections(fromLatLng, toLatLng);
  }

  void getGoogleMapsDirections(LatLng from, LatLng to) async {
    try {
      // Verificar que `from` y `to` no sean iguales
      if (from == to) {
        utils.Snackbar.showSnackbar(context, 'Las ubicaciones de origen y destino son las mismas.');
        return;
      }

      // Obtener direcciones desde el proveedor de Google Maps
      _direction = await _googleProvider.getGoogleMapsDirections(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );

      // Verificar si `_direction` es null o no tiene datos
      if (_direction != null) {
        min = _direction.duration.text;
        km = _direction.distance.text;

        calculatePrices();
        print('km: $km min: $min ******************************************************');
      } else {
        utils.Snackbar.showSnackbar(context, 'No se pudieron obtener las direcciones.');
      }

      refresh();
    } catch (e) {
      // Capturar y mostrar cualquier excepción que ocurra
      utils.Snackbar.showSnackbar(context, 'Error al obtener direcciones: $e');
      print('Exception: $e'); // Imprimir excepción para depuración
    }
  }
  void goToRequest() {
    Navigator.pushNamed(context, 'client/travel/request', arguments: {
      'from': from,
      'to': to,
      'fromLatLng': fromLatLng,
      'toLatLng': toLatLng,
    });
  }

  void calculatePrices()async{
    Prices prices = await _pricesProvider.getAll();

    double kmValue = double.parse(km!.split(" ")[0])*prices.km ;
    double minValue = double.parse(min!.split(" ")[0])*prices.min ;
    double total =kmValue+minValue;
    minTotal = total - 900;
    maxTotal = total + 900;
    refresh();
  }


  Future<void> setPolyLines() async {
    try {
      PolylineRequest request = PolylineRequest(
        origin: PointLatLng(fromLatLng.latitude, fromLatLng.longitude),
        destination: PointLatLng(toLatLng.latitude, toLatLng.longitude),
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

        addMarker('from', fromLatLng.latitude, fromLatLng.longitude, 'Recoger aquí', '', fromMarker);
        addMarker('to', toLatLng.latitude, toLatLng.longitude, 'Destino', '', toMarker);

        refresh();
      } else {
        utils.Snackbar.showSnackbar(context, 'No se encontró ninguna ruta');
      }
    } catch (e) {
      utils.Snackbar.showSnackbar(context, 'Error al obtener ruta: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    controller.setMapStyle(
        '[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]'
    );
    _mapController.complete(controller);
    await setPolyLines();
  }

  Future<void> animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(latitude, longitude),
        zoom: 15,
      ),
    ));
  }

  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarker(String markerId, double lat, double lng, String title, String content, BitmapDescriptor iconMarker) {
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
