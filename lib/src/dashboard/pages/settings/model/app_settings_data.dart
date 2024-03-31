class PrivacyPolicyModel {
  PrivacyPolicyModel({
    this.privacyPolicy,
    this.termsOfUse,
  });

  PrivacyPolicyModel.fromJson(dynamic json) {
    privacyPolicy = json['privacy_policy'];
    termsOfUse = json['terms_of_use'];
  }
  String? privacyPolicy;
  String? termsOfUse;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['privacy_policy'] = privacyPolicy;
    map['terms_of_use'] = termsOfUse;
    return map;
  }
}
