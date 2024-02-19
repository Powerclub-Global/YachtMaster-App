class StripeCardModel {
  StripeCardModel({
      this.object, 
      this.data, 
      this.hasMore, 
      this.url,});

  StripeCardModel.fromJson(dynamic json) {
    object = json['object'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
    hasMore = json['has_more'];
    url = json['url'];
  }
  String? object;
  List<Data>? data;
  bool? hasMore;
  String? url;
StripeCardModel copyWith({  String? object,
  List<Data>? data,
  bool? hasMore,
  String? url,
}) => StripeCardModel(  object: object ?? this.object,
  data: data ?? this.data,
  hasMore: hasMore ?? this.hasMore,
  url: url ?? this.url,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['object'] = object;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['has_more'] = hasMore;
    map['url'] = url;
    return map;
  }

}

class Data {
  Data({
      this.id, 
      this.object, 
      this.addressCity, 
      this.addressCountry, 
      this.addressLine1, 
      this.addressLine1Check, 
      this.addressLine2, 
      this.addressState, 
      this.addressZip, 
      this.addressZipCheck, 
      this.brand, 
      this.country, 
      this.customer, 
      this.cvcCheck, 
      this.dynamicLast4, 
      this.expMonth, 
      this.expYear, 
      this.fingerprint, 
      this.funding, 
      this.last4, 
      this.metadata, 
      this.name, 
      this.tokenizationMethod, 
      this.wallet,});

  Data.fromJson(dynamic json) {
    id = json['id'];
    object = json['object'];
    addressCity = json['address_city'];
    addressCountry = json['address_country'];
    addressLine1 = json['address_line1'];
    addressLine1Check = json['address_line1_check'];
    addressLine2 = json['address_line2'];
    addressState = json['address_state'];
    addressZip = json['address_zip'];
    addressZipCheck = json['address_zip_check'];
    brand = json['brand'];
    country = json['country'];
    customer = json['customer'];
    cvcCheck = json['cvc_check'];
    dynamicLast4 = json['dynamic_last4'];
    expMonth = json['exp_month'];
    expYear = json['exp_year'];
    fingerprint = json['fingerprint'];
    funding = json['funding'];
    last4 = json['last4'];
    metadata = json['metadata'];
    name = json['name'];
    tokenizationMethod = json['tokenization_method'];
    wallet = json['wallet'];
  }
  String? id;
  String? object;
  dynamic addressCity;
  dynamic addressCountry;
  dynamic addressLine1;
  dynamic addressLine1Check;
  dynamic addressLine2;
  dynamic addressState;
  dynamic addressZip;
  dynamic addressZipCheck;
  String? brand;
  String? country;
  String? customer;
  dynamic cvcCheck;
  dynamic dynamicLast4;
  num? expMonth;
  num? expYear;
  String? fingerprint;
  String? funding;
  String? last4;
  dynamic metadata;
  dynamic name;
  dynamic tokenizationMethod;
  dynamic wallet;
Data copyWith({  String? id,
  String? object,
  dynamic addressCity,
  dynamic addressCountry,
  dynamic addressLine1,
  dynamic addressLine1Check,
  dynamic addressLine2,
  dynamic addressState,
  dynamic addressZip,
  dynamic addressZipCheck,
  String? brand,
  String? country,
  String? customer,
  dynamic cvcCheck,
  dynamic dynamicLast4,
  num? expMonth,
  num? expYear,
  String? fingerprint,
  String? funding,
  String? last4,
  dynamic metadata,
  dynamic name,
  dynamic tokenizationMethod,
  dynamic wallet,
}) => Data(  id: id ?? this.id,
  object: object ?? this.object,
  addressCity: addressCity ?? this.addressCity,
  addressCountry: addressCountry ?? this.addressCountry,
  addressLine1: addressLine1 ?? this.addressLine1,
  addressLine1Check: addressLine1Check ?? this.addressLine1Check,
  addressLine2: addressLine2 ?? this.addressLine2,
  addressState: addressState ?? this.addressState,
  addressZip: addressZip ?? this.addressZip,
  addressZipCheck: addressZipCheck ?? this.addressZipCheck,
  brand: brand ?? this.brand,
  country: country ?? this.country,
  customer: customer ?? this.customer,
  cvcCheck: cvcCheck ?? this.cvcCheck,
  dynamicLast4: dynamicLast4 ?? this.dynamicLast4,
  expMonth: expMonth ?? this.expMonth,
  expYear: expYear ?? this.expYear,
  fingerprint: fingerprint ?? this.fingerprint,
  funding: funding ?? this.funding,
  last4: last4 ?? this.last4,
  metadata: metadata ?? this.metadata,
  name: name ?? this.name,
  tokenizationMethod: tokenizationMethod ?? this.tokenizationMethod,
  wallet: wallet ?? this.wallet,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['object'] = object;
    map['address_city'] = addressCity;
    map['address_country'] = addressCountry;
    map['address_line1'] = addressLine1;
    map['address_line1_check'] = addressLine1Check;
    map['address_line2'] = addressLine2;
    map['address_state'] = addressState;
    map['address_zip'] = addressZip;
    map['address_zip_check'] = addressZipCheck;
    map['brand'] = brand;
    map['country'] = country;
    map['customer'] = customer;
    map['cvc_check'] = cvcCheck;
    map['dynamic_last4'] = dynamicLast4;
    map['exp_month'] = expMonth;
    map['exp_year'] = expYear;
    map['fingerprint'] = fingerprint;
    map['funding'] = funding;
    map['last4'] = last4;
    map['metadata'] = metadata;
    map['name'] = name;
    map['tokenization_method'] = tokenizationMethod;
    map['wallet'] = wallet;
    return map;
  }

}