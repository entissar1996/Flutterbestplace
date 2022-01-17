import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/constants.dart';
import 'package:flutterbestplace/models/marker.dart';
//google maps :
import 'package:google_maps_flutter/google_maps_flutter.dart';
//geolocator :
import 'package:geolocator/geolocator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutterbestplace/Controllers/maps_controller.dart';

class AllMarkers extends StatefulWidget {
  @override
  State<AllMarkers> createState() => getAllMarkersState();
}

class getAllMarkersState extends State<AllMarkers> {
  var _controller = Completer();
  MarkerController controllerMarker = MarkerController();
  CameraPosition _kGooglePlex;
  Position cp;
  Set<Marker> markers = {};
  GoogleMapController myController;
  MarkerController controllerMarkere = MarkerController();

  populateClients() {
    var clients = [];
    FirebaseFirestore.instance.collection('marker').get().then((docs) {
      if (docs.docs.isNotEmpty) {
        for (int i = 0; i < docs.docs.length; ++i) {
          clients.add(docs.docs[i].data);
          //initMarker(docs.docs[i].data,docs.docs[i].id);
        }
      }
    });
  }
//geolocator : funnction permission
  Future getPer() async {
    bool services;
    LocationPermission per;
    services = await Geolocator.isLocationServiceEnabled();
    if (services == false) {
      AwesomeDialog(
        context: context,
        title: 'services',
        body: Text('Activate the localisation in your smartphone'),
      )..show();
      if (per == LocationPermission.denied) {
        per = await Geolocator.requestPermission();
      }
    }
    return per;
  }

//geolocator :function de  latitude and longitude
  Future<Position> getLateAndLate() async {
    cp = await Geolocator.getCurrentPosition().then((value) => value);
    _kGooglePlex = CameraPosition(
      target: LatLng(cp.latitude, cp.longitude),
      zoom: 6,
    );

    markers.add(Marker(
        markerId: MarkerId("2"),icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), position: LatLng(cp.latitude, cp.longitude)));
  }

  getAllMarker() async {
    List<MarkerS> listeMarker = await controllerMarker.MarkerAll();
    listeMarker.forEach((marker) {
      print("*******************MarkerLIste**************************");
      print(marker.toJson());
      var i=1;
      markers.add(Marker(
          markerId: MarkerId("$i"),
          icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          position: LatLng(marker.latitude, marker.longitude)));
      print(markers);
      i++;
    });
  }


  /*markers = {
  Marker(
  markerId: MarkerId("1"),
  draggable: true,
  onDragEnd: (LatLng t) {
  print("Drag end :");
  print('${t.latitude}');
  print('${t.longitude}');
  },
  infoWindow: InfoWindow(
  title: ("place en mahdia 1"),
  onTap: () {
  print('marq 1 : place en mahdia 1');
  }),
  position: LatLng(35.51287634344423, 11.038556308246598)),
  Marker(
        markerId: MarkerId("2"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
            title: ("place en mahdia 2"),
            onTap: () {
              print('marq 2 : place en mahdia 2');
            }),
        position: LatLng(35.5049812224652, 11.043470115161881)),
  };*/

  @override
  void initState() {
    getPer();
    getLateAndLate();
    getAllMarker();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return new  Scaffold(
      body: Column(
        children: [
          _kGooglePlex == null
              ? CircularProgressIndicator()
              : Container(
                  child: GoogleMap(
                    markers: markers,
                    mapType: MapType.normal,
                    onTap: (LatLng t) {
                      print('t1 : ${t.latitude}');
                      print('t1 : ${t.longitude}');
                    },
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (controller) {
                      _controller.complete(controller);
                    },
                    polylines: {
                      Polyline(polylineId: const PolylineId("over"), color: Colors.red,width: 5)
                    },
                  ),
                  height: 746,
                ),

        ],
      ),
    );
  }
}
