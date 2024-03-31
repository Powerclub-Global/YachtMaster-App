import 'package:cloud_firestore/cloud_firestore.dart';

/// feedback : ""
/// user_id : ""
/// rating : ""
/// created_at : ""

class AppFeedbackModel {
  AppFeedbackModel({
    this.feedback,
    this.userId,
    this.rating,
    this.createdAt,this.id,this.pricture,
    this.userName,this.phoneNumber});

  AppFeedbackModel.fromJson(dynamic json) {
    feedback = json['feedback'];
    userId = json['user_id'];
    id = json['id'];
    rating = json['rating'];
    createdAt = json['created_at'];
  }
  String? feedback;
  String? id;
  String? userId;
  String? pricture;
  String? userName;
  String? phoneNumber;
  double? rating;
  Timestamp? createdAt;
  AppFeedbackModel copyWith({  String? feedback,
    String? userId,
    String? id,
    double? rating,
    Timestamp? createdAt,
  }) => AppFeedbackModel(  feedback: feedback ?? this.feedback,
    userId: userId ?? this.userId,
    rating: rating ?? this.rating,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['feedback'] = feedback;
    map['user_id'] = userId;
    map['id'] = id;
    map['rating'] = rating;
    map['created_at'] = createdAt;
    return map;
  }

}