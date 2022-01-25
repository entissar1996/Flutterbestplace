import 'dart:async';
import 'package:flutterbestplace/Screens/EditProfil/edit_profil.dart';
import 'package:flutterbestplace/components/appbar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterbestplace/Controllers/rate_controller.dart';
import 'package:flutterbestplace/Screens/post.dart';
import 'package:flutterbestplace/components/progress.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/constants.dart';

//google maps :
import 'package:google_maps_flutter/google_maps_flutter.dart';

//geolocator :
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutterbestplace/components/numbers_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutterbestplace/models/user.dart';
import '../../Controllers/auth_service.dart';
import 'package:flutterbestplace/Controllers/user_controller.dart';
import 'package:flutterbestplace/Controllers/maps_controller.dart';

import '../home.dart';
import '../post_tile.dart';

class ProfilPlace extends StatefulWidget {
  final String profileId;

  ProfilPlace({this.profileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilPlace> {

  double rate;
  bool isLoading = false;
  bool _isOpen = false;
  String postOrientation = "grid";
  CameraPosition _kGooglePlex;
  var _competer = Completer();
  Position cp;
  Set<Marker> markers = {};
  Post postsScreen = Post();
  int postCount = 0;
  List<Post> posts = [];
  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;
  double zoomMaps = 4;
  RteController controllerRate = Get.put(RteController());
  PanelController _panelController = PanelController();
  AuthService _controller = Get.put(AuthService());
  MarkerController controllerMarker = MarkerController();

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(_controller.idController)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : kPrimaryColor,
            border: Border.all(
              color: isFollowing ? Colors.grey : kPrimaryColor,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }
  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfil(currentUserId: _controller.idController)));
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = _controller.idController == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,

      );
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(_controller.idController)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .doc(_controller.idController)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(_controller.idController)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(_controller.idController)
        .set({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .doc(_controller.idController)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(_controller.idController)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": _controller.userController.value.fullname,
      "userId": _controller.idController,
      "userProfileImg": _controller.userController.value.photoUrl,
      "timestamp": timestamp,
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Future<Position> getMarker() async {
/*
    var markerData= await controllerMarker.MarkerById(_controller.idController);
    print("***************Map Marker**************");
    //var latitude = markerData.latitude;
    //var longitude = markerData.longitude;
    print(latitude);
    print(longitude);
    _kGooglePlex = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoomMaps,
    );
    var add = markers.add(
        Marker(markerId: MarkerId(markerData.id), position: LatLng(latitude, longitude)));
    setState(() {});*/
  }

  @override
  void initState()  {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
    getMarker();

    controllerRate.RateById(_controller.idController);
    controllerRate.CalculRating();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          CUser user = CUser.fromDocument(snapshot.data);
          return Scaffold(
            appBar: buildAppBar(context),
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                FractionallySizedBox(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: user.photoUrl == null
                            ? AssetImage("assets/images/profil_defaut.jpg")
                            : NetworkImage(user.photoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 0.3,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                SlidingUpPanel(
                  controller: _panelController,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(32),
                    topLeft: Radius.circular(32),
                  ),
                  minHeight: MediaQuery.of(context).size.height * 0.35,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                  body: GestureDetector(
                    onTap: () => _panelController.close(),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  panelBuilder: (ScrollController controller) =>
                      _panelBody(controller),
                  onPanelSlide: (value) {
                    if (value >= 0.2) {
                      if (!_isOpen) {
                        setState(() {
                          _isOpen = true;
                        });
                      }
                    }
                  },
                  onPanelClosed: () {
                    setState(() {
                      _isOpen = false;
                    });
                  },
                ),
              ],
            ),
          );
        });
  }

  /// WIDGETS

  Widget buildCircle({
    Widget child,
    double all,
    Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

  /*return FutureBuilder(
  future: usersRef.doc(widget.profileId).get(),
  builder: (context, snapshot) {
  if (!snapshot.hasData) {
  return circularProgress();
  }
  CUser user = CUser.fromDocument(snapshot.data);*/
  Widget buildName() => FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        CUser user = CUser.fromDocument(snapshot.data);
        return Column(children: [
          Text(
            user.fullname,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.adresse,
            style: TextStyle(color: Colors.grey),
          ),
        ]);
      });

