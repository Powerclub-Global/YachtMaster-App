import 'package:cloud_firestore/cloud_firestore.dart';

/// images : ["https://firebasestorage.googleapis.com/v0/b/yacht-masters.appspot.com/o/charterImages%2FLiUaAj9KAcU4osmvTKJ8x2lTj7S2%2F2022-08-11%2018%3A13%3A52.768281?alt=media&token=9ab7e9ce-59c1-42ee-b4f6-0495f7ebf239"]
/// cancelation_policy : {"description":"desc","title":"policy"}
/// created_at : ""
/// price_full_day : 10000.0
/// availability : {"start_time":"05:34 PM","half_day_slots":[{"start":"","end":""}],"full_day_slots":[{"start":"","end":""}],"end_time":"06:34 PM","dates":["",""]}
/// created_by : "LiUaAj9KAcU4osmvTKJ8x2lTj7S2"
/// is_pet_allow : false
/// health_safety : {"description":"desc","title":"health"}
/// guest_capacity : 10
/// sub_heading : "subhead"
/// yacht_rules : {"description":"desc","title":"yaxht"}
/// name : "CharterX"
/// charters_offers : ["1659694716955","1659694795736"]
/// location : {"city":"Kot Radha Kishan","adress":"54M2+G6G ,Kot Radha Kishan","long":74.10064447671175,"lat":31.18301664296288}
/// id : "1660223632750"
/// price_half_day : 5000.0

class CharterModel {
  CharterModel({
    this.images,
    this.cancelationPolicy,
    this.createdAt,
    this.priceFullDay,
    this.availability,
    this.createdBy,
    this.isPetAllow,
    this.healthSafety,
    this.guestCapacity,
    this.subHeading,
    this.yachtRules,
    this.name,
    this.chartersOffers,
    this.location,
    this.id,
    this.status,
    this.priceFourHours,
    this.priceHalfDay,});

  CharterModel.fromJson(dynamic json) {
    images = json['images'] != null ? json['images'].cast<String>() : [];
    cancelationPolicy = json['cancelation_policy'] != null ? CancelationPolicy.fromJson(json['cancelation_policy']) : null;
    createdAt = json['created_at'];
    priceFullDay = json['price_full_day'];
    availability = json['availability'] != null ? Availability.fromJson(json['availability']) : null;
    createdBy = json['created_by'];
    status = json['status'];
    isPetAllow = json['is_pet_allow'];
    healthSafety = json['health_safety'] != null ? HealthSafety.fromJson(json['health_safety']) : null;
    guestCapacity = json['guest_capacity'];
    subHeading = json['sub_heading'];
    yachtRules = json['yacht_rules'] != null ? YachtRules.fromJson(json['yacht_rules']) : null;
    name = json['name'];
    chartersOffers = json['charters_offers'] != null ? json['charters_offers'].cast<String>() : [];
    location = json['location'] != null ? CharterLocationModel.fromJson(json['location']) : null;
    id = json['id'];
    priceHalfDay = json['price_half_day'];
    priceFourHours = json['price_four_hours'];
  }
  List<String>? images;
  CancelationPolicy? cancelationPolicy;
  Timestamp? createdAt;
  double? priceFullDay;
  Availability? availability;
  String? createdBy;
  bool? isPetAllow;
  HealthSafety? healthSafety;
  int? guestCapacity;
  String? subHeading;
  YachtRules? yachtRules;
  String? name;
  List<String>? chartersOffers;
  CharterLocationModel? location;
  String? id;
  int? status;
  double? priceHalfDay;
  double? priceFourHours;
  CharterModel copyWith({  List<String>? images,
    CancelationPolicy? cancelationPolicy,
    Timestamp? createdAt,
    double? priceFullDay,
    int? status,
    Availability? availability,
    String? createdBy,
    bool? isPetAllow,
    HealthSafety? healthSafety,
    int? guestCapacity,
    String? subHeading,
    YachtRules? yachtRules,
    String? name,
    List<String>? chartersOffers,
    CharterLocationModel? location,
    String? id,
    double? priceHalfDay,
    double? priceFourHours,
  }) => CharterModel(  images: images ?? this.images,
    cancelationPolicy: cancelationPolicy ?? this.cancelationPolicy,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    priceFullDay: priceFullDay ?? this.priceFullDay,
    availability: availability ?? this.availability,
    createdBy: createdBy ?? this.createdBy,
    isPetAllow: isPetAllow ?? this.isPetAllow,
    healthSafety: healthSafety ?? this.healthSafety,
    guestCapacity: guestCapacity ?? this.guestCapacity,
    subHeading: subHeading ?? this.subHeading,
    yachtRules: yachtRules ?? this.yachtRules,
    name: name ?? this.name,
    chartersOffers: chartersOffers ?? this.chartersOffers,
    location: location ?? this.location,
    id: id ?? this.id,
    priceHalfDay: priceHalfDay ?? this.priceHalfDay,
    priceFourHours: priceFourHours ?? this.priceFourHours,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['images'] = images;
    map['status'] = status;
    if (cancelationPolicy != null) {
      map['cancelation_policy'] = cancelationPolicy?.toJson();
    }
    map['created_at'] = createdAt;
    map['price_full_day'] = priceFullDay;
    if (availability != null) {
      map['availability'] = availability?.toJson();
    }
    map['created_by'] = createdBy;
    map['is_pet_allow'] = isPetAllow;
    if (healthSafety != null) {
      map['health_safety'] = healthSafety?.toJson();
    }
    map['guest_capacity'] = guestCapacity;
    map['sub_heading'] = subHeading;
    if (yachtRules != null) {
      map['yacht_rules'] = yachtRules?.toJson();
    }
    map['name'] = name;
    map['charters_offers'] = chartersOffers;
    if (location != null) {
      map['location'] = location?.toJson();
    }
    map['id'] = id;
    map['price_half_day'] = priceHalfDay;
    map['price_four_hours'] = priceFourHours;
    return map;
  }

}

