
/// service_fee : 135
/// taxes : 315
/// tip : 450

class TaxesModel {
  TaxesModel({
    this.serviceFee,
    this.taxes,this.referralAmount,
    this.tip,});

  TaxesModel.fromJson(dynamic json) {
    serviceFee = json['service_fee'];
    taxes = json['taxes'];
    tip = json['tip'];
    referralAmount = json['referral_amount'];
  }
  int? serviceFee;
  int? taxes;
  int? tip;
  var referralAmount;
  TaxesModel copyWith({  int? serviceFee,
    int? taxes,
    int? tip,
    var referralAmount,
  }) => TaxesModel(  serviceFee: serviceFee ?? this.serviceFee,
    taxes: taxes ?? this.taxes,
    tip: tip ?? this.tip,
    referralAmount: referralAmount ?? this.referralAmount,
  );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['service_fee'] = serviceFee;
    map['referral_amount'] = referralAmount;
    map['taxes'] = taxes;
    map['tip'] = tip;
    return map;
  }

}