import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterbestplace/Screens/Profil_User/body.dart';
import 'package:flutterbestplace/Users/profile.dart';
import 'package:flutterbestplace/models/user.dart';
import 'package:flutterbestplace/Screens/home.dart';
import 'package:flutterbestplace/components/progress.dart';

import 'Profil_Place/body.dart';
import 'Profil_User/profil_screen.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var searchResultsFuture;
TextEditingController searchController = TextEditingController();
  handleSearch(String query) {
    Future<QuerySnapshot> users =
        usersRef.where("fullname", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;
    });
  }
  clearSearch(){
    searchController.clear();
  }
  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
            hintText: "Search for a user",
            filled: true,
            prefixIcon: Icon(
              Icons.account_box,
              size: 28.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch,
            )),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              "assets/images/search.svg",
              height: orientation == Orientation.portrait ? 300 : 200.0,
            ),
            Text(
              "Find places",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            )
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
        future: searchResultsFuture,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchResults = [];

          snapshot.data.docs.forEach((element) {
            CUser user = CUser.fromDocument(element);
            UserResult searchResult=UserResult(user);
            searchResults.add(searchResult);
          });

          return ListView(
            children: searchResults,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildSearchField(),
        body: searchResultsFuture == null
            ? buildNoContent()
            : buildSearchResults());
  }
}

class UserResult extends StatelessWidget {
  final CUser user;
  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color:Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(children:<Widget>[
        GestureDetector(
          onTap: ()=>showProfile(context, profileId: user.id, Role:user.role),
          child:ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: user.photoUrl!=null ? CachedNetworkImageProvider(user.photoUrl):AssetImage("assets/images/profil_defaut.jpg"),
            ),
            title: Text(
              user.fullname,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Divider(
          height:2.0,
          color: Colors.white54,
        ),
          ],),
    );
  }
}
showProfile(BuildContext context, { String profileId,String Role}) {
  if(Role == "User"){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilUser(
        profileId: profileId,
      ),
    ),
  );}else{
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
