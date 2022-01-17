import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/Screens/Welcome/welcome_screen.dart';
import 'package:flutterbestplace/Screens/create_account.dart';
import 'package:flutterbestplace/constants.dart';
import 'package:flutterbestplace/Screens/Signup/signup_screen.dart';
import 'package:flutterbestplace/Screens/Signup/contactplace.dart';
import 'package:flutterbestplace/Screens/Signup/position.dart';
import 'package:flutterbestplace/Screens/Login/login_screen.dart';
import 'package:flutterbestplace/Screens/Accueil/accueil.dart';
import 'package:flutterbestplace/Screens/Profil_User/profil_screen.dart';
import 'package:flutterbestplace/Screens/EditProfil/edit_profil.dart';
import 'package:flutterbestplace/Screens/Profil_Place/profil_place.dart';

import 'package:flutterbestplace/Screens/google_map/add_Marker.dart';
import 'package:flutterbestplace/Screens/google_map/all_Markers.dart';
import 'package:get/get.dart';

import 'Screens/Profil_Place/body.dart';
import 'Screens/Profil_User/body.dart';
import 'Screens/home.dart';
import 'Users/listuserchat.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomeScreen(),/*StreamBuilder(
        stream:AuthService().onChangedUser,
        builder: (context,snapshot){
          return snapshot.data==null?WelcomeScreen():AccuielScreen();
        },

      ),*/
      getPages: [
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/contactPlace', page: () => ContactPlace()),
        GetPage(name: '/position', page: () => PositionAdd()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/accueil', page: () => AccuielScreen()),
        GetPage(name: '/profilUser', page: () => ProfilUser()),
        GetPage(name: '/editprofil', page: () => EditProfil()),
        GetPage(name: '/profilPlace', page: () => ProfilPlace()),
        GetPage(name: '/getmaps', page: () => AllMarkers()),
        GetPage(name: '/updaterole', page: () => CreateAccount()),
        GetPage(name: '/chat', page: () => Listuserchat()),

        GetPage(name: '/home', page: () => Home()),

      ],
      /* routes: {
        'signup': (context) => SignUpScreen(),
        'login': (context) => LoginScreen(),
        'accueil': (context) => AccuielScreen(),
        'profil': (context) => ProfilScreen(),
      },*/
    );
  }
}
