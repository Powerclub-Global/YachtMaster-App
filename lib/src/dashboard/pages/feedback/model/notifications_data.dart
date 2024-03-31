import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yacht_master_admin/constants/enums.dart';

class NotificationsData {
  NotificationsData({
      this.refId, 
      this.notification, 
      this.createdFor, 
      this.createdAt, 
      this.id, 
      this.type, 
      this.isSeen, 
      this.createdBy,});

  NotificationsData.fromJson(dynamic json) {
    refId = json['ref_id'];
    notification = json['notification'];
    createdFor = json['created_for'];
    createdAt = json['created_at'];
    id = json['id'];
    type = NotificationsType.values[json['type']];
    isSeen = json['is_seen'];
    createdBy = json['created_by'];
  }
  String? refId;
  String? notification;
  String? createdFor;
  Timestamp? createdAt;
  String? id;
  NotificationsType? type;
  bool? isSeen;
  String? createdBy;
NotificationsData copyWith({  String? refId,
  String? notification,
  String? createdFor,
  Timestamp? createdAt,
  String? id,
  NotificationsType? type,
  bool? isSeen,
  String? createdBy,
}) => NotificationsData(  refId: refId ?? this.refId,
  notification: notification ?? this.notification,
  createdFor: createdFor ?? this.createdFor,
  createdAt: createdAt ?? this.createdAt,
  id: id ?? this.id,
  type: type ?? this.type,
  isSeen: isSeen ?? this.isSeen,
  createdBy: createdBy ?? this.createdBy,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ref_id'] = refId;
    map['notification'] = notification;
    map['created_for'] = createdFor;
    map['created_at'] = createdAt;
    map['id'] = id;
    map['type'] = type?.index;
    map['is_seen'] = isSeen;
    map['created_by'] = createdBy;
    return map;
  }

}