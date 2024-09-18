import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/models/driver.dart';
import 'package:seven_taxis_app/src/models/TravelHistory.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';
import 'package:seven_taxis_app/src/providers/travel_history_provider.dart';




class DriverHistoryDetailController {
  Function? refresh;
  BuildContext? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TravelHistoryProvider? _travelHistoryProvider;
  MyAuthProvider? _authProvider;
  DriverProvider? _driverProvider;

  TravelHistory? travelHistory;
  Driver? driver;

  String? idTravelHistory;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider =  TravelHistoryProvider();
    _authProvider =  MyAuthProvider();
    _driverProvider=DriverProvider();

    idTravelHistory = ModalRoute.of(context)?.settings.arguments as String;

    getTravelHistoryInfo();
  }

  void getTravelHistoryInfo() async {
    travelHistory = await  _travelHistoryProvider?.getById(idTravelHistory!);
    getClientInfo(travelHistory?.idDriver ?? '');
  }

  void getClientInfo(String idClient) async {
    driver = await _driverProvider?.getById(idClient);
    refresh!();
  }

}

