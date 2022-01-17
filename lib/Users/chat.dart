import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:get/get.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullname),
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
                                  return MessageComponent(
                                    msg: msg,
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
                   /* Map<String, dynamic> map ={"content":msgController.text,"senderUid":_controller.user.id, "receiverUid":user.id,
                      "createAt":Timestamp.now()};
                    Message msg=Message.fromJson( map, _controller.idController);
                    print("????????????????????????????????????????????????????????????????????????????????????????????????????????????");
                    print(msg.toJson());*/
                    print("ffffffffffffffffffffffffffff$msgController");
                      var msg = Message(
                      content:msgController.text,
                      senderUid:_controller.user.id,
                      receiverUid:user.id,
                        createAt:timestamp,
                    );
                      print("????????????? $timestamp");
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
