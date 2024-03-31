import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_model.dart';

/// updated_at : ""
/// created_at : ""
/// last_message : {"updated_at":"","receiver_id":"","created_at":"","chat_head_id":"","is_seen":true,"message":"","type":0,"sender_id":""}
/// id : "1667565229561"
/// created_by : "a7VXf3w85VNAU6av0lpgFeMFXOl1"
/// users : ["a7VXf3w85VNAU6av0lpgFeMFXOl1","1667542947672"]
/// status : 0
/// peer_id : "a7VXf3w85VNAU6av0lpgFeMFXOl1"

class ChatHeadModel {
  ChatHeadModel({
    this.lastMessage,
    this.id,
    this.users,
    this.status,
    this.createdAt

  });

  ChatHeadModel.fromJson(dynamic json) {
    lastMessage = json['last_message'] != null
        ? ChatModel.fromJson(json['last_message'])
        : null;
    id = json['id'];
    users = json['users'] != null ? json['users'].cast<String>() : [];
    status = json['status'];
    createdAt = json['created_at'];

  }

  ChatModel? lastMessage;
  String? id;
  List<String>? users;
  int? status;
  Timestamp? createdAt;

  ChatHeadModel copyWith({
    ChatModel? lastMessage,
    String? id,
    List<String>? users,
    int? status,
    Timestamp? createdAt

  }) =>
      ChatHeadModel(
        lastMessage: lastMessage ?? this.lastMessage,
        id: id ?? this.id,
        users: users ?? this.users,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,

      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (lastMessage != null) {
      map['last_message'] = lastMessage?.toJson();
    }
    map['id'] = id;
    map['users'] = users;
    map['status'] = status;
    map['created_at'] = createdAt;

    return map;
  }
}

