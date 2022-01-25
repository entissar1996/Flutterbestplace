import 'package:get/get.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../Controllers/auth_service.dart';

class Message {
  AuthService _controller = Get.put(AuthService());

  String id;
  String content;
  String senderUid;
  String receiverUid;
  String createAt;

  Message({this.id, this.content, this.senderUid, this.receiverUid, this.createAt});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        id: json['id'],
        content :json["content"],
        senderUid : json["senderUid"],
        receiverUid :json["receiverUid"],
        createAt :json["createAt"]);
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'createAt': createAt,
    };
  }
  bool get isMe=>_controller.idController==senderUid;
}
