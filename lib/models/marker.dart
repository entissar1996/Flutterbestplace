import 'package:cloud_firestore/cloud_firestore.dart';

class MarkerS {
  String id;
  double latitude;
  double longitude;

  MarkerS({
    this.id,
    this.latitude,
    this.longitude,
  });

  factory MarkerS.fromDocument(DocumentSnapshot doc){
    return MarkerS(id: doc['id'],latitude: doc['latitude'],longitude: doc['longitude']);
  }
  MarkerS.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {
    id = documentSnapshot.id;
    latitude = documentSnapshot["latitude"];
    longitude = documentSnapshot["longitude"];
  }

  factory MarkerS.fromJson(Map<String, dynamic> json) {
    return MarkerS(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
      };
}
