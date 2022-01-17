import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/Screens/Login/components/background.dart';
import 'package:flutterbestplace/components/photo_profil.dart';
import 'package:flutterbestplace/components/progress.dart';
import 'package:flutterbestplace/components/rounded_input_field.dart';
import 'package:flutterbestplace/models/user.dart';
import 'package:get/get.dart';
import 'package:flutterbestplace/Controllers/user_controller.dart';
import 'package:flutterbestplace/components/rounded_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutterbestplace/models/Data.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../constants.dart';
import '../Signup/components/body.dart';
final Reference storageRef=FirebaseStorage.instance.ref();

class Body extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<Body> {
  AuthService _controller = Get.put(AuthService());
  var NewName = null;
  var NewPhone = null;
  var NewAdress = null;
  final _formKey = GlobalKey<FormState>();
  File _image =File("");

  bool isUploading = false;
  String postId = Uuid().v4();
  final picker = ImagePicker();


  getImage() async {
final pickedFile = await picker.getImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960);

    setState(() {_image = File(pickedFile.path);
    });
  }

  getImagegallery() async {
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
  clearImage() {
    setState(() {
      _image = null;
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

  } Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
    storageRef.child("post_$postId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }
  createPostInFireStore({String mediaUrl,String location,String description}){
    var userId = _controller.idController;
    usersRef.doc(userId).set({

      "photoUrl": mediaUrl,

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

    );

    setState(() {
      _image=File("");
      isUploading = false;
      postId = Uuid().v4();

    });
  }

  ///NOTE: Only supported on Android & iOS
  ///Needs image_picker plugin {https://pub.dev/packages/image_picker}
  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: clearImage),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
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
    _controller.userController.value.photoUrl==null? AssetImage("assets/images/profil_defaut.jpg"):CachedNetworkImageProvider(_controller.userController.value.photoUrl),
            ),

          ),

        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                    () => PhotoProfile(
                  imagePath:_controller.userController.value.photoUrl==null ?"https://firebasestorage.googleapis.com/v0/b/bestplace-331512.appspot.com/o/profil_defaut.jpg?alt=media&token=c9ce20af-4910-43cd-b43a-760a5c4b4243":_controller.userController.value.photoUrl,

                  isEdit: true,
                  onClicked: () async {
                    getImagegallery();
                    if(_image!=null){
                      buildUploadForm();
                    }
                  _controller.uploadProfilePicture(_image);
                  },

                ),

              ),

              const SizedBox(height: 24),
              Obx(
                    () => RoundedInputField(
                  hintText: "your name",
                  InitialValue: _controller.userController.value.fullname,
                  icon: Icons.person,
                  onChanged: (value) {
                    NewName = value;
                  },
                ),
              ),
              const SizedBox(height: 24),
              /*    Obx(
          () => RoundedInputField(
            hintText: "_controller.userController.value.email,
            icon: Icons.email,
            onChanged: (value) {
              NewEmail = value;
            },
          ),
        ),*/
              Obx(
                    () => RoundedInputField(
                  hintText: 'your phone',
                  InitialValue: _controller.userController.value.phone,
                  icon: Icons.phone,
                  onChanged: (value) {
                    NewPhone = value;
                  },
                ),
              ),

              Obx(
                    () => RoundedInputField(
                  hintText: 'your adress',
                  InitialValue: _controller.userController.value.adresse,
                  icon: Icons.location_city,
                  onChanged: (value) {
                    NewAdress = value;
                  },
                ),
              ),
              RoundedButton(
                text: "Save",
                press: () async {
                  var fromdata = _formKey.currentState;
                  fromdata.save();
                  var userId = _controller.idController;
                  print("HGKJGVUUKHJHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH: $userId");
                  print("name : $NewName , phone : $NewPhone , adresse : $NewAdress");
                   _controller.updateUser(userId,NewName,NewPhone,NewAdress);
                  Get.toNamed('/profilUser');

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
