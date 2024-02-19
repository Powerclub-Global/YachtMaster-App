import 'package:cloud_firestore/cloud_firestore.dart';

/// creaated_at : ""
/// favourite_item_id : ""
/// id : ""
/// type : 0

class FavouriteModel {
  FavouriteModel({
      this.creaatedAt, 
      this.favouriteItemId, 
      this.id, 
      this.type,});

  FavouriteModel.fromJson(dynamic json) {
    creaatedAt = json['creaated_at'];
    favouriteItemId = json['favourite_item_id'];
    id = json['id'];
    type = json['type'];
  }
  Timestamp? creaatedAt;
  String? favouriteItemId;
  String? id;
  int? type;
FavouriteModel copyWith({  Timestamp? creaatedAt,
  String? favouriteItemId,
  String? id,
  int? type,
}) => FavouriteModel(  creaatedAt: creaatedAt ?? this.creaatedAt,
  favouriteItemId: favouriteItemId ?? this.favouriteItemId,
  id: id ?? this.id,
  type: type ?? this.type,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['creaated_at'] = creaatedAt;
    map['favourite_item_id'] = favouriteItemId;
    map['id'] = id;
    map['type'] = type;
    return map;
  }

}