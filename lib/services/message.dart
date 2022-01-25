
import 'package:flutterbestplace/Controllers/auth_service.dart';
import 'package:flutterbestplace/models/messages.dart';
import 'package:flutterbestplace/utils/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MessageService {
  final db = FirebaseFirestore.instance;
  CollectionReference refMessage;
  AuthService _controller = Get.put(AuthService());

  Future sendMessage(String message) async {
    final newMessage = Messages(
      id: _controller.idController,
      senderUid: _controller.idController,
      roomId: ROOM_ID,
      message: message.trim(),
      messageType: MessageType.text,
      createdAt: DateTime.now(),
    );

    try {
      refMessage = db.collection(ROOM_COLLECTION);
      var res = await refMessage.add(newMessage.toJson());
      print(res);
      return {"status" : true, "message" : "success"};
    } on FirebaseAuthException catch (e) {
      return {"status" : false, "message" : e.message.toString()};
    }
  }

  Stream<QuerySnapshot> getMessageStream(int limit) {
    return db.collection(ROOM_COLLECTION)
        // .where('message', isEqualTo: "Hi")
        .orderBy('createdAt')
        // .limit(limit)
        .snapshots();
  }

}
