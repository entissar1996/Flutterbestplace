import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/models/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutterbestplace/Screens/home.dart';
import 'package:flutterbestplace/components/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';

import '../constants.dart';


class Upload extends StatefulWidget {
  final CUser currentUser;

  Upload({ this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  Position _currentPosition;
  String _currentAddress="";
  AuthService _controller = Get.put(AuthService());

  TextEditingController captionController=TextEditingController();
TextEditingController locationController=TextEditingController();

  File _image = File("");

  bool isUploading = false;
  String postId = Uuid().v4();
  final picker = ImagePicker();

  getImage() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960);

    setState(() {
      this._image = File(pickedFile.path);
    });
  }

  getImagegallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  selectImage(parentcontext) {
    return showDialog(
        context: parentcontext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: getImage,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: getImagegallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: kPrimaryLightColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            "assets/images/upload.svg",
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Create new post",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              color: kPrimaryColor,
              onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      _image = File("");
    });
  }
  Future<File> compressImage(File file) async {
    // Get file path
    // eg:- "Volume/VM/abcd.jpeg"
    final filePath = file.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    return  await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        minWidth: 1000,
        minHeight: 1000,
        quality: 70);

  }
  /*compressImage() async {
   /* final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    dynamic imageFile = Im.decodeImage(_image.readAsBytesSync());
    final compressedImageFile = File("$path/img_$postId.jpg")
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));*/
    final filePath = _image.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      _image.absolute.path, outPath,
      quality: 5,
    );
    print(_image.lengthSync());
    print(result.lengthSync());
    setState(() {_image=result;});

  }
*/
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }
  createPostInFireStore({String mediaUrl,String location,String description}){
    var userId = _controller.idController;
    postsRef.doc(userId).collection("userPosts").doc(postId).set({
  "postId": postId,
  "ownerId":userId,
  "username":_controller.userController.value.fullname,
  "mediaUrl": mediaUrl,
  "description": description,
  "location":location,
  "timestamp":timestamp,
  "likes":{},
});
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    //await compressImage();
    String mediaUrl = await uploadImage(await compressImage(_image));
    createPostInFireStore(
      mediaUrl:mediaUrl,
      location:locationController.text,
      description:captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      _image=File("");
      isUploading = false;
      postId = Uuid().v4();

    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: clearImage),
        title: Text(
          "Caption Post",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17.0,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_image),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration:  _currentAddress == null? InputDecoration(

    hintText:_currentAddress , border: InputBorder.none,): InputDecoration(

    hintText: "Where was this photo taken ?", border: InputBorder.none,)
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
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
          ),
        ],
      ),
    );
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
  }
  @override
  Widget build(BuildContext context) {
    return _image.path == "" ? buildSplashScreen() : buildUploadForm();
  }
}
