import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/Interface_User/Profil/components/photo_profil.dart';
import 'package:flutter_auth/Screens/Interface_User/Profil/components/button_widget.dart';
import 'package:flutter_auth/Screens/Interface_User/Profil/components/numbers_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_auth/models/user.dart';


class Body extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Body> {

  @override
  Widget build(BuildContext context) {
    final user = User(
    fullname:"nourhen lh",
    email: 'nono@gmail.com',
    avatar: "assets/images/profil_defaut.jpg",
  );
    
    return  ListView(
        physics: BouncingScrollPhysics(),
        children: [
          PhotoProfile(
            imagePath: user.avatar,
            onClicked: () async {},
          ),
          const SizedBox(height: 24),
          buildName(user),
          const SizedBox(height: 24),
         // Center(child:buildRating()),
          //const SizedBox(height: 24),
          Center(child:ButtonWidget(
                       text: 'Upgrade To Profile',
                       onClicked: () {},
                      )
                ),
          const SizedBox(height: 24),
          NumbersWidget(),
        ],
      ) ;
  }
  Widget buildName(User user) => Column(
        children: [
          Text(
            user.fullname,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

      Widget buildRating() =>  RatingBar.builder(
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
    
}
 