import 'package:cloud_firestore/cloud_firestore.dart';

/// created_at : ""
/// title : "Safety Center"
/// type : 2
/// content : "safety center description"

class ContentModel {
  ContentModel({
    this.createdAt,
    this.title,
    this.type,
    this.content,});

  ContentModel.fromJson(dynamic json) {
    createdAt = json['created_at'];
    title = json['title'];
    type = json['type'];
    content = json['content'];
  }
  Timestamp? createdAt;
  String? title;
  int? type;
  String? content;
  ContentModel copyWith({  Timestamp? createdAt,
    String? title,
    int? type,
    String? content,
  }) => ContentModel(  createdAt: createdAt ?? this.createdAt,
    title: title ?? this.title,
    type: type ?? this.type,
    content: content ?? this.content,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['created_at'] = createdAt;
    map['title'] = title;
    map['type'] = type;
    map['content'] = content;
    return map;
  }

}