import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterbestplace/Controllers/db_service.dart';
import 'package:flutterbestplace/Screens/EditProfil/edit_profil.dart';
import 'package:flutterbestplace/Screens/Profil_Place/body.dart';
import 'package:flutterbestplace/Screens/Profil_User/body.dart';
import 'package:flutterbestplace/Screens/home.dart';
import 'package:flutterbestplace/Screens/post.dart';
import 'package:flutterbestplace/Screens/post_screen.dart';
import 'package:flutterbestplace/Screens/post_tile.dart';
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

class Adminprofile extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Adminprofile> {
  AuthService _controller = Get.put(AuthService());

  final String currentUserId = currentUser?.id;
  CUser userprofile;

  @override
  void initState() {
    super.initState();
    handl();
  }

  var searchResultsFuture;
  var ResultsFuture;

  TextEditingController searchController = TextEditingController();

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        usersRef.where("fullname", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  handl() {
    Future<QuerySnapshot> users = usersRef.get();
    setState(() {
      ResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        leading: BackButton(),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        actions: [],
      ),
      body:
      StreamBuilder<List<CUser>>(
        stream: DBService().getAllUser,
        builder: (_, s) {
          if (s.hasData) {
            final users = s.data;

            return users.length == 0
                ? Center(
                    child: Text("No Chat"),
                  )
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (ctx, i) {
                      final user = users[i];
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => showProfile(context,
                                    profileId: user.id, Role: user.role)),
                          );
                          // NavigateToNextPage(context, ChatPage(user:user))
                        },
                        leading: Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(.5)),
                          child: Material(
                            elevation: 4.0,
                            shape: CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            color: Colors.transparent,
                            child: Ink.image(
                              image: NetworkImage(user.photoUrl == null
                                  ? "https://firebasestorage.googleapis.com/v0/b/bestplace-331512.appspot.com/o/profil_defaut.jpg?alt=media&token=c9ce20af-4910-43cd-b43a-760a5c4b4243"
                                  : user.photoUrl),
                              fit: BoxFit.cover,
                              width: 80.0,
                              height: 80.0,
                            ),
                          ),
                        ),
                        title: Text(user.fullname),
                      );
                    });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId, String Role}) {
  if (Role == "User") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilUser(
          profileId: profileId,
        ),
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilPlace(
          profileId: profileId,
        ),
      ),
    );
  }
}
