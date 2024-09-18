import 'package:flutter/material.dart';
import 'package:seven_taxis_app/src/providers/auth_provider.dart';
import 'package:seven_taxis_app/src/providers/travel_history_provider.dart';
import 'package:seven_taxis_app/src/models/TravelHistory.dart';

class ClientHistoryController {
  Function? refresh;  // Hacer refresh opcional
  late BuildContext context;
  GlobalKey<ScaffoldState> key =  GlobalKey<ScaffoldState>();

  TravelHistoryProvider? _travelHistoryProvider;
  MyAuthProvider? _authProvider;

  Future<void> init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider = TravelHistoryProvider();
    _authProvider = MyAuthProvider();

    // Verificar que refresh no sea null antes de llamarlo
    if (this.refresh != null) {
      this.refresh!();
    }
  }

  Future<List<TravelHistory>> getAll() async {
    // Verificar que _authProvider no sea null antes de usarlo
    if (_authProvider != null && _authProvider!.getUser() != null) {
      return await _travelHistoryProvider!.getByIdClient(_authProvider!.getUser()!.uid);
    } else {
      // En caso de que haya algún problema, retornar una lista vacía
      return [];
    }
  }
  void goToDetailHistory(String id){
    Navigator.pushNamed(context, 'client/history/detail',arguments: id);
  }
}
