import 'package:cloud_firestore/cloud_firestore.dart';

/// images : [""]
/// price : 0
/// name : ""
/// created_at : ""
/// description : ""
/// location : {"address":"","long":"","lat":""}
/// created_by : ""

class YachtsModel {
  YachtsModel({
    this.images,
    this.price,
    this.name,
    this.createdAt,
    this.id,this.status,
    this.description,
    this.location,
    this.createdBy,});

  YachtsModel.fromJson(dynamic json) {
    images = json['images'] != null ? json['images'].cast<String>() : [];
    status = json['status'];
    price = json['price'];
    name = json['name'];
    id = json['id'];
    createdAt = json['created_at'];
    description = json['description'];
    location = json['location'] != null ? YachtLocation.fromJson(json['location']) : null;
    createdBy = json['created_by'];
  }
  List<String>? images;
  double? price;
  String? name;
  String? id;
  int? status;
  Timestamp? createdAt;
  String? description;
  YachtLocation? location;
  String? createdBy;
  YachtsModel copyWith({  List<String>? images,
    double? price,
    String? name,
    int? status,
    String? id,
    Timestamp? createdAt,
    String? description,
    YachtLocation? location,
    String? createdBy,
  }) => YachtsModel(  images: images ?? this.images,
    price: price ?? this.price,
    name: name ?? this.name,
    status: status ?? this.status,
    id: name ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    description: description ?? this.description,
    location: location ?? this.location,
    createdBy: createdBy ?? this.createdBy,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['images'] = images;
    map['status'] = status;
    map['price'] = price;
    map['name'] = name;
    map['id'] = id;
    map['created_at'] = createdAt;
    map['description'] = description;
    if (location != null) {
      map['location'] = location?.toJson();
    }
    map['created_by'] = createdBy;
    return map;
  }

}

/// address : ""
/// long : ""
/// lat : ""

class YachtLocation {
  YachtLocation({
    this.address,
    this.long, this.city,
    this.lat,});

  YachtLocation.fromJson(dynamic json) {
    address = json['address'];
    city = json['city'];
    long = json['long'];
    lat = json['lat'];
  }
  String? address;
  String? city;
  double? long;
  double? lat;
  YachtLocation copyWith({
    String? address,
    String? city,
    double? long,
    double? lat,
  }) => YachtLocation(
    address: address ?? this.address,
    city: city ?? this.city,
    long: long ?? this.long,
    lat: lat ?? this.lat,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['address'] = address;
    map['city'] = city;
    map['long'] = long;
    map['lat'] = lat;
    return map;
  }

}