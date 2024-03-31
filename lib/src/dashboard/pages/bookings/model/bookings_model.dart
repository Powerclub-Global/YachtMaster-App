import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class BookingsModel {
  BookingsModel({
    this.totalGuest,
    this.charterFleetDetail,
    this.paymentDetail,
    this.schedule,
    this.durationType,
    this.createdAt,
    this.bookingStatus,
    this.id,
    this.createdBy,
    this.hostUserUid,
    this.priceDetaill,
  });

  BookingsModel.fromJson(dynamic json) {
    totalGuest = json['total_guest'];
    charterFleetDetail =
    json['charter_fleet_detail'] != null ? CharterFleetDetail.fromJson(json['charter_fleet_detail']) : null;
    paymentDetail = json['payment_detail'] != null ? PaymentDetail.fromJson(json['payment_detail']) : null;
    schedule = json['schedule '] != null ? BookingScheduleModel.fromJson(json['schedule ']) : null;
    durationType = json['duration_type'];
    createdAt = json['created_at'];
    bookingStatus = json['booking_status'];
    id = json['id'];
    createdBy = json['created_by'];
    hostUserUid = json['host_user_uid'];
    priceDetaill = json['price_detaill'] != null ? PriceDetaill.fromJson(json['price_detaill']) : null;
  }
  int? totalGuest;
  CharterFleetDetail? charterFleetDetail;
  PaymentDetail? paymentDetail;
  BookingScheduleModel? schedule;
  int? durationType;
  Timestamp? createdAt;
  int? bookingStatus;
  String? id;
  String? createdBy;
  String? hostUserUid;
  PriceDetaill? priceDetaill;
  BookingsModel copyWith({
    int? totalGuest,
    CharterFleetDetail? charterFleetDetail,
    PaymentDetail? paymentDetail,
    BookingScheduleModel? schedule,
    int? durationType,
    Timestamp? createdAt,
    int? bookingStatus,
    String? id,
    String? createdBy,
    String? hostUserUid,
    PriceDetaill? priceDetaill,
  }) =>
      BookingsModel(
        totalGuest: totalGuest ?? this.totalGuest,
        charterFleetDetail: charterFleetDetail ?? this.charterFleetDetail,
        paymentDetail: paymentDetail ?? this.paymentDetail,
        schedule: schedule ?? this.schedule,
        durationType: durationType ?? this.durationType,
        createdAt: createdAt ?? this.createdAt,
        bookingStatus: bookingStatus ?? this.bookingStatus,
        id: id ?? this.id,
        createdBy: createdBy ?? this.createdBy,
        hostUserUid: hostUserUid ?? this.hostUserUid,
        priceDetaill: priceDetaill ?? this.priceDetaill,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total_guest'] = totalGuest;
    if (charterFleetDetail != null) {
      map['charter_fleet_detail'] = charterFleetDetail?.toJson();
    }
    if (paymentDetail != null) {
      map['payment_detail'] = paymentDetail?.toJson();
    }
    if (schedule != null) {
      map['schedule '] = schedule?.toJson();
    }
    map['duration_type'] = durationType;
    map['created_at'] = createdAt;
    map['booking_status'] = bookingStatus;
    map['id'] = id;
    map['created_by'] = createdBy;
    map['host_user_uid'] = hostUserUid;
    if (priceDetaill != null) {
      map['price_detaill'] = priceDetaill?.toJson();
    }
    return map;
  }
}

class PriceDetaill {
  PriceDetaill({
    this.totalPrice,
    this.serviceFee,
    this.subTotal,
    this.taxes,
    this.tip,
  });

  PriceDetaill.fromJson(dynamic json) {
    totalPrice = json['total_price'];
    serviceFee = json['service_fee'];
    subTotal = json['sub_total'];
    taxes = json['taxes'];
    tip = json['tip'];
  }
  double? totalPrice;
  double? serviceFee;
  double? subTotal;
  double? taxes;
  double? tip;
  PriceDetaill copyWith({
    double? totalPrice,
    double? serviceFee,
    double? subTotal,
    double? taxes,
    double? tip,
  }) =>
      PriceDetaill(
        totalPrice: totalPrice ?? this.totalPrice,
        serviceFee: serviceFee ?? this.serviceFee,
        subTotal: subTotal ?? this.subTotal,
        taxes: taxes ?? this.taxes,
        tip: tip ?? this.tip,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total_price'] = totalPrice;
    map['service_fee'] = serviceFee;
    map['sub_total'] = subTotal;
    map['taxes'] = taxes;
    map['tip'] = tip;
    return map;
  }
}

