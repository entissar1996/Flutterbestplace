import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterbestplace/Screens/EditProfil/edit_profil.dart';
import 'package:flutterbestplace/Screens/home.dart';
import 'package:flutterbestplace/Screens/post.dart';
import 'package:flutterbestplace/Screens/post_screen.dart';
import 'package:flutterbestplace/components/progress.dart';
import 'package:flutterbestplace/components/appbar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutterbestplace/components/button_widget.dart';
import 'package:flutterbestplace/components/photo_profil.dart';
import 'package:flutterbestplace/components/numbers_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutterbestplace/models/user.dart';
import '../../Controllers/auth_service.dart';
import 'package:flutterbestplace/Controllers/user_controller.dart';

import '../../components/rounded_button.dart';

class ProfilUser extends StatefulWidget {
  final String profileId;
  ProfilUser({ this.profileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilUser> {
  String postOrientation = "grid";
  PanelController _panelController = PanelController();

  Post postsScreen = Post();
  AuthService _controller = Get.put(AuthService());
  bool isLoading = false;
  bool _isOpen = false;
  int postCount = 0;
  List<Post> posts = [];
  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;
  final String currentUserId = currentUser?.id;
  CUser userprofile;


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
      "ownerId": _controller.idController,
      "username": _controller.userController.value.fullname,
      "userId": _controller.idController,
      "userProfileImg": _controller.userController.value.photoUrl,
      "timestamp": timestamp,
    });
  }
  getUser()async{
    userprofile =await _controller.getUserById(widget.profileId);
    print(userprofile.toJson());
  }
  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
    getUser();
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

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfil(currentUserId:_controller.idController)));
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
          ListView(
            physics: BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 24),
              PhotoProfile(
                      imagePath: user.photoUrl == null
                          ? "https://firebasestorage.googleapis.com/v0/b/bestplace-331512.appspot.com/o/profil_defaut.jpg?alt=media&token=c9ce20af-4910-43cd-b43a-760a5c4b4243"
                          : user.photoUrl,
                      /*onClicked: () {
                    print("tef bye");
                    Get.toNamed('/editprofil');
                  },*/
                ),
              const SizedBox(height: 24),

               buildName(user),

              const SizedBox(height: 24),
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
            ],
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

  Widget buildName(CUser user) => Column(
        children: [
          Text(
            user.fullname,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey),
          ),
          /* Text(
            user.phone,
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            user.ville,
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            user.adresse,
            style: TextStyle(color: Colors.grey),
          )*/
        ],
      );

  Widget buildRating() => RatingBar.builder(
        initialRating: 2.5,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          print(rating);
        },
      );

  /// Panel Body
  SingleChildScrollView _panelBody(ScrollController controller) {
    double hPadding = 40;

    return SingleChildScrollView(
      controller: controller,
      physics: ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          IconTap(),
          buildProfilePosts(),
        ],
      ),
    );
  }

  //
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
      return GridView.builder(
        primary: false,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: posts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemBuilder: (BuildContext context, int index) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(posts[index].mediaUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
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
              icon: Icon(Icons.grid_on, color: kPrimaryColor, size: 30.0),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  postOrientation = "list";
                });
              },
              icon: Icon(Icons.list, color: kPrimaryColor, size: 30.0),
            ),
          ],
        ),
      );

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
