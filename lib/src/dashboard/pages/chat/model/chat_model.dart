import 'package:cloud_firestore/cloud_firestore.dart';

/// receiver_id : ""
/// created_at : ""
/// chat_head_id : ""
/// type : 0
/// is_seen : true
/// message : ""
/// sender_id : ""

class ChatModel {
  ChatModel({
      this.receiverId, 
      this.createdAt, 
      this.chatHeadId, 
      this.type, 
      this.isSeen, 
      this.message,
      this.senderId,});

  ChatModel.fromJson(dynamic json) {
    receiverId = json['receiver'];
    createdAt = json['created_at'];
    chatHeadId = json['chat_head_id'];
    type = json['type'];
    isSeen = json['is_seen'];
    message = json['message'];
    senderId = json['sender'];
  }
  String? receiverId;
  Timestamp? createdAt;
  String? chatHeadId;
  int? type;
  bool? isSeen;
  String? message;
  String? senderId;
  Timestamp? updatedAt;

  ChatModel copyWith({  String? receiverId,
  Timestamp? createdAt,
  String? chatHeadId,
  int? type,
  bool? isSeen,
  String? message,
  String? senderId,
}) => ChatModel(  receiverId: receiverId ?? this.receiverId,
  createdAt: createdAt ?? this.createdAt,
  chatHeadId: chatHeadId ?? this.chatHeadId,
    type: type ?? this.type,
  isSeen: isSeen ?? this.isSeen,
  message: message ?? this.message,
  senderId: senderId ?? this.senderId,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['receiver'] = receiverId;
    map['created_at'] = createdAt;
    map['chat_head_id'] = chatHeadId;
    map['type'] = type;
    map['is_seen'] = isSeen;
    map['message'] = message;
    map['sender'] = senderId;

    return map;
  }

}