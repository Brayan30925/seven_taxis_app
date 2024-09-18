import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_taxis_app/src/models/driver.dart';
import 'package:seven_taxis_app/src/models/travel_info.dart';

class TravelInfoProvider {
  late CollectionReference _ref;

  TravelInfoProvider() {
    _ref = FirebaseFirestore.instance.collection('TravelInfo');
  }
  Stream<DocumentSnapshot>getByidStream(String id){
    return _ref.doc(id).snapshots(includeMetadataChanges: true);

  }
  Future<TravelInfo?> getById(String id) async {
    try {
      // Obtiene el documento de la colección por ID
      DocumentSnapshot document = await _ref.doc(id).get();

      // Verifica si el documento existe
      if (!document.exists) {
        print('********** documento no exites travel***********************************');
        return null;
      }

      // Verifica si los datos del documento son del tipo Map<String, dynamic>
      Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

      if (data == null) {
        // Retorna null si los datos no son válidos
        return null;
      }



      // Crea el objeto TravelInfo usando los datos del documento
      print('Estoy enviando el TravelInfo');
      TravelInfo travelInfo = TravelInfo.fromJson(data);
      return travelInfo;
    } catch (error) {
      print("Error al obtener el TravelInfo: $error");
      return null;
    }
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
  Future<void>update(Map<String,dynamic>data ,String id){
    return _ref.doc(id).update(data);
  }

}
