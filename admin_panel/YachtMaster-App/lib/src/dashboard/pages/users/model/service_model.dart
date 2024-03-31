import 'package:cloud_firestore/cloud_firestore.dart';

/// images : [""]
/// name : ""
/// created_at : ""
/// description : ""
/// location : {"address":"","log":0,"lat":0}
/// id : ""
/// created_by : ""

class ServiceModel {
  ServiceModel({
    this.images,
    this.name,
    this.createdAt,
    this.description,
    this.location,
    this.id,this.status,
    this.isFav=false,
    this.createdBy,});

  ServiceModel.fromJson(dynamic json) {
    images = json['images'] != null ? json['images'].cast<String>() : [];
    status = json['status'];
    name = json['name'];
    createdAt = json['created_at'];
    description = json['description'];
    location = json['location'] != null ? LocationModel.fromJson(json['location']) : null;
    id = json['id'];
    createdBy = json['created_by'];
  }
  List<String>? images;
  String? name;
  int? status;
  Timestamp? createdAt;
  String? description;
  LocationModel? location;
  String? id;
  String? createdBy;
  bool? isFav;
  ServiceModel copyWith({  List<String>? images,
    String? name,
    int? status,
    Timestamp? createdAt,
    String? description,
    LocationModel? location,
    String? id,
    String? createdBy,
  }) => ServiceModel(  images: images ?? this.images,
    name: name ?? this.name,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    description: description ?? this.description,
    location: location ?? this.location,
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['images'] = images;
    map['status'] = status;
    map['name'] = name;
    map['created_at'] = createdAt;
    map['description'] = description;
    if (location != null) {
      map['location'] = location?.toJson();
    }
    map['id'] = id;
    map['created_by'] = createdBy;
    return map;
  }

}

/// address : ""
/// log : 0
/// lat : 0

class LocationModel {
  LocationModel({
    this.address,
    this.log, this.city,
    this.lat,});

  LocationModel.fromJson(dynamic json) {
    address = json['address'];
    city = json['city'];
    log = json['log'];
    lat = json['lat'];
  }
  String? address;
  String? city;
  double? log;
  double? lat;
  LocationModel copyWith({
    String? address,
    String? city,
    double? log,
    double? lat,
  }) => LocationModel(  address: address ?? this.address,
    log: log ?? this.log,
    city: city ?? this.city,
    lat: lat ?? this.lat,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['address'] = address;
    map['city'] = city;
    map['log'] = log;
    map['lat'] = lat;
    return map;
  }

}