/// city : "Kot Radha Kishan"
/// adress : "54M2+G6G ,Kot Radha Kishan"
/// long : 74.10064447671175
/// lat : 31.18301664296288

class CharterLocationModel {
  CharterLocationModel({
    this.city,
    this.adress,
    this.long,
    this.lat,});

  CharterLocationModel.fromJson(dynamic json) {
    city = json['city'];
    adress = json['adress'];
    long = json['long'];
    lat = json['lat'];
  }
  String? city;
  String? adress;
  double? long;
  double? lat;
  CharterLocationModel copyWith({  String? city,
    String? adress,
    double? long,
    double? lat,
  }) => CharterLocationModel(  city: city ?? this.city,
    adress: adress ?? this.adress,
    long: long ?? this.long,
    lat: lat ?? this.lat,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['city'] = city;
    map['adress'] = adress;
    map['long'] = long;
    map['lat'] = lat;
    return map;
  }

}

/// description : "desc"
/// title : "yaxht"

class YachtRules {
  YachtRules({
    this.description,
    this.title,});

  YachtRules.fromJson(dynamic json) {
    description = json['description'];
    title = json['title'];
  }
  String? description;
  String? title;
  YachtRules copyWith({  String? description,
    String? title,
  }) => YachtRules(  description: description ?? this.description,
    title: title ?? this.title,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['description'] = description;
    map['title'] = title;
    return map;
  }

}

/// description : "desc"
/// title : "health"

class HealthSafety {
  HealthSafety({
    this.description,
    this.title,});

  HealthSafety.fromJson(dynamic json) {
    description = json['description'];
    title = json['title'];
  }
  String? description;
  String? title;
  HealthSafety copyWith({  String? description,
    String? title,
  }) => HealthSafety(  description: description ?? this.description,
    title: title ?? this.title,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['description'] = description;
    map['title'] = title;
    return map;
  }

}

/// start_time : "05:34 PM"
/// half_day_slots : [{"start":"","end":""}]
/// full_day_slots : [{"start":"","end":""}]
/// end_time : "06:34 PM"
/// dates : ["",""]

