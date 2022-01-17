import 'package:flutter/material.dart';

import '../models/message.dart';

class MessageComponent extends StatelessWidget {
  const MessageComponent({Key key, this.msg}) : super(key: key);
  final Message msg;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment:
          msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: msg.isMe?Radius.circular(10):Radius.circular(0),
              bottomRight: msg.isMe?Radius.circular(0):Radius.circular(10),
            ),
          ),
          constraints: BoxConstraints(
            minWidth: 30,
            minHeight: 30,
            maxWidth: width / 1.1,
          ),
          child: Text(msg.content),
        ),
      ],
    );
  }
}
