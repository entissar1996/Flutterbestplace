import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterbestplace/Screens/home.dart';
import 'dart:io';
import 'package:flutterbestplace/models/marker.dart';
import 'package:flutterbestplace/models/Data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MarkerController {
  final markerRef = FirebaseFirestore.instance.collection('marker');
  List<MarkerS> Markes = [];

  //var MController = MarkerS();
  Future<void> addMarker(idUser, lat, long) async {
    try {
      await markerRef.doc(idUser).set({
        'id': idUser,
        'latitude': lat,
        'longitude': long,
      }).then((value) => print("Marquer Added"))
          .catchError((error) => print("Failed to add marker: $error"));
    } catch (e) {
      return e.message;
    }
  }

  Future<String> MarkerById(id) async {
    try {
      final markerdata = markerRef.withConverter<MarkerS>(
        fromFirestore: (snapshot, _) => MarkerS.fromJson(snapshot.data()),
        toFirestore: (marker, _) => marker.toJson(),
      );
      MarkerS marker = await markerdata.doc(id).get().then((snapshot) =>
          snapshot.data());
      print(marker.toJson());
      return marker.id;
    } catch (e) {
      print("FAILED GET MARKER");
    }
  }

  Future<List<MarkerS>> MarkerAll() async {
    final markerdata = markerRef.withConverter<MarkerS>(
      fromFirestore: (snapshot, _) => MarkerS.fromJson(snapshot.data()),
      toFirestore: (marker, _) => marker.toJson(),
    );
    QuerySnapshot querySnapshot = await markerRef.get();
    List<QueryDocumentSnapshot> Documents = querySnapshot.docs;
    print(Documents);
    Documents.forEach((element)async{
      print("********************************");
      print(element.id);
      print(element["latitude"]);
      print(element["longitude"]);
      MarkerS marker =MarkerS(
        id:element.id,
        latitude:element["latitude"],
        longitude:element["longitude"],
      );
      print(marker.toJson());
      Markes.add(marker);
   });
    print("liste Markers :");
    print(Markes);
   return Markes;




  }
}/*
  Future MarkerAll() async {
    List<MarkerS> markers;
    final MAsRef = await markerRef.withConverter<MarkerS>(
      fromFirestore: (snapshot, _) => MarkerS.fromJson(snapshot.data()),
      toFirestore: (user, _) => user.toJson(),
    );
    QuerySnapshot querySnapshot = await MAsRef.get();
    List<QueryDocumentSnapshot> Documents = querySnapshot.docs;
    print("++++++++++++++++++++++++++++MarkerAllData++++++++++++++++++++++++++++++++++");
    print(Documents);
    Documents.forEach((marker) async{
      print(marker.toJson());
    });
    return markers;
  }
}*/
/*

Documents.forEach((marker) async{
     MarkerS markerdata = await MAsRef.doc(marker.id).get().then((snapshot) =>
         snapshot.data());
     print(markerdata.toJson());
   });
   for (var snapshot in Documents) {
     MarkerS markerdata = await MAsRef.doc(snapshot.id).get().then((snapshot) =>
         snapshot.data());
     print("++++++++++++++++++++++++++++MarkerAll()++++++++++++++++++++++++++++++++++");
     print(markerdata.toJson());
     markers.add(markerdata);
   }

   return markers;
 }*/
 /*  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('markers').get();
    for (var snapshot in querySnapshot.docs) {
      var documentID = snapshot.id;
      print(snapshot.id);// <-- Document ID
    }
    markerse= <Marker>[
      Marker(markerId:MarkerId(userdata.id),
          position: LatLng(userdata.latitude, userdata.longitude),
          icon:BitmapDescriptor.defaultMarker,
          infoWindow:InfoWindow(title: "HHHHHH")),
    ].toSet();}
    dynamic allmarkers = await controllerMarker.markerRef.doc("6mQ0xU5daniQVMVbxXEB").get();

          Map<String, dynamic> data = allmarkers.data() as Map<String,dynamic>;

          print("documentID----*********************************************************  ${data["latitude"]}");*/


    // Get data from docs and convert map to List
    // final allData = querySnapshot.docs.map((doc) => doc.data());
    /*List <dynamic> liste = allData;
    print("ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ");
    print(liste);
    for (int i = 0; i < liste.length; i++){
      setState(() {
        markerse = <Marker>[
          Marker(markerId:MarkerId(liste[i]['id']),
              position: LatLng(liste[i]['latitude'], liste[i]['longitude']),
              icon:BitmapDescriptor.defaultMarker,
              infoWindow:InfoWindow(title: liste[i]['address'])),
        ].toSet();
      });
      }
  }*/

