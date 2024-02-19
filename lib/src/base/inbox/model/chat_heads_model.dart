import 'package:cloud_firestore/cloud_firestore.dart';

/// created_at : ""
/// id : ""
/// created_by : ""
/// users : [""]
/// status : 0
/// peer_id : ""

class ChatHeadModel {
  ChatHeadModel({
    this.createdAt,
    this.id,
    this.createdBy, this.lastMessage,this.lastMessageTime,
    this.users,
    this.status,
    this.peerId,});

  ChatHeadModel.fromJson(dynamic json) {
    createdAt = json['created_at'];
    lastMessageTime = json['last_message_time'];
    lastMessage = json['last_message'];
    id = json['id'];
    createdBy = json['created_by'];
    users = json['users'] != null ? json['users'].cast<String>() : [];
    status = json['status'];
    peerId = json['peer_id'];
  }
  Timestamp? createdAt;
  Timestamp? lastMessageTime;
  String? id;
  String? createdBy;
  String? lastMessage;
  List<String>? users;
  int? status;
  String? peerId;
  ChatHeadModel copyWith({
    Timestamp? createdAt,
    Timestamp? lastMessageTime,
    String? id,
    String? createdBy,
    String? lastMessage,
    List<String>? users,
    int? status,
    String? peerId,
  }) => ChatHeadModel(
    createdAt: createdAt ?? this.createdAt,
    lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    lastMessage: lastMessage ?? this.lastMessage,
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    users: users ?? this.users,
    status: status ?? this.status,
    peerId: peerId ?? this.peerId,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['created_at'] = createdAt;
    map['last_message'] = lastMessage;
    map['last_message_time'] = lastMessageTime;
    map['id'] = id;
    map['created_by'] = createdBy;
    map['users'] = users;
    map['status'] = status;
    map['peer_id'] = peerId;
    return map;
  }

}