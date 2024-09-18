import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeoFireProvider{
  late CollectionReference _ref;
  late GeoFlutterFire _geo;

  GeoFireProvider(){
    _ref =FirebaseFirestore.instance.collection('Location');
    _geo = GeoFlutterFire();
  }
  Future<void>create(String id,double lat,double lon){
    GeoFirePoint myLocation = _geo.point(latitude: lat, longitude: lon);
    return _ref.doc(id).set({'status': 'drivers_available','position': myLocation.data});
  }
  Future<void>createWorking(String id,double lat,double lon){
    GeoFirePoint myLocation = _geo.point(latitude: lat, longitude: lon);
    return _ref.doc(id).set({'status': 'drivers_working','position': myLocation.data});
  }
  Stream<List<DocumentSnapshot>>getNearbyDrivers(double lat,double long, double radius){
    GeoFirePoint center = _geo.point(latitude: lat, longitude: long);
    return _geo.collection(
        collectionRef: _ref.where('status',isEqualTo: 'drivers_available' )
    ).within(center: center, radius: radius, field: 'position');
  }

  Future<void> delete(String id){
    return _ref.doc(id).delete();
  }
  Stream<DocumentSnapshot> getlocationByIdStream(String id){
    return _ref.doc(id).snapshots(includeMetadataChanges: true);

  }


}