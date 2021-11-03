import 'package:flutter/material.dart';
import 'package:flutterbestplace/Screens/Signup/components/background.dart';
import 'package:flutterbestplace/Screens/Signup/components/or_divider.dart';
import 'package:flutterbestplace/Screens/Signup/components/social_icon.dart';
import 'package:flutterbestplace/components/already_have_an_account_acheck.dart';
import 'package:flutterbestplace/components/rounded_button.dart';
import 'package:flutterbestplace/components/rounded_input_field.dart';
import 'package:flutterbestplace/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterbestplace/Controllers/user_controller.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
//import 'package:flutterbestplace/models/user.dart';
import 'package:get/get.dart';

class Body extends StatelessWidget {
  var name;
  var mail;
  var psw;

  final _formKey = GlobalKey<FormState>();
  UserController _controller = Get.put(UserController());
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
                "SIGNUP",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/signup.svg",
                height: size.height * 0.35,
              ),
              RoundedInputField(
                hintText: "Your Name",
                onChanged: (value) {
                  name = value;
                },
                validate: (value) {
                  if (value.isEmpty) {
                    return 'Enter something';
                  } else {
                    return null;
                  }
                },
              ),
              RoundedInputField(
                hintText: "Your Email",
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
                  } else if (!RegExp(
                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                      .hasMatch(value)) {
                    return 'Enter valid password';
                  } else {
                    return null;
                  }
                },
              ),
              RoundedButton(
                text: "SIGNUP",
                press: () {
                  var fromdata = _formKey.currentState;
                  if (fromdata.validate()) {
                    /*_userController.signup(mail, psw);
                    _userController.getuser();*/
                    _controller.signup(name, mail, psw);
                  } else {
                    print("notvalid");
                  }
                },
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
                  SocalIcon(
                    iconSrc: "assets/icons/facebook.svg",
                    press: () {},
                  ),
                  SocalIcon(
                    iconSrc: "assets/icons/twitter.svg",
                    press: () {},
                  ),
                  SocalIcon(
                    iconSrc: "assets/icons/google-plus.svg",
                    press: () {},
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

/*Future<User> signup(email, password) async {
  final response = await http.post(
    Uri.parse("https://bestpkace-api.herokuapp.com/users/register"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );
  print(jsonDecode(response.body));

  if (response.statusCode == 200) {
    Get.toNamed('/profil');
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to register user.');
  }
}*/
