import 'package:cloud_firestore/cloud_firestore.dart';

/// receiver_id : ""
/// created_at : ""
/// chat_head_id : ""
/// type : 0
/// message : ""
/// is_seen : ""
/// sender_id : ""

class ChatModel {
  ChatModel({
      this.receiverId, 
      this.createdAt, 
      this.chatHeadId, 
      this.type, 
      this.message, 
      this.isSeen, 
      this.senderId,});

  ChatModel.fromJson(dynamic json) {
    receiverId = json['receiver_id'];
    createdAt = json['created_at'];
    chatHeadId = json['chat_head_id'];
    type = json['type'];
    message = json['message'];
    isSeen = json['is_seen'];
    senderId = json['sender_id'];
  }
  String? receiverId;
  Timestamp? createdAt;
  String? chatHeadId;
  int? type;
  String? message;
  bool? isSeen;
  String? senderId;
ChatModel copyWith({  String? receiverId,
  Timestamp? createdAt,
  String? chatHeadId,
  int? type,
  String? message,
  bool? isSeen,
  String? senderId,
}) => ChatModel(  receiverId: receiverId ?? this.receiverId,
  createdAt: createdAt ?? this.createdAt,
  chatHeadId: chatHeadId ?? this.chatHeadId,
  type: type ?? this.type,
  message: message ?? this.message,
  isSeen: isSeen ?? this.isSeen,
  senderId: senderId ?? this.senderId,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['receiver_id'] = receiverId;
    map['created_at'] = createdAt;
    map['chat_head_id'] = chatHeadId;
    map['type'] = type;
    map['message'] = message;
    map['is_seen'] = isSeen;
    map['sender_id'] = senderId;
    return map;
  }

}