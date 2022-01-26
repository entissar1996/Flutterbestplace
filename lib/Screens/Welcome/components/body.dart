import 'package:flutter/material.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/Screens/Welcome/components/background.dart';
import 'package:flutterbestplace/components/rounded_button.dart';
import 'package:flutterbestplace/constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../Signup/components/social_icon.dart';

class Body extends StatelessWidget {
  AuthService _controller = Get.put(AuthService());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Welcome to BestPlace",
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color:kPrimaryColor),
            ),
            SizedBox(height: size.height * 0.05),
            Image.asset(
              "assets/images/logo.png",
              height: size.height * 0.32,
            ),
            SizedBox(height: size.height * 0.05),
            RoundedButton(
              text: "LOGIN",
              press: () {
                //Navigator.of(context).pushNamed('login');
                Get.toNamed('/login');
                //Get.toNamed('/profil');
              },
            ),
            RoundedButton(
              text: "SIGN UP",
              color: kPrimaryLightColor,
              textColor: Colors.black,
              press: () {
                //Navigator.of(context).pushNamed('signup');
                Get.toNamed('/signup');
              },
            ),
            SocalIcon(
              iconSrc: "assets/icons/google-plus.svg",
              press: () async {
                await _controller.linkGoogleAndTwitter();
                // _controller.userController.value.role="User";
                Get.toNamed('/home');

              },
            ),
          ],
        ),
      ),
    );
  }
}
