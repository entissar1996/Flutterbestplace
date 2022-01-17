import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';



class CUser {
  String id;
  String fullname;
  String email;
  String password;
  String phone;
  String ville;
  String adresse;
  String role;
  String photoUrl="https://firebasestorage.googleapis.com/v0/b/bestplace-331512.appspot.com/o/profil_defaut.jpg?alt=media&token=c9ce20af-4910-43cd-b43a-760a5c4b4243";
  List followers;
  List following;
  CUser(
      {this.id,
      this.fullname,
      this.email,
      this.password,
      this.phone,
      this.ville,
      this.adresse,
      this.role,
      this.photoUrl,
      this.followers,
      this.following,
      });
  factory CUser.fromJson(Map<String, dynamic> json) {
    return CUser(
      id: json['id'],
      fullname: json['fullname'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      ville: json['ville'],
      adresse: json['adresse'],
      role: json['role'],
      photoUrl: json['photoUrl'],
      followers: json['followers'],
      following: json['following'],

    );
  }
  factory CUser.fromDocument(DocumentSnapshot doc){
    return CUser(id: doc['id'],fullname: doc['fullname'], email: doc['email'],  phone: doc['phone'],ville: doc['ville'],adresse: doc['adresse'], photoUrl: doc['photoUrl'], followers: doc['followers'],following: doc['following'],role: doc['role']);
  }
  CUser.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {
    id = documentSnapshot.id;
    fullname = documentSnapshot["fullname"];
    email = documentSnapshot["email"];
    password= documentSnapshot['password'];
    phone= documentSnapshot['phone'];
    ville= documentSnapshot['ville'];
    adresse=documentSnapshot['adresse'];
    role= documentSnapshot['role'];
    photoUrl= documentSnapshot['photoUrl'];
    followers= documentSnapshot['followers'];
    following= documentSnapshot['following'];
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'fullname': fullname,
        'email': email,
        'password': password,
        'phone': phone,
        'ville': ville,
        'adresse': adresse,
        'role': role,
        'photoUrl': photoUrl,
        'followers': followers,
        'following': following,
      };

}
