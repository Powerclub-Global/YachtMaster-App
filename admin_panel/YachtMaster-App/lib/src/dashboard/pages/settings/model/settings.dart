class AppData {
  AppData({
      this.phoneNumber, 
      this.privacyPolicy, 
      this.termsOfUse, 
      this.googleUrl, 
      this.website, 
      this.appVersion, 
      this.instaUrl, 
      this.email, 
      this.facebookUrl, 
      this.twitterUrl, 
      this.aboutApplication, 
      this.address,});

  AppData.fromJson(dynamic json) {
    phoneNumber = json['phone_number'];
    privacyPolicy = json['privacy_policy'];
    termsOfUse = json['terms_of_use'];
    googleUrl = json['google_url'];
    website = json['website'];
    appVersion = json['app_version'];
    instaUrl = json['insta_url'];
    email = json['email'];
    facebookUrl = json['facebook_url'];
    twitterUrl = json['twitter_url'];
    if (json['about_application'] != null) {
      aboutApplication = [];
      json['about_application'].forEach((v) {
        aboutApplication?.add(AboutApplication.fromJson(v));
      });
    }
    address = json['address'];
  }
  String? phoneNumber;
  String? privacyPolicy;
  String? termsOfUse;
  String? googleUrl;
  String? website;
  String? appVersion;
  String? instaUrl;
  String? email;
  String? facebookUrl;
  String? twitterUrl;
  List<AboutApplication>? aboutApplication;
  String? address;
AppData copyWith({  String? phoneNumber,
  String? privacyPolicy,
  String? termsOfUse,
  String? googleUrl,
  String? website,
  String? appVersion,
  String? instaUrl,
  String? email,
  String? facebookUrl,
  String? twitterUrl,
  List<AboutApplication>? aboutApplication,
  String? address,
}) => AppData(  phoneNumber: phoneNumber ?? this.phoneNumber,
  privacyPolicy: privacyPolicy ?? this.privacyPolicy,
  termsOfUse: termsOfUse ?? this.termsOfUse,
  googleUrl: googleUrl ?? this.googleUrl,
  website: website ?? this.website,
  appVersion: appVersion ?? this.appVersion,
  instaUrl: instaUrl ?? this.instaUrl,
  email: email ?? this.email,
  facebookUrl: facebookUrl ?? this.facebookUrl,
  twitterUrl: twitterUrl ?? this.twitterUrl,
  aboutApplication: aboutApplication ?? this.aboutApplication,
  address: address ?? this.address,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phone_number'] = phoneNumber;
    map['privacy_policy'] = privacyPolicy;
    map['terms_of_use'] = termsOfUse;
    map['google_url'] = googleUrl;
    map['website'] = website;
    map['app_version'] = appVersion;
    map['insta_url'] = instaUrl;
    map['email'] = email;
    map['facebook_url'] = facebookUrl;
    map['twitter_url'] = twitterUrl;
    if (aboutApplication != null) {
      map['about_application'] = aboutApplication?.map((v) => v.toJson()).toList();
    }
    map['address'] = address;
    return map;
  }

}

class AboutApplication {
  AboutApplication({
      this.description, 
      this.title,});

  AboutApplication.fromJson(dynamic json) {
    description = json['description'];
    title = json['title'];
  }
  String? description;
  String? title;
AboutApplication copyWith({  String? description,
  String? title,
}) => AboutApplication(  description: description ?? this.description,
  title: title ?? this.title,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['description'] = description;
    map['title'] = title;
    return map;
  }

}