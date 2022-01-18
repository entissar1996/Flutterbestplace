import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/constants.dart';
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
   var msgController=TextEditingController();
   AuthService _controller = Get.put(AuthService());

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
            Expanded(child: StreamBuilder<List<Message>>(
              stream:DBService().getMessage(user.id),
              builder: (context, s1) {
                if (s1.hasData) {
                 return StreamBuilder<List<Message>>(
                    stream:DBService().getMessage(user.id,false),
                    builder: (context, s2) {
                      if (s2.hasData) {
                        var messages = [...s1.data, ...s2.data];
                        messages.sort((i,j)=>i.createAt.toString().compareTo(j.createAt.toString()));
                        messages=messages.reversed.toList();
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
                                    margin: EdgeInsets.only(bottom:10),
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                      controller:msgController,
                      decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )),
                ),
                IconButton(
                  onPressed: () async{
                      var msg = Message(
                      content:msgController.text,
                      senderUid:_controller.user.id,
                      receiverUid:user.id,
                        createAt:,//DateFormat("hh:mm:ss a").format(DateTime.now())"${DateTime.now().hour}:${DateTime.now().minute} ${DateTime.now().day}",
                    );
                      msgController.clear();
                   //   print("????????????? $timeago)}");
                    await DBService().sendMessage(msg);
                  },

                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
