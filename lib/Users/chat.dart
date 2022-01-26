import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/constants.dart';
import 'package:flutterbestplace/models/messages.dart';
import 'package:flutterbestplace/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../Controllers/db_service.dart';
import '../Screens/home.dart';
import '../components/messagecomponent.dart';
import '../models/message.dart';
import '../models/user.dart';

class ChatPage extends StatelessWidget {
  ChatPage({Key key, this.user}) : super(key: key);
  final CUser user;
  var msgController = TextEditingController();
  AuthService _controller = Get.put(AuthService());
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    DateTime currentPhoneDate = DateTime.now(); //DateTime

    Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate);
    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullname),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<List<Messages>>(
              stream: DBService().getMessage(user.id),
              builder: (context, s1) {
                if (s1.hasData) {
                  return StreamBuilder<List<Messages>>(
                    stream: DBService().getMessage(user.id, false),
                    builder: (context, s2) {
                      if (s2.hasData) {
                        var messages = [...s1.data, ...s2.data];
                        messages.sort((i, j) => i.createdAt
                            .toString()
                            .compareTo(j.createdAt.toString()));
                        messages = messages.reversed.toList();
                        return messages.length == 0
                            ? Center(
                                child: Text("No Message"),
                              )
                            : ListView.builder(
                                reverse: true,
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final msg = messages[index];

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: MessageComponent(
                                      msg: msg,
                                    ),
                                  );
                                },
                              );
                      } else
                        return Center(child: CircularProgressIndicator());
                    },
                  );
                } else
                  return Center(child: CircularProgressIndicator());
              },
            )),
            Container(
              padding: EdgeInsets.only(left: 15, right: 5),
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                        child: CustomTextField(
                      controller: msgController,
                      hintText: "Write your message",
                    )),
                  ),
                  IconButton(
                      onPressed: () async {
                        var msg = Messages(
                          message: msgController.text,
                          senderUid: _controller.user.id,
                          receiverUid: user.id,
                          createdAt: DateTime.now(),
                        );
                        msgController.clear();
                        await DBService().sendMessage(msg);
                      },
                      icon: Icon(
                        Icons.send_rounded,
                        color: isLoading ? Colors.grey : kPrimaryColor,
                        size: 35,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
