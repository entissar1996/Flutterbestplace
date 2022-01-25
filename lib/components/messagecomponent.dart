import 'package:flutter/material.dart';
import 'package:flutterbestplace/Screens/home.dart';
import 'package:flutterbestplace/models/messages.dart';
import 'package:flutterbestplace/utils/global.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constants.dart';
import '../models/message.dart';

class MessageComponent extends StatelessWidget {
  const MessageComponent({Key key, this.msg}) : super(key: key);
  final Messages msg;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;



    return Row(
      mainAxisAlignment:
          msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: msg.isMe ? kPrimaryColor : kPrimaryLightColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft:
                      msg.isMe ? Radius.circular(10) : Radius.circular(0),
                  bottomRight:
                      msg.isMe ? Radius.circular(0) : Radius.circular(10),
                ),
              ),
              constraints: BoxConstraints(
                minWidth: 120,
                minHeight: 50,
                maxWidth: width / 1.1,
              ),
              child: Text(
                msg.message,
                textAlign: TextAlign.start,
                style: TextStyle(color: msg.isMe ?Colors.white:Colors.black),
              ),

            ),
            Positioned(
              bottom: 0,
              right: 0,
              child:Container(
                padding: EdgeInsets.only(right:5,bottom:5),
                child: Text(getTimeAgo(this.msg.createdAt),style:TextStyle(fontSize: 10,color:Colors.white)),
              ) ,)
        ],
        ),
      ],
    );
  }
}
