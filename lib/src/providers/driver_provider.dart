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
}
