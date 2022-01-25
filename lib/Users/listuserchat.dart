import 'package:flutter/material.dart';
import 'package:flutterbestplace/constants.dart';

import '../Controllers/db_service.dart';
import '../models/user.dart';
import 'chat.dart';

class Listuserchat extends StatelessWidget {
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
      body: StreamBuilder<List<CUser>>(
        stream: DBService().getDiscussionUser,
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
                                builder: (context) => ChatPage(user: user)),
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
                          child:Material(
                            elevation: 4.0,
                            shape: CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            color: Colors.transparent,
                            child: Ink.image(
                              image: NetworkImage(user.photoUrl==null?"https://firebasestorage.googleapis.com/v0/b/bestplace-331512.appspot.com/o/profil_defaut.jpg?alt=media&token=c9ce20af-4910-43cd-b43a-760a5c4b4243":user.photoUrl),
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
