import 'package:get/get.dart';

import '../Controllers/auth_service.dart';

class Messages {
  AuthService _controller = Get.put(AuthService());

   String id;
   String senderUid;
   String receiverUid;
   String roomId;
   String message;
   int messageType;
   DateTime createdAt;

   Messages({
    this.id,
    this.senderUid,
    this.receiverUid,
    this.roomId,
    this.message,
    this.messageType,
    this.createdAt,
  });

 /* static Messages fromJson(Map<String, dynamic> json) => Messages(
        id: json['id'],
        senderUid: json['senderUid'],
        receiverUid: json['receiverUid'],
        roomId: json['roomId'],
        message: json['message'],
        messageType: json['messageType'],
        createdAt: json['createdAt']?.toDate(),
      );*/
  factory Messages.fromJson(Map<String, dynamic> json) {
    return Messages(
        id: json['id'],
        senderUid: json['senderUid'],
        receiverUid: json['receiverUid'],
        roomId: json['roomId'],
        message: json['message'],
        messageType: json['messageType'],
        createdAt: json['createdAt']?.toDate());
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'senderUid': senderUid,
        'receiverUid': receiverUid,
        'roomId': roomId,
        'message': message,
        'messageType': messageType,
        'createdAt': createdAt.toUtc(),
      };
  bool get isMe=>_controller.idController==senderUid;

}
