import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/Login/components/background.dart';
import 'package:flutter_auth/Screens/Signup/signup_screen.dart';
import 'package:flutter_auth/components/already_have_an_account_acheck.dart';
import 'package:flutter_auth/components/rounded_button.dart';
import 'package:flutter_auth/components/rounded_input_field.dart';
import 'package:flutter_auth/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_auth/Screens/user.dart';
import 'dart:convert';

class Body extends StatelessWidget {
 var mail;
 var psw;
 final _formKey = GlobalKey<FormState>();
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
              onChanged: (value) {
                mail = value;
              },
              validate: (value){
                if (value.isEmpty) {
                    return 'Enter something';
                } else if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
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
              press: () {
                var fromdata=_formKey.currentState;
                 if (fromdata.validate()) {
                   login(mail, psw);

                  }else{
                    print("notvalid");
                  }
              },


            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              press: () {
                   Navigator.of(context).pushNamed('signup');
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );*/
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}



Future<User> login(email, password) async {
  final response = await http.post(
    Uri.parse("https://bestpkace-api.herokuapp.com/users/authenticate"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );
  print(jsonDecode(response.body));

if (response.statusCode == 200 ) {
  print('ok');
   // Navigator.of(context).pushNamed('accueil');
  } else {
    throw Exception('Failed to register user.');
  }
}
