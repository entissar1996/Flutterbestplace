import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/Screens/post.dart';
import 'package:flutterbestplace/components/rounded_button.dart';
import 'package:flutterbestplace/components/rounded_input_field.dart';
import 'package:flutterbestplace/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterbestplace/models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Screens/home.dart';
import '../components/progress.dart';
import '../constants.dart';

class Pro extends StatefulWidget {
  final CUser currentUser;

  Pro({this.currentUser});
  @override
  AccuielScreenState createState() => AccuielScreenState();
}

class AccuielScreenState extends State<Pro> {

  int _selectedIndex = 0;
  int _currentTab = 0;
  List<IconData> _icons = [
    FontAwesomeIcons.utensils,
    FontAwesomeIcons.tshirt,
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.hotel,
  ];
  List<Post> posts;
  bool isLoading = false;
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    getTimeline();
  }
  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await postsRef
        .doc(widget.currentUser.id)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }
  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
    snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Text("No posts");
    } else {
      return ListView(children: posts);
    }
  }

  Widget _buildIcon(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: 100.0,
        width: 100.0,
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? kPrimaryLightColor
              : Color(0xFFE7EBEE),
          borderRadius: BorderRadius.circular(26.0),
        ),
        child: Icon(
          _icons[index],
          size: 25.0,
          color: _selectedIndex == index
              ? Theme.of(context).primaryColor
              : Color(0xFFB4C1C4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ListView(
            // physics: BouncingScrollPhysics(),
            children: [


              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _icons
                    .asMap()
                    .entries
                    .map(
                      (MapEntry map) => _buildIcon(map.key),
                )
                    .toList(),
              )
            ],


          ),
        ],

      ),
    );
    }
}
