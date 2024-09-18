import 'dart:convert';

TravelHistory travelHistoryFromJson(String str) => TravelHistory.fromJson(json.decode(str));

String travelHistoryToJson(TravelHistory data) => json.encode(data.toJson());

class TravelHistory {
  TravelHistory({
    this.id,
    this.idClient,
    this.idDriver,
    this.from,
    this.to,
    this.timestamp,
    this.price,
    this.calificationClient,
    this.calificationDriver,
    this.nameDriver,
    this.nameClient
  });

  String? id;
  String? idClient;
  String? idDriver;
  String? from;
  String? to;
  String? nameDriver;
  String? nameClient;
  int? timestamp;
  double? price;
  double? calificationClient;
  double? calificationDriver;

  // El factory que maneja valores nulos correctamente
  factory TravelHistory.fromJson(Map<String, dynamic> json) => TravelHistory(
    id: json["id"] ?? '',
    idClient: json["idClient"] ?? '',
    idDriver: json["idDriver"] ?? '',
    from: json["from"] ?? '',
    to: json["to"] ?? '',
    nameDriver: json["nameDriver"] ?? '',
    nameClient: json["nameClient"] ?? '',
    timestamp: json["timestamp"] ?? 0,
    price: json["price"]?.toDouble() ?? 0.0,
    calificationClient: json["calificationClient"]?.toDouble() ?? 0.0,
    calificationDriver: json["calificationDriver"]?.toDouble() ?? 0.0,
  );

  // Conversión a JSON asegurando que no haya valores nulos
  Map<String, dynamic> toJson() => {
    "id": id ?? '',
    "idClient": idClient ?? '',
    "idDriver": idDriver ?? '',
    "from": from ?? '',
    "to": to ?? '',
    "nameDriver": nameDriver ?? '',
    "nameClient": nameClient ?? '',
    "timestamp": timestamp ?? 0,
    "price": price ?? 0.0,
    "calificationClient": calificationClient ?? 0.0,
    "calificationDriver": calificationDriver ?? 0.0,
  };
}
