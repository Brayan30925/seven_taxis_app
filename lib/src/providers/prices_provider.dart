import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_taxis_app/src/models/prices.dart';

class PricesProvider{


  late CollectionReference _ref;

  PricesProvider(){
    _ref = FirebaseFirestore.instance.collection('Prices');

  }
  Future<Prices> getAll() async {
    DocumentSnapshot document = await _ref.doc('info').get();

    // Asegúrate de que el valor no sea nulo y realiza un casting seguro
    Map<String, dynamic> data = document.data() as Map<String, dynamic>? ?? {};

    Prices prices = Prices.fromJson(data);
    return prices;
  }

}