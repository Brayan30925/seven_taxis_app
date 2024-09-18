import 'dart:convert';

TravelInfo travelInfoFromJson(String str) => TravelInfo.fromJson(json.decode(str));

String travelInfoToJson(TravelInfo data) => json.encode(data.toJson());

class TravelInfo {
  String id;
  String status;
  String idDriver; // Cambiado a nullable
  String from;
  String to;
  String idTravelHistory;
  double fromLat;
  double fromLng;
  double toLat;
  double toLng;
  double price;

  TravelInfo({
    required this.id,
    required this.status,
    required this.idDriver,
    required this.from,
    required this.to,
    required this.idTravelHistory,
    required this.fromLat,
    required this.fromLng,
    required this.toLat,
    required this.toLng,
    required this.price,
  });

  factory TravelInfo.fromJson(Map<String, dynamic> json) => TravelInfo(
    id: json["id"],
    status: json["status"],
    idDriver: json["idDriver"], // Permite que sea null
    from: json["from"],
    to: json["to"],
    idTravelHistory: json["idTravelHistory"],
    fromLat: json["fromLat"]?.toDouble() ?? 0,
    fromLng: json["fromLng"]?.toDouble() ?? 0,
    toLat: json["toLat"]?.toDouble() ?? 0,
    toLng: json["toLng"]?.toDouble() ?? 0,
    price: json["price"]?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "idDriver": idDriver,
    "from": from,
    "to": to,
    "idTravelHistory": idTravelHistory,
    "fromLat": fromLat,
    "fromLng": fromLng,
    "toLat": toLat,
    "toLng": toLng,
    "price": price,
  };
}
