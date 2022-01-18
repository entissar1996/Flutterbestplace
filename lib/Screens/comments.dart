import 'package:flutter/material.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/components/progress.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterbestplace/Screens/home.dart';
import 'package:flutterbestplace/Screens/header.dart';
class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
     this.postId,
     this.postOwnerId,
     this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
    postId: this.postId,
    postOwnerId: this.postOwnerId,
    postMediaUrl: this.postMediaUrl,
  );
}

class CommentsState extends State<Comments> {
  AuthService _controller = Get.put(AuthService());
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({
    this.postId,
     this.postOwnerId,
     this.postMediaUrl,
  });

  buildComments() {

    return StreamBuilder(
        stream: commentsRef
            .doc(postId)
            .collection('comments')
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments = [];
          snapshot.data.docs.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comments,
          );
        });
  }

  addComment() {
    commentsRef.doc(postId).collection("comments").add({
      "username": _controller.userController.value.fullname,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": _controller.userController.value.photoUrl,
      "userId": _controller.idController,
    });
    bool isNotPostOwner = postOwnerId != _controller.idController;
    if (isNotPostOwner) {
      activityFeedRef.doc(postOwnerId).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": timestamp,
        "postId": postId,
        "userId": _controller.idController,
        "username": _controller.userController.value.fullname,
        "userProfileImg": _controller.userController.value.photoUrl,
        "mediaUrl": postMediaUrl,
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: "Write a comment..."),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text("Post"),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
     this.username,
     this.userId,
    this.avatarUrl,
     this.comment,
     this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(username,style: TextStyle(fontSize: 15),),
           trailing:Text(timeago.format(timestamp.toDate())),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl==null ?"https://firebasestorage.googleapis.com/v0/b/bestplace-331512.appspot.com/o/profil_defaut.jpg?alt=media&token=c9ce20af-4910-43cd-b43a-760a5c4b4243":avatarUrl),
          ),
          subtitle: Text(comment, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
        ),
        Divider(),
      ],
    );
  }
}
