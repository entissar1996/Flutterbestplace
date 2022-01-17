import 'package:flutter/material.dart';

import '../Controllers/db_service.dart';
import '../models/user.dart';
import 'chat.dart';

class Listuserchat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
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
                          child: Icon(Icons.person),
                        ),
                        title: Text(user.fullname),
                        subtitle: Text(user.email),
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