  Widget buildRating(double Rating) {
    return RatingBar.builder(
      initialRating: Rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      glow: true,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          rate = rating;
          print(rate);
        });
        /*setState(() {
         _rating.add(rating);
        print("_rating : $_rating");
        });*/
      },
      updateOnDrag: false,
    );
  }

  _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate This Places'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please leave a star rating.'),
                buildRating(1.0),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('rating'),
              onPressed: () {
                print("///////////////////////////");
                print(rate);
                controllerRate.SaveRate(_controller.idController, rate,
                    widget.profileId);
                //controllerRate.addRate(rate, _controller.idController);
                // print("liste rates  cout : ${controllerRate.Rates.value.length}");
                setState(() {
                  controllerRate.CalculRating();
                });
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  /// Panel Body
  SingleChildScrollView _panelBody(ScrollController controller) {
    double hPadding = 40;

    return SingleChildScrollView(
      controller: controller,
      physics: ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            height: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                /*Obx(
                  () => _titleSection(buildName()),
                ),*/
                buildName(),

                MaterialButton(
                    onPressed: () {
                      print("okkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
                      _showMyDialog();
                    },
                    child: Center(
                        child: buildRating(controllerRate.Rating.value))),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildCountColumn("posts", postCount),
                    buildCountColumn("followers", followerCount),
                    buildCountColumn("following", followingCount),

                  ],

                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildProfileButton(),
                  ],
                ),

                // _actionSection(hPadding: hPadding),
              ],
            ),
          ),
          IconTap(),
          buildProfilePosts(),
        ],
      ),
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts == null) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/nopost.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.pink[50],
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }else if (postOrientation == "map") {
      return Column(
        children: [
          _kGooglePlex == null
              ? CircularProgressIndicator()
              : Container(
                  child: GoogleMap(
                    markers: markers,
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (controller) {
                      _competer.complete(controller);
                    },
                  ),
                  height: 500,
                ),
          ElevatedButton(
            child: Text(
              "update",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              zoomMaps = zoomMaps + 2;
            },
            style: ElevatedButton.styleFrom(
                primary: kPrimaryColor,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w100)),
          ),
        ],
      );
    }
  }

//IconTap
  Widget IconTap() => Container(
        color: kPrimaryLightColor,
        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  postOrientation = "grid";
                });
              },
              icon: Icon(Icons.image, color: kPrimaryColor, size: 30.0),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  postOrientation = "map";
                });
              },
              icon: Icon(Icons.map, color: kPrimaryColor, size: 30.0),
            )
          ],
        ),
      );

  /// Action Section
  Row _actionSection({double hPadding}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Visibility(
          visible: !_isOpen,
          child: Expanded(
            child: OutlineButton(
              onPressed: () => _panelController.open(),
              borderSide: BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Text(
                'VIEW PROFILE',
                style: TextStyle(
                  fontFamily: 'NimbusSanL',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: !_isOpen,
          child: SizedBox(
            width: 16,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: _isOpen
                  ? (MediaQuery.of(context).size.width - (2 * hPadding)) / 1.6
                  : double.infinity,
              child: FlatButton(
                onPressed: () => print('Message tapped'),
                color: Colors.blue,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Text(
                  'MESSAGE',
                  style: TextStyle(
                    fontFamily: 'NimbusSanL',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Title Section
  Column _titleSection(CUser user) {
    return Column(
      children: <Widget>[
        Text(
          user.fullname,
          style: TextStyle(
            fontFamily: 'NimbusSanL',
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
        buildEditIcon(kPrimaryColor),
        SizedBox(
          height: 8,
        ),
        Text(
          user.email,
          style: TextStyle(
            fontFamily: 'NimbusSanL',
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          user.phone == null ? "" : user.phone,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 3,
          child: IconButton(
            onPressed: () {
              Get.toNamed('/editprofil');
            },
            icon: Icon(
              Icons.edit,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
}
