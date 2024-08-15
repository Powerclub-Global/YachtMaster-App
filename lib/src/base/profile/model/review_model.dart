import 'package:cloud_firestore/cloud_firestore.dart';
import '../../search/view/bookings/model/bookings.dart';

/// booking_id : ""
/// user_id : ""
/// rating : 4.4
/// description : ""
/// created_at : ""
/// fleet_id : ""
/// host_id : ""

class ReviewModel {
  ReviewModel({
      this.bookingId, 
      this.userId, 
      this.rating, 
      this.description, 
      this.createdAt, 
      this.charterFleetDetail, this.id,
      this.hostId,});

  ReviewModel.fromJson(dynamic json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    rating = json['rating'];
    description = json['description'];
    createdAt = json['created_at'];
    charterFleetDetail = json['charter_fleet_detail'] != null ? CharterFleetDetail.fromJson(json['charter_fleet_detail']) : null;
    hostId = json['host_id'];
    id = json['id'];
  }
  String? bookingId;
  String? userId;
  var rating;
  String? description;
  String? id;
  Timestamp? createdAt;
  CharterFleetDetail? charterFleetDetail;
  String? hostId;
ReviewModel copyWith({  String? bookingId,
  String? userId,
  String? id,
  double? rating,
  String? description,
  Timestamp? createdAt,
  CharterFleetDetail? charterFleetDetail,
  String? hostId,
}) => ReviewModel(  bookingId: bookingId ?? this.bookingId,
  userId: userId ?? this.userId,
  id: id ?? this.id,
  rating: rating ?? this.rating,
  description: description ?? this.description,
  createdAt: createdAt ?? this.createdAt,
  charterFleetDetail: charterFleetDetail ?? this.charterFleetDetail,
  hostId: hostId ?? this.hostId,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['booking_id'] = bookingId;
    map['user_id'] = userId;
    map['rating'] = rating;
    map['description'] = description;
    map['created_at'] = createdAt;
    if (charterFleetDetail != null) {
      map['charter_fleet_detail'] = charterFleetDetail?.toJson();
    }
    map['host_id'] = hostId;
    map['id'] = id;
    return map;
  }

}
// /// image : ""
// /// name : ""
// /// location : ""
// /// id : "1660585301388"
//
// class CharterFleetDetail {
//   CharterFleetDetail({
//     this.image,
//     this.name,
//     this.location,
//     this.id,});
//
//   CharterFleetDetail.fromJson(dynamic json) {
//     image = json['image'];
//     name = json['name'];
//     location = json['location'];
//     id = json['id'];
//   }
//   String? image;
//   String? name;
//   String? location;
//   String? id;
//   CharterFleetDetail copyWith({  String? image,
//     String? name,
//     String? location,
//     String? id,
//   }) => CharterFleetDetail(  image: image ?? this.image,
//     name: name ?? this.name,
//     location: location ?? this.location,
//     id: id ?? this.id,
//   );
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['image'] = image;
//     map['name'] = name;
//     map['location'] = location;
//     map['id'] = id;
//     return map;
//   }
//
// }