/// referral_link : "yachtmaster.com/mikegaller/"
/// facebook_url : ""
/// website_url : ""
/// instagram_url : ""
/// twitter_url : ""
/// google_url : ""
/// admin_crypto_email : "bodhi@labworld.org"

class AppUrlModel {
  AppUrlModel({
    this.referralLink,
    this.facebookUrl,
    this.websiteUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.googleUrl,
    this.support,
    this.superhostminimumbookings,
    this.hostPolicies,
    this.adminCryptoEmail,
    this.is_enable_permission_dialog,
    this.is_enable_social_login,
    this.adminUsdtEmail,
  });

  AppUrlModel.fromJson(dynamic json) {
    referralLink = json['referral_link'];
    support = json['support'];
    facebookUrl = json['facebook_url'];
    websiteUrl = json['website_url'];
    instagramUrl = json['instagram_url'];
    twitterUrl = json['twitter_url'];
    googleUrl = json['google_url'];
    adminCryptoEmail = json['admin_crypto_email'];
    superhostminimumbookings = json['superhost_minimum_bookings'];
    hostPolicies = json['host_policies'];
    is_enable_permission_dialog = json['is_enable_permission_dialog'];
    is_enable_social_login = json['is_enable_social_login'];
    adminUsdtEmail = json['admin_usdt_email'];
  }
  String? referralLink;
  String? facebookUrl;
  String? websiteUrl;
  String? instagramUrl;
  String? twitterUrl;
  String? googleUrl;
  String? adminCryptoEmail;
  String? adminUsdtEmail;
  String? support;
  String? hostPolicies;
  int? superhostminimumbookings;
  bool? is_enable_permission_dialog;
  bool? is_enable_social_login;
  AppUrlModel copyWith({
    String? referralLink,
    String? facebookUrl,
    int? superhostminimumbookings,
    String? websiteUrl,
    bool? is_enable_permission_dialog,
    bool? is_enable_social_login,
    String? hostPolicies,
    String? support,
    String? instagramUrl,
    String? twitterUrl,
    String? googleUrl,
    String? adminCryptoEmail,
    String? adminUsdtEmail,
  }) =>
      AppUrlModel(
        referralLink: referralLink ?? this.referralLink,
        support: support ?? this.support,
        facebookUrl: facebookUrl ?? this.facebookUrl,
        is_enable_permission_dialog:
            is_enable_permission_dialog ?? this.is_enable_permission_dialog,
        is_enable_social_login:
            is_enable_social_login ?? this.is_enable_social_login,
        superhostminimumbookings:
            superhostminimumbookings ?? this.superhostminimumbookings,
        websiteUrl: websiteUrl ?? this.websiteUrl,
        instagramUrl: instagramUrl ?? this.instagramUrl,
        twitterUrl: twitterUrl ?? this.twitterUrl,
        googleUrl: googleUrl ?? this.googleUrl,
        adminCryptoEmail: adminCryptoEmail ?? this.adminCryptoEmail,
        hostPolicies: hostPolicies ?? this.hostPolicies,
        adminUsdtEmail: adminUsdtEmail ?? this.adminUsdtEmail,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['referral_link'] = referralLink;
    map['is_enable_permission_dialog'] = is_enable_permission_dialog;
    map['is_enable_social_login'] = is_enable_social_login;
    map['support'] = support;
    map['superhost_minimum_bookings'] = superhostminimumbookings;
    map['facebook_url'] = facebookUrl;
    map['website_url'] = websiteUrl;
    map['instagram_url'] = instagramUrl;
    map['twitter_url'] = twitterUrl;
    map['google_url'] = googleUrl;
    map['admin_crypto_email'] = adminCryptoEmail;
    map['host_policies'] = hostPolicies;
    map['admin_usdt_email'] = adminUsdtEmail;
    return map;
  }
}
