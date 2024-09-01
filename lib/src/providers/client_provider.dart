import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';

class ClientProvider {
  late CollectionReference _ref;

  ClientProvider() {
    _ref = FirebaseFirestore.instance.collection('clients');
  }

  Future<void> create(Client client) async {
    try {
      await _ref.doc(client.id).set(client.toJson());
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
