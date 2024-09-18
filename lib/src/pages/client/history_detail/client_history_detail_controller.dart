import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/models/driver.dart';
import 'package:seven_taxis_app/src/models/TravelHistory.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/providers/travel_history_provider.dart';

import '../../../providers/client_provider.dart';


class DriverHistoryDetailController {
  Function? refresh;
  BuildContext? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TravelHistoryProvider? _travelHistoryProvider;
  MyAuthProvider? _authProvider;
  ClientProvider? _clientProvider;

  TravelHistory? travelHistory;
  Client? client;

  String? idTravelHistory;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider =  TravelHistoryProvider();
    _authProvider =  MyAuthProvider();
    _clientProvider=ClientProvider();

    idTravelHistory = ModalRoute.of(context)?.settings.arguments as String;

    getTravelHistoryInfo();
  }

  void getTravelHistoryInfo() async {
    travelHistory = await  _travelHistoryProvider?.getById(idTravelHistory!);
    getClientInfo(travelHistory?.idClient ?? '');
  }

  void getClientInfo(String idDriver) async {
    client = await _clientProvider?.getById(idDriver);
    refresh!();
  }

}

