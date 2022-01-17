import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

import '../../Controllers/maps_controller.dart';
import '../../models/marker.dart';
 class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() =>_MapsPageState();

}
class _MapsPageState extends State<MapsPage>{
  GoogleMapController myController;
  MarkerController controllerMarker = MarkerController();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Set<Marker> markerse = {};

  void initMarker(latitude, longitude ,address,specifyId)async{
  var markerIdval=specifyId;
  final MarkerId markerId=MarkerId(
      markerIdval);
  final Marker marker=Marker(
    markerId:markerId,
    position:LatLng(latitude, longitude),
    infoWindow:InfoWindow(title:"shpos",snippet:address)
  );
  setState(() {markers[markerId]=marker;});
}
  getMarkerData()async{
/*    FirebaseFirestore.instance.collection('markers').get().then((myMockData){
      if(myMockData.docs.isNotEmpty){

        for(int i=0;i<myMockData.docs.length;i++){
          print("*******************************************");
          print(markers["6mQ0xU5daniQVMVbxXEB"]);
          print(myMockData.docs[i]["latitude"]);
         initMarker(myMockData.docs[i].data().keys,myMockData.docs[i].data(),"address",myMockData.docs[i].id);
        }
      }
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('markers').get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data());
    for(int i=0;i<allData.length;i++){

      print("*******************************************");
      print(markers["6mQ0xU5daniQVMVbxXEB"]);

      print(allData.toList());
      print(allData);
      Map jsonData = json.decode(allData.elementAt(1)) as Map;

      print(jsonData['latitude'].toString());

      /*initMarker(allData[i].,myMockData.docs[i].data(),"address",myMockData.docs[i].id);*/

    }*/
  List <dynamic> liste =await controllerMarker.MarkerAll();
  print("ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ");
  print(liste);
  for (int i = 0; i < liste.length; i++){
    markerse.add(Marker(  markerId: MarkerId(liste[i]['id']),
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        position: LatLng(liste[i]['latitude'], liste[i]['longitude'])));
  }
  }
  Future<void> getMarker() async{
    /*QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('markers').get();
    for (var snapshot in querySnapshot.docs) {
      var documentID = snapshot.id;
      print(snapshot.id);// <-- Document ID
    }*/
    final MAsRef = await FirebaseFirestore.instance.collection('markers').withConverter<MarkerS>(
      fromFirestore: (snapshot, _) => MarkerS.fromJson(snapshot.data()),
      toFirestore: (user, _) => user.toJson(),
    );
    MarkerS userdata = await MAsRef.doc("6mQ0xU5daniQVMVbxXEB").get().then((snapshot) => snapshot.data());
    print("***********User**************");
    print(userdata.toJson());
     print(userdata.longitude);
    /*dynamic allmarkers = await controllerMarker.markerRef.doc("6mQ0xU5daniQVMVbxXEB").get();

          Map<String, dynamic> data = allmarkers.data() as Map<String,dynamic>;

          print("documentID----*********************************************************  ${data["latitude"]}");
*/

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
      }*/
  }
  void initState(){
  //getMarkerData();
  //controllerMarker.MarkerAll();

  super.initState();
  }
  @override
  Widget build(BuildContext context) {
    getMarker();
    return  Scaffold(
      body:GoogleMap(
          markers:markerse,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(21.1458,79.2882),
          zoom:4,
        ),
        onMapCreated: (GoogleMapController controller) {
          myController = controller;
        },
      ),
    );

  }

}
