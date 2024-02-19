/// uid : ""
/// amount : ""

class WalletModel {
  WalletModel({
      this.uid, 
      this.amount,});

  WalletModel.fromJson(dynamic json) {
    uid = json['uid'];
    amount = json['amount'];
  }
  String? uid;
  var amount;
WalletModel copyWith({  String? uid,
  var amount,
}) => WalletModel(  uid: uid ?? this.uid,
  amount: amount ?? this.amount,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = uid;
    map['amount'] = amount;
    return map;
  }

}