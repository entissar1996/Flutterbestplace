import 'package:flutter/material.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/Screens/Login/components/background.dart';
import 'package:flutterbestplace/components/already_have_an_account_acheck.dart';
import 'package:flutterbestplace/components/rounded_button.dart';
import 'package:flutterbestplace/components/rounded_input_field.dart';
import 'package:flutterbestplace/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterbestplace/models/user.dart';
import 'package:flutterbestplace/Controllers/user_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutterbestplace/models/Data.dart';
import 'package:get/get.dart';

class Body extends StatelessWidget {
  var mail;
  var psw;
  CUser user = CUser();
  final _formKey = GlobalKey<FormState>();
  AuthService _controller = Get.put(AuthService());
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.35,
              ),
              SizedBox(height: size.height * 0.03),
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
                    return 'Enter something';
                  }
                  return null;
                },
              ),
              RoundedButton(
                text: "LOGIN",
                press: () async {
    var fromdata = _formKey.currentState;
    if (fromdata.validate()) {
    fromdata.save();
      var Errormessage = await _controller.login(mail,psw);
    print("Erormessage $Errormessage");
    if (Errormessage== null){
      if(_controller.userController.value.role!="Admin"){
        Get.toNamed('/home');}
      else{
        Get.toNamed('/profilAdmin');
      }
     // Get.toNamed('/home');
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
                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                press: () {
                  // Navigator.of(context).pushNamed('signup');
                  Get.toNamed('/signup');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
