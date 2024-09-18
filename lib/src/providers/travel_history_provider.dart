import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_taxis_app/src/models/TravelHistory.dart';
import 'package:seven_taxis_app/src/models/cliente.dart';
import 'package:seven_taxis_app/src/models/driver.dart';
import 'package:seven_taxis_app/src/providers/client_provider.dart';
import 'package:seven_taxis_app/src/providers/driver_provider.dart';

class TravelHistoryProvider {
  final CollectionReference _ref = FirebaseFirestore.instance.collection('TravelHistory');

  TravelHistoryProvider();


  Future<String> create(TravelHistory travelHistory) async {
    try {
      String id = _ref.doc().id;
      travelHistory.id = id;
      await _ref.doc(travelHistory.id).set(travelHistory.toJson());
      return id;
    } on FirebaseException catch (error) {
      return Future.error('Error al crear el historial de viaje: ${error.message}');
    } catch (error) {
      return Future.error('Error inesperado: $error');
    }
  }

  Future<List<TravelHistory>> getByIdClient(String idClient) async {
    try {
      QuerySnapshot querySnapshot = await _ref
          .where('idClient', isEqualTo: idClient)
          .orderBy('timestamp', descending: false)
          .get();

      List<Map<String, dynamic>> allData = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      List<TravelHistory> travelHistoryList = allData
          .map((data) => TravelHistory.fromJson(data))
          .toList();

      for (TravelHistory travelHistory in travelHistoryList){
        DriverProvider driverProvider = DriverProvider();
        Driver? driver = await driverProvider.getById(travelHistory.idDriver ?? '');
        travelHistory.nameDriver=driver?.username;
      }

      return travelHistoryList;
    } catch (error) {
      return Future.error('Error al obtener los historiales: $error');
    }
  }Future<List<TravelHistory>> getByIdDriver(String idDriver) async {
    try {
      QuerySnapshot querySnapshot = await _ref
          .where('idDriver', isEqualTo: idDriver)
          .orderBy('timestamp', descending: false)
          .get();

      List<Map<String, dynamic>> allData = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      List<TravelHistory> travelHistoryList = allData
          .map((data) => TravelHistory.fromJson(data))
          .toList();

      for (TravelHistory travelHistory in travelHistoryList){
        ClientProvider clientProvider = ClientProvider();
        Client? client = await clientProvider.getById(travelHistory.idClient ?? '');
        travelHistory.nameClient=client?.username;
      }

      return travelHistoryList;
    } catch (error) {
      return Future.error('Error al obtener los historiales: $error');
    }
  }

  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<TravelHistory?> getById(String id) async {
    try {
      DocumentSnapshot document = await _ref.doc(id).get();
      if (document.exists) {
        return TravelHistory.fromJson(document.data() as Map<String, dynamic>);
      }
      return null;
    } catch (error) {
      return Future.error('Error al obtener el historial de viaje: $error');
    }
  }

  Future<void> update(Map<String, dynamic> data, String id) async {
    try {
      await _ref.doc(id).update(data);
    } catch (error) {
      return Future.error('Error al actualizar el historial: $error');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _ref.doc(id).delete();
    } catch (error) {
      return Future.error('Error al eliminar el historial: $error');
    }
  }
}