class BookingScheduleModel {
  BookingScheduleModel({
    this.startTime,
    this.endTime,
    this.dates,
  });

  BookingScheduleModel.fromJson(dynamic json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    dates = json['dates'] != null ? json['dates'].cast<Timestamp>() : [];
  }
  String? startTime;
  String? endTime;
  List<Timestamp>? dates;
  BookingScheduleModel copyWith({
    String? startTime,
    String? endTime,
    List<Timestamp>? dates,
  }) =>
      BookingScheduleModel(
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        dates: dates ?? this.dates,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['dates'] = dates;
    return map;
  }
}

class PaymentDetail {
  PaymentDetail(
      {this.paymentType,
        this.payInType,
        this.paymentStatus,
        this.remainingAmount,
        this.isSplit,
        this.paidAmount,
        this.payWithWallet = 0.0,
        this.splitPayment,
        this.paymentIntents,
        this.paymentMethod,
        this.cryptoScreenShot,
        this.currentUserCardNum,
        this.cryptoReceiverEmail});

  PaymentDetail.fromJson(dynamic json) {
    paymentType = json['payment_type'];
    payWithWallet = json['pay_with_wallet'];
    payInType = json['pay_in_type'];
    paymentStatus = json['payment_status'];
    remainingAmount = json['remaining_amount'];
    isSplit = json['is_split'];
    paidAmount = json['paid_amount'];
    if (json['split_payment'] != null) {
      splitPayment = [];
      json['split_payment'].forEach((v) {
        splitPayment?.add(SplitPaymentModel.fromJson(v));
      });
    }
    if (json['payment_intents'] != null) {
      paymentIntents = [];
      json['payment_intents'].forEach((v) {
        paymentIntents?.add(PaymentIntents.fromJson(v));
      });
    }
    paymentMethod = json['payment_method'];
    currentUserCardNum = json['current_user_card_num'];
    cryptoReceiverEmail = json['crypto_receiver_email'];
    cryptoScreenShot = json['crypto_screenshot'];
  }
  int? paymentType;
  int? payInType;
  int? paymentStatus;
  var remainingAmount;
  var payWithWallet;
  bool? isSplit;
  var paidAmount;
  List<SplitPaymentModel>? splitPayment;
  List<PaymentIntents>? paymentIntents;
  int? paymentMethod;
  String? currentUserCardNum;
  String? cryptoScreenShot;
  String? cryptoReceiverEmail;
  PaymentDetail copyWith({
    int? paymentType,
    int? payInType,
    int? paymentStatus,
    double? remainingAmount,
    bool? isSplit,
    double? paidAmount,
    double? payWithWallet,
    List<SplitPaymentModel>? splitPayment,
    List<PaymentIntents>? paymentIntents,
    int? paymentMethod,
    String? currentUserCardNum,
    String? cryptoScreenShot,
    String? cryptoReceiverEmail,
  }) =>
      PaymentDetail(
        paymentType: paymentType ?? this.paymentType,
        payInType: payInType ?? this.payInType,
        payWithWallet: payWithWallet ?? this.payWithWallet,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        isSplit: isSplit ?? this.isSplit,
        paidAmount: paidAmount ?? this.paidAmount,
        splitPayment: splitPayment ?? this.splitPayment,
        paymentIntents: paymentIntents ?? this.paymentIntents,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        currentUserCardNum: currentUserCardNum ?? this.currentUserCardNum,
        cryptoReceiverEmail: cryptoReceiverEmail ?? this.cryptoReceiverEmail,
        cryptoScreenShot: cryptoScreenShot ?? this.cryptoScreenShot,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['payment_type'] = paymentType;
    map['pay_with_wallet'] = payWithWallet;
    map['pay_in_type'] = payInType;
    map['payment_status'] = paymentStatus;
    map['remaining_amount'] = remainingAmount;
    map['is_split'] = isSplit;
    map['paid_amount'] = paidAmount;
    if (splitPayment != null) {
      map['split_payment'] = splitPayment?.map((v) => v.toJson()).toList();
    }
    if (paymentIntents != null) {
      map['payment_intents'] = paymentIntents?.map((v) => v.toJson()).toList();
    }
    map['payment_method'] = paymentMethod;
    map['current_user_card_num'] = currentUserCardNum;
    map['crypto_receiver_email'] = cryptoReceiverEmail;
    map['crypto_screenshot'] = cryptoScreenShot;

    return map;
  }
}

class SplitPaymentModel {
  SplitPaymentModel(
      {this.remainingDeposit,
        this.paymentType,
        this.amount,
        this.percentage,
        this.remainingAmount,
        this.paymentStatus,
        this.depositStatus,
        this.payWithWallet = 0.0,
        this.userUid,
        this.paymentMethod,
        this.cryptoScreenShot,
        this.currentUserCardNum,
        this.cryptoReceiverEmail});

