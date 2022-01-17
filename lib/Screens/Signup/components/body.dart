import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/Screens/Signup/components/background.dart';
import 'package:flutterbestplace/Screens/Signup/components/or_divider.dart';
import 'package:flutterbestplace/Screens/Signup/components/social_icon.dart';
import 'package:flutterbestplace/components/already_have_an_account_acheck.dart';
import 'package:flutterbestplace/components/rounded_button.dart';
import 'package:flutterbestplace/components/rounded_input_field.dart';
import 'package:flutterbestplace/components/rounded_password_field.dart';
import 'package:flutterbestplace/components/Dropdown_widget.dart';
import 'package:flutterbestplace/Controllers/user_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutterbestplace/models/Data.dart';
import 'package:flutterbestplace/models/user.dart';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../Controllers/db_service.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final Reference storageRef=FirebaseStorage.instance.ref();
final usersRef =FirebaseFirestore.instance.collection("user");
final postsRef =FirebaseFirestore.instance.collection("posts");
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');

final FirebaseAuth _auth = FirebaseAuth.instance;

final DateTime timestamp=DateTime.now();
class Body extends StatelessWidget {

  //UserController _controller = Get.put(UserController());
  AuthService _controller = Get.put(AuthService());
  var name;
  var mail;
  var psw;
  var role;

  bool _success;
  String _userEmail = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "SIGNUP",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              RoundedInputField(
                hintText: "Your Name",
                icon: Icons.person,
                onChanged: (value) {
                  name = value;
                },
                validate: (value) {
                  if (value.isEmpty) {
                    return 'Enter your Name';
                  } else {
                    return null;
                  }
                },
              ),
              RoundedInputField(
                hintText: "Your Email",
                icon: Icons.email,
                onChanged: (value) {
                  mail = value;
                },
                validate: (value) {
                  if (value.isEmpty) {
                    return 'Enter something';
                  } else if (RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value)) {
                    return null;
                  } else {
                    return 'Enter valid email';
                  }
                },
              ),
              RoundedPasswordField(
                onChanged: (value) {
                  psw = value;
                },
                validate: (value) {
                  if (value.isEmpty) {
                    return 'Enter Password';
                  } else if (!RegExp(
                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                      .hasMatch(value)) {
                    return 'Enter valid password (minimum 8 characters with combination of letters in upper, lower,special and chiffres)';
                  } else {
                    return null;
                  }
                },
              ),
              DropdownWidget(
                HintText: Text("Your Role"),
                Items: <String>['User', 'Place'],
                onChanged: (value) {
                  print("role : $value");
                    role = value;
                },
                valueSelect: role,
                validate: (value) {
                  if (value == null) {
                    return 'Choose your Role';
                  } else {
                    return null;
                  }
                },
              ),
              RoundedButton(
                text: "SIGNUP",
                press: () async {
    var fromdata = _formKey.currentState;
    if (fromdata.validate()) {
      fromdata.save();

        var Errormessage = await _controller.createUser(name,mail, psw,role);
        print("Erormessage $Errormessage");
        if (Errormessage== null){
          if(role=='User'){
          Get.toNamed('/login');
          }else if (role=='Place'){
            Get.toNamed('/position');
          }
        }else{
          AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              animType: AnimType.RIGHSLIDE,
              headerAnimationLoop: true,
              title: 'Error',
              desc:Errormessage ,
              btnOkOnPress: () {},
              btnOkIcon: Icons.cancel,
              btnOkColor: Colors.red)
            ..show();
        }




    }else {
      print("notvalid");
    }
                }
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                login: false,
                press: () {
                  Get.toNamed('/login');
                },
              ),
              OrDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                 /* SocalIcon(
                    iconSrc: "assets/icons/facebook.svg",
                    press: () {},
                  ),
                  SocalIcon(
                    iconSrc: "assets/icons/twitter.svg",
                    press: () {},
                  ),*/
                  SocalIcon(
                    iconSrc: "assets/icons/google-plus.svg",
                    press: () async {
                      await _controller.linkGoogleAndTwitter();
                     // _controller.userController.value.role="User";
                     // Get.toNamed('/home');

                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }



}