class Availability {
  Availability({
    this.startTime,
    this.halfDaySlots,
    this.fourHoursSlot,
    this.fullDaySlots,
    this.endTime,
    this.dates,});

  Availability.fromJson(dynamic json) {
    startTime = json['start_time'];
    if (json['four_hours_slots'] != null) {
      fourHoursSlot = [];
      json['four_hours_slots'].forEach((v) {
        fourHoursSlot?.add(HalfDaySlots.fromJson(v));
      });
    }
    if (json['half_day_slots'] != null) {
      halfDaySlots = [];
      json['half_day_slots'].forEach((v) {
        halfDaySlots?.add(HalfDaySlots.fromJson(v));
      });
    }
    if (json['full_day_slots'] != null) {
      fullDaySlots = [];
      json['full_day_slots'].forEach((v) {
        fullDaySlots?.add(FullDaySlots.fromJson(v));
      });
    }
    endTime = json['end_time'];
    dates = json['dates'] != null ? json['dates'].cast<Timestamp>() : [];
  }
  String? startTime;
  List<HalfDaySlots>? halfDaySlots;
  List<HalfDaySlots>? fourHoursSlot;
  List<FullDaySlots>? fullDaySlots;
  String? endTime;
  List<Timestamp>? dates;
  Availability copyWith({  String? startTime,
    List<HalfDaySlots>? halfDaySlots,
    List<HalfDaySlots>? fourHoursSlot,
    List<FullDaySlots>? fullDaySlots,
    String? endTime,
    List<Timestamp>? dates,
  }) => Availability(  startTime: startTime ?? this.startTime,
    halfDaySlots: halfDaySlots ?? this.halfDaySlots,
    fourHoursSlot: fourHoursSlot ?? this.fourHoursSlot,
    fullDaySlots: fullDaySlots ?? this.fullDaySlots,
    endTime: endTime ?? this.endTime,
    dates: dates ?? this.dates,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['start_time'] = startTime;
    if (fourHoursSlot != null) {
      map['four_hours_slots'] = fourHoursSlot?.map((v) => v.toJson()).toList();
    }
    if (halfDaySlots != null) {
      map['half_day_slots'] = halfDaySlots?.map((v) => v.toJson()).toList();
    }
    if (fullDaySlots != null) {
      map['full_day_slots'] = fullDaySlots?.map((v) => v.toJson()).toList();
    }
    map['end_time'] = endTime;
    map['dates'] = dates;
    return map;
  }

}

/// start : ""
/// end : ""

class FullDaySlots {
  FullDaySlots({
    this.start, this.status,
    this.end,});

  FullDaySlots.fromJson(dynamic json) {
    start = json['start'];
    end = json['end'];
    status = json['status'];
  }
  String? start;
  String? end;
  int? status;
  FullDaySlots copyWith({  String? start,
    String? end,
    int? status,
  }) => FullDaySlots(  start: start ?? this.start,
    end: end ?? this.end,
    status: status ?? this.status,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['start'] = start;
    map['end'] = end;
    map['status'] = status;
    return map;
  }

}

/// start : ""
/// end : ""

class HalfDaySlots {
  HalfDaySlots({
    this.start,
    this.end,this.status=0});

  HalfDaySlots.fromJson(dynamic json) {
    start = json['start'];
    end = json['end'];
    status = json['status'];
  }
  String? start;
  String? end;
  int? status;
  HalfDaySlots copyWith({  String? start,
    String? end,
    int? status,
  }) => HalfDaySlots(  start: start ?? this.start,
    end: end ?? this.end,
    status: status ?? this.status,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['start'] = start;
    map['end'] = end;
    map['status'] = status;
    return map;
  }

}

/// description : "desc"
/// title : "policy"

class CancelationPolicy {
  CancelationPolicy({
    this.description,
    this.title,});

  CancelationPolicy.fromJson(dynamic json) {
    description = json['description'];
    title = json['title'];
  }
  String? description;
  String? title;
  CancelationPolicy copyWith({  String? description,
    String? title,
  }) => CancelationPolicy(  description: description ?? this.description,
    title: title ?? this.title,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['description'] = description;
    map['title'] = title;
    return map;
  }

}