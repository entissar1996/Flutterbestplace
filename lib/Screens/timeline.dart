import 'package:flutter/material.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/Screens/post.dart';
import 'package:flutterbestplace/models/user.dart';
import 'package:flutterbestplace/Screens/home.dart';
import 'package:flutterbestplace/Screens/header.dart';
import 'package:flutterbestplace/components/progress.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../constants.dart';


//CollectionReference users = FirebaseFirestore.instance.collection('user');
final  users =FirebaseFirestore.instance.collection('user');

class Timeline extends StatefulWidget {
  final CUser currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
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
  int _selectedIndex = 0;
  int _currentTab = 0;
  List<IconData> _icons = [
    FontAwesomeIcons.utensils,
    FontAwesomeIcons.tshirt,
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.hotel,
  ];
  Widget _buildIcon(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: 90.0,
        width: 90.0,
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

  @override
  Widget build(context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(

      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FractionallySizedBox(
      alignment: Alignment.topLeft,
        heightFactor: 0.15,
        child:
        Image.asset(
            "assets/images/logo3.png",
           // height: size.height * 0.09,
          )),
      FractionallySizedBox(
      alignment: Alignment.center,
        heightFactor: 0.75,
        child: Container(
            child: ListView(
              // physics: BouncingScrollPhysics(),
              children: [
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
          ),
      ),
          FractionallySizedBox(
            alignment: Alignment.bottomLeft,
            heightFactor: 0.7,
            child: Container(
              child: RefreshIndicator(
                  onRefresh: () => getTimeline(), child: buildTimeline()),
            ),
          ),
        ],

      ),);
  }
}
