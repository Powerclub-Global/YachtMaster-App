import 'package:cloud_firestore/cloud_firestore.dart';

/// booking_id : ""
/// receiver : [""]
/// sender : ""
/// created_at : ""
/// text : ""
/// is_seen : false
/// type : 0
/// title : ""

class NotificationModel {
  NotificationModel({
    this.bookingId,
    this.receiver,
    this.sender,
    this.createdAt,
    this.text,
    this.isSeen, this.hostUserId,
    this.type,
    this.id,
    this.title,});

  NotificationModel.fromJson(dynamic json) {
    bookingId = json['booking_id'];
    hostUserId = json['host_user_id'];
    receiver = json['receiver'] != null ? json['receiver'].cast<String>() : [];
    sender = json['sender'];
    createdAt = json['created_at'];
    text = json['text'];
    isSeen = json['is_seen'];
    type = json['type'];
    title = json['title'];
    id = json['id'];
  }
  String? bookingId;
  String? id;
  List<String?>? receiver;
  String? sender;
  Timestamp? createdAt;
  String? text;
  bool? isSeen;
  int? type;
  String? title;
  String? hostUserId;
  NotificationModel copyWith({  String? bookingId,
    List<String>? receiver,
    String? sender,
    String? id,
    String? hostUserId,
    Timestamp? createdAt,
    String? text,
    bool? isSeen,
    int? type,
    String? title,
  }) => NotificationModel(  bookingId: bookingId ?? this.bookingId,
    receiver: receiver ?? this.receiver,
    id: id ?? this.id,
    hostUserId: hostUserId ?? this.hostUserId,
    sender: sender ?? this.sender,
    createdAt: createdAt ?? this.createdAt,
    text: text ?? this.text,
    isSeen: isSeen ?? this.isSeen,
    type: type ?? this.type,
    title: title ?? this.title,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['booking_id'] = bookingId;
    map['receiver'] = receiver;
    map['id'] = id;
    map['host_user_id'] = hostUserId;
    map['sender'] = sender;
    map['created_at'] = createdAt;
    map['text'] = text;
    map['is_seen'] = isSeen;
    map['type'] = type;
    map['title'] = title;
    return map;
  }

}