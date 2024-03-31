import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../constants/enums.dart';

class UserModel {
  UserModel({
    this.uid,
    this.fcm,
    this.number,
    this.dialCode,
    this.imageUrl,
    this.lastName,
    this.createdAt,
    this.phoneNumber,
    this.firstName,
    this.stripeCustomerID,
    this.isActiveUser,
    this.isFav = false,
    this.rating = 0.0,
    this.status,
    this.hostDocumentUrl,
    this.email,
    this.isCardSaved = false,
    this.role,
    this.requestStatus,
    this.inviteStatus,
  });

  UserModel.fromJson(dynamic json) {
    uid = json['uid'];
    fcm = json['fcm'];
    number = json['number'];
    isActiveUser = json['isActiveUser'] ?? true;
    dialCode = json['dial_code'];
    imageUrl = json['image_url'];
    lastName = json['last_name'];
    createdAt = json['created_at'];
    phoneNumber = json['phone_number'];
    firstName = json['first_name'];
    email = json['email'];
    stripeCustomerID = json['stripe_customer_id'];
    isCardSaved = json['is_card_saved'] ?? false;
    role = UserType.values[json['role'] ?? 0];
    requestStatus = RequestStatus.values[json['request_status'] ?? 0];
    status = UserStatus.values[json['status'] ?? 0];
    hostDocumentUrl = json['host_document_url'];
    this.inviteStatus = json['invite_status'];
  }
  String? uid;
  String? fcm;
  String? number;
  String? dialCode;
  String? imageUrl;
  String? hostDocumentUrl;
  bool? isCardSaved;
  String? lastName;
  Timestamp? createdAt;
  String? phoneNumber;
  String? firstName;
  String? email;
  String? stripeCustomerID;
  bool? isFav;
  bool? isActiveUser;
  UserStatus? status;
  UserType? role;
  RequestStatus? requestStatus;
  int? inviteStatus;
  var rating;
  UserModel copyWith(
          {String? uid,
          String? fcm,
          String? number,
          String? dialCode,
          String? imageUrl,
          String? hostDocumentUrl,
          String? lastName,
          Timestamp? createdAt,
          bool? isCardSaved,
          UserStatus? status,
          bool? isActiveUser,
          String? phoneNumber,
          String? firstName,
          String? stripeCustomerID,
          String? email,
          UserType? role,
          RequestStatus? requestStatus,
          int? inviteStatus}) =>
      UserModel(
          uid: uid ?? this.uid,
          fcm: fcm ?? this.fcm,
          isCardSaved: isCardSaved ?? this.isCardSaved,
          isActiveUser: isActiveUser ?? this.isActiveUser,
          hostDocumentUrl: hostDocumentUrl ?? this.hostDocumentUrl,
          status: status ?? this.status,
          requestStatus: requestStatus ?? this.requestStatus,
          number: number ?? this.number,
          role: role ?? this.role,
          dialCode: dialCode ?? this.dialCode,
          imageUrl: imageUrl ?? this.imageUrl,
          lastName: lastName ?? this.lastName,
          createdAt: createdAt ?? this.createdAt,
          phoneNumber: phoneNumber ?? this.phoneNumber,
          firstName: firstName ?? this.firstName,
          stripeCustomerID: stripeCustomerID ?? this.stripeCustomerID,
          email: email ?? this.email,
          inviteStatus: inviteStatus ?? this.inviteStatus);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = uid;
    map['is_card_saved'] = isCardSaved;
    map['host_document_url'] = hostDocumentUrl;
    map['isActiveUser'] = isActiveUser;
    map['fcm'] = fcm;
    map['number'] = number;
    map['dial_code'] = dialCode;
    map['image_url'] = imageUrl;
    map['last_name'] = lastName;
    map['created_at'] = createdAt;
    map['phone_number'] = phoneNumber;
    map['first_name'] = firstName;
    map['email'] = email;
    map['stripe_customer_id'] = stripeCustomerID;
    map['role'] = role?.index ?? 0;
    map['request_status'] = requestStatus?.index ?? 0;
    map['status'] = status?.index ?? 0;
    map['invite_status'] = inviteStatus;
    return map;
  }
}
//