  SplitPaymentModel.fromJson(dynamic json) {
    remainingDeposit = json['remaining_deposit'];
    paymentType = json['payment_type'];
    amount = json['amount'];
    percentage = json['percentage'];
    remainingAmount = json['remaining_amount'];
    paymentStatus = json['payment_status'];
    depositStatus = json['deposit_status'];
    userUid = json['user_uid'];
    payWithWallet = json['pay_with_wallet'];
    paymentMethod = json['payment_method'];
    currentUserCardNum = json['current_user_card_num'];
    cryptoReceiverEmail = json['crypto_receiver_email'];
    cryptoScreenShot = json['crypto_screenshot'];
  }
  var remainingDeposit;
  int? paymentType;
  var amount;
  String? percentage;
  var remainingAmount;
  var payWithWallet;
  int? paymentStatus;
  int? depositStatus;
  String? userUid;
  int? paymentMethod;
  String? currentUserCardNum;
  String? cryptoScreenShot;
  String? cryptoReceiverEmail;
  SplitPaymentModel copyWith({
    int? remainingDeposit,
    int? paymentType,
    double? amount,
    double? payWithWallet,
    String? percentage,
    int? remainingAmount,
    int? paymentStatus,
    int? depositStatus,
    String? userUid,
    int? paymentMethod,
    String? currentUserCardNum,
    String? cryptoScreenShot,
    String? cryptoReceiverEmail,
  }) =>
      SplitPaymentModel(
        remainingDeposit: remainingDeposit ?? this.remainingDeposit,
        paymentType: paymentType ?? this.paymentType,
        amount: amount ?? this.amount,
        payWithWallet: payWithWallet ?? this.payWithWallet,
        percentage: percentage ?? this.percentage,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        depositStatus: depositStatus ?? this.depositStatus,
        userUid: userUid ?? this.userUid,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        currentUserCardNum: currentUserCardNum ?? this.currentUserCardNum,
        cryptoReceiverEmail: cryptoReceiverEmail ?? this.cryptoReceiverEmail,
        cryptoScreenShot: cryptoScreenShot ?? this.cryptoScreenShot,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['remaining_deposit'] = remainingDeposit;
    map['pay_with_wallet'] = payWithWallet;
    map['payment_type'] = paymentType;
    map['amount'] = amount;
    map['percentage'] = percentage;
    map['remaining_amount'] = remainingAmount;
    map['payment_status'] = paymentStatus;
    map['deposit_status'] = depositStatus;
    map['user_uid'] = userUid;
    map['payment_method'] = paymentMethod;
    map['current_user_card_num'] = currentUserCardNum;
    map['crypto_receiver_email'] = cryptoReceiverEmail;
    map['crypto_screenshot'] = cryptoScreenShot;
    return map;
  }
}

class CharterFleetDetail {
  CharterFleetDetail({
    this.image,
    this.name,
    this.location,
    this.id,
  });

  CharterFleetDetail.fromJson(dynamic json) {
    image = json['image'];
    name = json['name'];
    location = json['location'];
    id = json['id'];
  }
  String? image;
  String? name;
  String? location;
  String? id;
  CharterFleetDetail copyWith({
    String? image,
    String? name,
    String? location,
    String? id,
  }) =>
      CharterFleetDetail(
        image: image ?? this.image,
        name: name ?? this.name,
        location: location ?? this.location,
        id: id ?? this.id,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['image'] = image;
    map['name'] = name;
    map['location'] = location;
    map['id'] = id;
    return map;
  }
}

class PaymentIntents {
  PaymentIntents({
    this.paymentIntentId,
    this.userId,
    this.paymentStatus,
  });

  PaymentIntents.fromJson(dynamic json) {
    paymentIntentId = json['payment_intent_id'];
    userId = json['user_id'];
    paymentStatus = PaymentIntentsStatus.values[json['payment_status']];
  }
  String? paymentIntentId;
  String? userId;
  PaymentIntentsStatus? paymentStatus;
  PaymentIntents copyWith({
    String? paymentIntentId,
    String? userId,
    PaymentIntentsStatus? paymentStatus,
  }) =>
      PaymentIntents(
        paymentIntentId: paymentIntentId ?? this.paymentIntentId,
        userId: userId ?? this.userId,
        paymentStatus: paymentStatus ?? this.paymentStatus,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['payment_intent_id'] = paymentIntentId;
    map['user_id'] = userId;
    map['payment_status'] = paymentStatus?.index;
    return map;
  }
}

