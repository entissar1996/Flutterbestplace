import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterbestplace/constants.dart';
//google maps :
import 'package:google_maps_flutter/google_maps_flutter.dart';
//geolocator :
import 'package:geolocator/geolocator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
//geocoding : les informations de position
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  var _controller = Completer();
  GoogleMapController gmc;
  StreamSubscription<Position> ps;
  Position cp;
  var lat;
  var long;
  CameraPosition _kGooglePlex;
  Set<Marker> marker = {};

  //start polyline :
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyCNKbddvj20I2bn-fJiCZWGFBRVv2DbOns";
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
    lat = cp.latitude;
    long = cp.longitude;
    _kGooglePlex = CameraPosition(
      target: LatLng(35.5049812224640, 11.043470115161800),
      zoom: 4,
    );
    setState(() {
      marker.add(Marker(
          markerId: MarkerId("1"),
          infoWindow: InfoWindow(
              title: ("place en mahdia 1"),
              onTap: () {
                print('marq 1 : place en mahdia 1');
              }),
          position: LatLng(35.5049812224640, 11.043470115161800)));
    });
  }

  changemaker(newlat, newlong) {
    marker.clear();
    // marker.remove(Marker(markerId: MarkerId("1")));
    marker.add(
        Marker(markerId: MarkerId("1"), position: LatLng(newlat, newlong)));
    gmc.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(newlat, newlong),
          zoom: 4,
        ),
      ),
    );
    setState(() {});
  }

  @override
  void initState() {
    ps = Geolocator.getPositionStream().listen((Position position) {
      changemaker(position.latitude, position.longitude);
    });
    getPer();
    getLateAndLate();
    getPolyline();
    super.initState();
  }

//marker :
  /* Set<Marker> mymarker = {
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
        position: LatLng(35.51287634344423, 11.038556308246598)),*/
  /*  Marker(
        markerId: MarkerId("2"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
            title: ("place en mahdia 2"),
            onTap: () {
              print('marq 2 : place en mahdia 2');
            }),
        position: LatLng(35.5049812224652, 11.043470115161881)),
  };*/

  addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        width: 1,
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(35.5049812224640, 11.043470115161800),
        PointLatLng(35.5049812224652, 11.043470115161881),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    // if (result.points.isNotEmpty) {
    // result.points.forEach((PointLatLng point) {
    polylineCoordinates.add(LatLng(35.5049812224640, 11.043470115161800));
    polylineCoordinates.add(LatLng(35.5049812224652, 11.043470115161881));
    //  });
    //}
    addPolyLine();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        children: [
          _kGooglePlex == null
              ? CircularProgressIndicator()
              : Container(
            child: GoogleMap(
              polylines: Set<Polyline>.of(polylines.values),
              markers: marker,
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              /*    onTap: (LatLng t) {
                      print('t1 : ${t.latitude}');
                      print('t1 : ${t.longitude}');
                      mymarker.remove(Marker(markerId: MarkerId("1")));
                      mymarker
                          .add(Marker(markerId: MarkerId("1"), position: t));
                      print('t2 : ${t.latitude}');
                      print('t2 : ${t.longitude}');
                    },*/
              onMapCreated: (controller) {
                _controller.complete(controller);
              },
            ),
            height: 500,
            width: 400,
          ),
          ElevatedButton(
            child: Text(
              "button",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              print(lat);
              print(long);

              /*List<Placemark> placemarks = await placemarkFromCoordinates(
                  35.51287634344423, 11.038556308246598);
              print(" placemarks : ${placemarks} ");*/
              // cp = await getLateAndLate();

              //geocoding :
              /*  List<Placemark> placemarks = await placemarkFromCoordinates(
                  35.51287634344423, 11.038556308246598);
              print(" placemarks : ${placemarks} ");*/
              /*   List<Location> locations = await locationFromAddress("haddad mahdia");
              print("position : ${placemarks} ");*/
            },
            style: ElevatedButton.styleFrom(
                primary: kPrimaryColor,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w100)),
          ),
        ],
      ),
    );
  }

/*google maps
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
      ),
    );
  }*/
}

//KeyAPI android : AIzaSyAp6_rBkKNIbEe0QLj5rn5IuBYV_EpoJr4
//keyAPI web: AIzaSyCNKbddvj20I2bn-fJiCZWGFBRVv2DbOns
