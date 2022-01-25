import 'package:flutter/material.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/Screens/post.dart';
import 'package:flutterbestplace/models/user.dart';
import 'package:flutterbestplace/Screens/home.dart';
import 'package:flutterbestplace/Screens/header.dart';
import 'package:flutterbestplace/components/progress.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


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
    return Scaffold(
        appBar: header(context, isAppTitle: true),
        body: RefreshIndicator(
            onRefresh: () => getTimeline(), child: buildTimeline()));
  }
}
