import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/models/driver.dart';

class DriverProvider {
  late CollectionReference _ref;

  DriverProvider() {
    _ref = FirebaseFirestore.instance.collection('Drivers');
  }

  Future<void> create(Driver driver) async {
    try {
      await _ref.doc(driver.id).set(driver.toJson());
    } catch (error) {
      String errorMessage;
      if (error is FirebaseException) {
        errorMessage = error.message ?? 'Unknown error';
      } else {
        errorMessage = 'Unknown error';
      }
      return Future.error(errorMessage);
    }
  }
  Stream<DocumentSnapshot> getByIdStream(String id){
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<Driver?> getById(String id) async {
    try {
      // Obtiene el documento de la colección por ID
      DocumentSnapshot document = await _ref.doc(id).get();

      // Verifica si el documento existe
      if (!document.exists) {
        // Retorna null si el documento no existe
        return null;
      }

      // Verifica si los datos del documento son del tipo Map<String, dynamic>
      Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

      if (data == null) {
        // Retorna null si los datos no son válidos
        return null;
      }
      // Verifica si todos los campos necesarios están presentes
      if (!data.containsKey('id') || !data.containsKey('username') ||
          !data.containsKey('email')) {
        // Retorna null si faltan campos necesarios
        return null;
      }

      // Crea el objeto Client usando los datos del documento

      print('estoy enviando el conductor');
      Driver driver = Driver.fromJson(data);
      return driver;
    }catch(error){
      print("Error al obtener el conductor: $error");
      return null;
    }

    }
  Future<void>update (Map<String,dynamic>data,String id){
    return _ref.doc(id).update(data);
  }
}
