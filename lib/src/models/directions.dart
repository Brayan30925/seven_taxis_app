import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

class DataInfo {
  late String text;
  late int value;

  DataInfo({
    required this.text,
    required this.value,
  });

  DataInfo.fromJsonMap(Map<String, dynamic> json) {
    text = json['text'] ?? '';
    value = json['value'] ?? 0;
  }
}

class Direction {
  late DataInfo distance;
  late DataInfo duration;
  late String startAddress;
  late String endAddress;
  late LatLng startLocation;
  late LatLng endLocation;

  Direction({
    required this.startAddress,
    required this.endAddress,
    required this.startLocation,
    required this.endLocation,
  });

  Direction.fromJsonMap(Map<String, dynamic> json) {
    distance = DataInfo.fromJsonMap(json['distance'] ?? {});
    duration = DataInfo.fromJsonMap(json['duration'] ?? {});
    startAddress = json['start_address'] ?? '';
    endAddress = json['end_address'] ?? '';
    startLocation = LatLng(
      lat: json['start_location']?['lat'] ?? 0.0,
      lng: json['start_location']?['lng'] ?? 0.0,
    );
    endLocation = LatLng(
      lat: json['end_location']?['lat'] ?? 0.0,
      lng: json['end_location']?['lng'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'distance': {
      'text': distance.text,
      'value': distance.value,
    },
    'duration': {
      'text': duration.text,
      'value': duration.value,
    },
    'start_address': startAddress,
    'end_address': endAddress,
    'start_location': {
      'lat': startLocation.lat,
      'lng': startLocation.lng,
    },
    'end_location': {
      'lat': endLocation.lat,
      'lng': endLocation.lng,
    },
  };
}
