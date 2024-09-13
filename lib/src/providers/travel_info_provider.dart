import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_taxis_app/src/models/travel_info.dart';

class TravelInfoProvider {
  late CollectionReference _ref;

  TravelInfoProvider() {
    _ref = FirebaseFirestore.instance.collection('TravelInfo');
  }

  Future<void> create(TravelInfo travelInfo) async {
    try {
      await _ref.doc(travelInfo.id).set(travelInfo.toJson());
    } on FirebaseException catch (error) {
      // Manejo de errores específicos de Firebase
      return Future.error(error.message ?? 'Error desconocido al crear TravelInfo.');
    } catch (error) {
      // Manejo de cualquier otro tipo de error
      return Future.error('Error inesperado: $error');
    }
  }
}
