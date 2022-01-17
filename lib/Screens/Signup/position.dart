import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/constants.dart';
import 'package:flutterbestplace/Screens/Signup/components/background.dart';
import 'package:flutterbestplace/components/rounded_button.dart';
import 'package:flutterbestplace/components/rounded_input_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutterbestplace/models/Data.dart';
import 'package:flutterbestplace/Controllers/maps_controller.dart';
import 'package:flutterbestplace/Controllers/user_controller.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/components/Dropdown_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PositionAdd extends StatefulWidget {
  @override
  State<PositionAdd> createState() => PositionState();
}

class PositionState extends State<PositionAdd> {
  var phone;
  var adresse;
  var category;
  var loca;
  bool _isOpen = false;
  final _formKey = GlobalKey<FormState>();
  CameraPosition _kGooglePlex;
  Position cp;
  var lat;
  var long;
  Set<Marker> marker = {};
  AuthService _controller = Get.put(AuthService());
  PanelController _panelController = PanelController();
  TextEditingController locationController=TextEditingController();


  //UserController _controller = UserController();
  MarkerController controllerMarker = MarkerController();

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
      target: LatLng(lat, long),
      zoom: 15.4746,
    );
    marker.add(Marker(
        markerId: MarkerId("1"),
        draggable: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onDragEnd: (LatLng t) {
          lat = t.latitude;
          long = t.longitude;
          print(lat);
          print(long);
        },
        position: LatLng(lat, long)));
    setState(() {});
  }
  getUserLocation()async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark placemark = placemarks[0];
    String completeAddress = '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    locationController.text = completeAddress;
    loca=completeAddress;
  }
  @override
  void initState() {
    getPer();
    getLateAndLate();
    getUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return new Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _kGooglePlex == null
              ? CircularProgressIndicator()
              : Container(
                  child: GoogleMap(
                    markers: marker,
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                  ),
                  height: 500,
                ),
          FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: 0.3,
            child: Container(
              color: Colors.white,
            ),
          ),
          SlidingUpPanel(
            controller: _panelController,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(32),
              topLeft: Radius.circular(32),
            ),
            minHeight: MediaQuery.of(context).size.height * 0.35,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            body: GestureDetector(
              onTap: () => _panelController.close(),
              child: Container(
                color: Colors.transparent,
              ),
            ),
            panelBuilder: (ScrollController controller) =>
                _panelBody(controller),
            onPanelSlide: (value) {
              if (value >= 0.2) {
                if (!_isOpen) {
                  setState(() {
                    _isOpen = true;
                  });
                }
              }
            },
            onPanelClosed: () {
              setState(() {
                _isOpen = false;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Panel Body
  SingleChildScrollView _panelBody(ScrollController controller) {
    double hPadding = 40;

    return SingleChildScrollView(
      controller: controller,
      physics: ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            height: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Location",
                  style: TextStyle(
                    fontFamily: 'NimbusSanL',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
              ],
            ),
          ),
          Formbuild(context),
        ],
      ),
    );
  }

  Widget Formbuild(BuildContext context) {
    List<String> categorys = [
      "food",
      "clothes",
      "sport",
      "hotel",
    ];
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RoundedInputField(
            hintText: "Your Adresse",
            icon: Icons.room,
            onChanged: (value) {
              if (locationController.text==null){
              adresse = value;}else{
                adresse =loca;
              }
            },
            validate: (value) {
              if (value.isEmpty) {
                return 'Enter your Adresse';
              } else {
                return null;
              }
            },
          ),
          RaisedButton.icon(
            label: Text(
              "Use Current Location",
              style: TextStyle(color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            color: kPrimaryColor,
            onPressed: getUserLocation,
            icon: Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
          RoundedInputField(
              hintText: "Your Phone",
              icon: Icons.phone,
              KeyboardType: TextInputType.number,
              onChanged: (value) {
                phone = value;
              },
              validate: (value) {
                if (value.isEmpty) {
                  return 'Enter your phone number';
                } else if (RegExp(r'([0-9]{8}$)').hasMatch(value)) {
                  return null;
                } else {
                  return 'Enter valide phone number';
                }
              }),
          DropdownWidget(
            HintText: Text("Your category"),
            Items: categorys,
            onChanged: (value) {
              category = value;
            },
            valueSelect: category,
            validate: (value) {
              if (value == null) {
                return 'Choose your City';
              } else {
                return null;
              }
            },
          ),
          RoundedButton(
            text: "SAVE",
            press: () async {
              var fromdata = _formKey.currentState;
              if (fromdata.validate()) {
                fromdata.save();
                print("******************$phone");
                print("******************$adresse");
                print("******************$category");
                await _controller.createPlace(
                    _controller.idController, phone, adresse, category);
                await controllerMarker.addMarker(
                    _controller.idController, lat, long);
                Get.toNamed('/home');
              } else {
                print("not valid");
              }
            },
          ),
        ],
      ),
    );
  }
}
