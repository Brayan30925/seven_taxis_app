import 'package:flutter/material.dart';
import 'dart:async';
import 'package:seven_taxis_app/src/providers/travel_history_provider.dart';
import 'package:seven_taxis_app/src/utils/snackbar.dart' as utils;
import '../../../models/TravelHistory.dart';

class DriverTravelCalificationController {
  late BuildContext context;
  GlobalKey<ScaffoldState> key = GlobalKey();
  late Function refresh;

  late String idTravelHistory;
  late TravelHistoryProvider _travelHistoryProvider;
  TravelHistory? travelHistory;
  double? calification;

  Future<void> init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider = TravelHistoryProvider();

    final route = ModalRoute.of(context);
    if (route == null) {
      print('ModalRoute.of(context) es nulo.');
      return;
    }

    final arguments = route.settings.arguments;
    if (arguments != null) {
      if (arguments is String) {
        idTravelHistory = arguments;
        print('ID DEL TRAVEL HISTORY: $idTravelHistory');
        await getTravelHistory();
      } else {
        print('Los argumentos proporcionados no son del tipo esperado (String).');
      }
    } else {
      print('No se encontró ID del Travel History en los argumentos.');
    }
  }

  void calificate() async {
    if (calification == null) {
      utils.Snackbar.showSnackbar(context, 'Por favor califica a tu cliente');
      return;
    }
    if (calification == 0) {
      utils.Snackbar.showSnackbar(context, 'La calificación mínima es 1');
      return;
    }

    Map<String, dynamic> data = {
      'calificationClient': calification ?? 1
    };

    try {
      await _travelHistoryProvider.update(data, idTravelHistory);
      Navigator.pushNamedAndRemoveUntil(
        context,
        'driver/map',
            (route) => false,
      );
    } catch (e) {
      utils.Snackbar.showSnackbar(context, 'Error al calificar: $e');
    }
  }

  Future<void> getTravelHistory() async {
    try {
      travelHistory = await _travelHistoryProvider.getById(idTravelHistory);
      if (travelHistory != null) {
        print('Travel History cargado: ${travelHistory!.id} ${travelHistory!.price}');
      } else {
        print('No se encontró información de Travel History');
      }
    } catch (e) {
      print('Error al obtener Travel History: $e');
    }

    if (context.mounted) {
      refresh();
    }
  }
}
