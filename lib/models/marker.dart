import 'package:cloud_firestore/cloud_firestore.dart';

class MarkerS {
  String id;
  String name;
  String address;
  double latitude;
  double longitude;

  MarkerS({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory MarkerS.fromDocument(DocumentSnapshot doc){
    return MarkerS(id: doc['id'],name: doc['name'],address: doc['address'],latitude: doc['latitude'],longitude: doc['longitude']);
  }
  MarkerS.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {
    id = documentSnapshot.id;
    name = documentSnapshot["name"];
    address = documentSnapshot["address"];
    latitude = documentSnapshot["latitude"];
    longitude = documentSnapshot["longitude"];
  }

  factory MarkerS.fromJson(Map<String, dynamic> json) {
    return MarkerS(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
    'name': name,
    'address': address,
    'latitude': latitude,
        'longitude': longitude,
      };
}
