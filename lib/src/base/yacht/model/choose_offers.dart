/// icon : "https://firebasestorage.googleapis.com/v0/b/yacht-masters.appspot.com/o/s1.png?alt=media&token=75e3fbad-48ca-417b-aa3e-506c8d5dcf52"
/// title : "Jet Skies"

class ChooseOffers {
  ChooseOffers({
      this.icon, 
      this.title,this.id,this.status
  });

  ChooseOffers.fromJson(dynamic json) {
    icon = json['icon'];
    title = json['title'];
    id = json['id'];
    status = json['status'];
  }
  String? icon;
  String? title;
  String? id;
  bool? status;
ChooseOffers copyWith({  String? icon,String? id,
  String? title,
  bool? status,
}) => ChooseOffers(  icon: icon ?? this.icon,
  title: title ?? this.title,
  id: id ?? this.id,
  status: status ?? this.status,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['icon'] = icon;
    map['title'] = title;
    map['id'] = id;
    map['status'] = status??true;
    return map;
  }

}