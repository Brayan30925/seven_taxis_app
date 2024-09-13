import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';
import 'package:seven_taxis_app/src/utils/shared_pref.dart';

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

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _sharedPref = SharedPref();
    _clientProvider = ClientProvider();
    await _sharedPref.save('isNotification', 'false');

    Map<String, dynamic> arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    print('************************$arguments********************************');

    // Asignación segura con valores predeterminados
    from = arguments['origin'] ?? 'Origen desconocido';
    to = arguments['destination'] ?? 'Destino desconocido';
    idClient = arguments['idClient'] ?? '';

    getClientInfo();
  }

  void getClientInfo() async {
    client = await _clientProvider.getById(idClient);
    refresh(); // Llamada para actualizar la vista después de obtener la información del cliente
  }
}
