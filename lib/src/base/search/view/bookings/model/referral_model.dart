/// invited_user_email : ""
/// date : ""
/// uid : ""
/// amount : ""
/// invited_user_uid : ""

class ReferralModel {
  ReferralModel({
      this.invitedUserEmail, 
      this.date, 
      this.uid, 
      this.amount, 
      this.invitedUserUid,});

  ReferralModel.fromJson(dynamic json) {
    invitedUserEmail = json['invited_user_email'];
    date = json['date'];
    uid = json['uid'];
    amount = json['amount'];
    invitedUserUid = json['invited_user_uid'];
  }
  String? invitedUserEmail;
  String? date;
  String? uid;
  String? amount;
  String? invitedUserUid;
ReferralModel copyWith({  String? invitedUserEmail,
  String? date,
  String? uid,
  String? amount,
  String? invitedUserUid,
}) => ReferralModel(  invitedUserEmail: invitedUserEmail ?? this.invitedUserEmail,
  date: date ?? this.date,
  uid: uid ?? this.uid,
  amount: amount ?? this.amount,
  invitedUserUid: invitedUserUid ?? this.invitedUserUid,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['invited_user_email'] = invitedUserEmail;
    map['date'] = date;
    map['uid'] = uid;
    map['amount'] = amount;
    map['invited_user_uid'] = invitedUserUid;
    return map;
  }

}