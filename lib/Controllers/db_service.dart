import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterbestplace/models/messages.dart';
import 'package:flutterbestplace/models/user.dart';
import 'package:get/get.dart';

import '../Screens/home.dart';
import 'auth_service.dart';

class DBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService _controller = Get.put(AuthService());
  final MessageRef = FirebaseFirestore.instance.collection("messages");

  Future<dynamic> createNewUser(CUser user) async {
    try {
      await _firestore.collection("user").doc(user.id).set(user.toJson());

      return true;
    } catch (e) {
      return e.message;
    }
  }

  Future<CUser> getUser(String uid) async {
    try {
      final usersRef = await FirebaseFirestore.instance
          .collection('user')
          .withConverter<CUser>(
            fromFirestore: (snapshot, _) => CUser.fromJson(snapshot.data()),
            toFirestore: (user, _) => user.toJson(),
          );
      CUser userdata =
          await usersRef.doc(uid).get().then((snapshot) => snapshot.data());
      print("***********User**************");
      print(userdata.toJson());
      return userdata;
    } catch (e) {
      print("FAILED GET USER");
    }
  }

  Stream<List<CUser>> get getDiscussionUser {
    return usersRef
        .where('id',whereNotIn:  ["Rmcp0g0yjkaTaad6T9pw4hN9q0q2", _controller.idController] )
        .snapshots()
        .map((event) =>
            event.docs.map((e) => CUser.fromJson(e.data())).toList());
  }
  Stream<List<CUser>> get getAllUser {
    return usersRef
        .where('id',whereNotIn:  ["Rmcp0g0yjkaTaad6T9pw4hN9q0q2", _controller.idController] )
        .snapshots()
        .map((event) =>
        event.docs.map((e) => CUser.fromJson(e.data())).toList());
  }

  Stream<List<Messages>> getMessage(String receiverUid,
      [bool myMessage = true]) {
    print("***********Message**************");
    return MessageRef.where('senderUid',
            isEqualTo: myMessage ? _controller.idController : receiverUid)
        .where('receiverUid',
            isEqualTo: myMessage ? receiverUid : _controller.idController)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => Messages.fromJson(e.data())).toList());

  }
  Future<bool> sendMessage(Messages msg) async {
    try {
      await MessageRef.doc().set(msg.toJson());
      return true;
    }
    catch (e) {
      return false;
    }
  }
}
