import 'package:cloud_firestore/cloud_firestore.dart';

/// full_name : ""
/// subject : ""
/// created_at : ""
/// description : ""
/// email : ""

class NeighborhoodSupportModel {
  NeighborhoodSupportModel({
      this.fullName, 
      this.subject, 
      this.createdAt, 
      this.description, 
      this.email,});

  NeighborhoodSupportModel.fromJson(dynamic json) {
    fullName = json['full_name'];
    subject = json['subject'];
    createdAt = json['created_at'];
    description = json['description'];
    email = json['email'];
  }
  String? fullName;
  String? subject;
  Timestamp? createdAt;
  String? description;
  String? email;
NeighborhoodSupportModel copyWith({  String? fullName,
  String? subject,
  Timestamp? createdAt,
  String? description,
  String? email,
}) => NeighborhoodSupportModel(  fullName: fullName ?? this.fullName,
  subject: subject ?? this.subject,
  createdAt: createdAt ?? this.createdAt,
  description: description ?? this.description,
  email: email ?? this.email,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['full_name'] = fullName;
    map['subject'] = subject;
    map['created_at'] = createdAt;
    map['description'] = description;
    map['email'] = email;
    return map;
  }

}