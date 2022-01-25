import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterbestplace/Screens/header.dart';
import 'package:flutterbestplace/components/Dropdown_widget.dart';
import 'package:get/get.dart';

import '../Controllers/auth_service.dart';
import '../components/rounded_button.dart';
import '../constants.dart';
import 'Signup/components/body.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldkey=GlobalKey<ScaffoldState>();
  final _formKey=GlobalKey<FormState>();
  String username="" ;
  AuthService _controller = Get.put(AuthService());

  var role='User';
  submit() async{
    final form=_formKey.currentState;

    if (form.validate()){
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
      _scaffoldkey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 20),(){
        Navigator.pop(context,username);
      });
      await _controller.updateRole(_controller.idController,role);
      Get.toNamed('/home');
    }
  }
  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldkey,
      body:ListView(
        children:<Widget> [
          Container(
            child: Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child:Text("Create a username",style: TextStyle(fontSize: 25.0)),)
                ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child:Form(
                    key:_formKey,
                    child:  DropdownWidget(
                      HintText: Text("Your Role"),
                      Items: <String>['User', 'Place'],
                      onChanged: (value) {
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
                  )
                ),
              ),
    RoundedButton(
    text: "Save",
    press: () async {
    var fromdata = _formKey.currentState;
    if (fromdata.validate()) {
    fromdata.save();
 await _controller.updateRole(_controller.idController,role);}
    if(role=='User'){
      Get.toNamed('/home');
    }else if (role=='Place'){
      Get.toNamed('/position');
    }
    })
            ],),
          )

        ],
      ),
    );
  }
}
