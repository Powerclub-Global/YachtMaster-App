// ignore_for_file: must_be_immutable

part of 'cities_bloc.dart';

 class CitiesState extends Equatable {
   List<String> recentCities;
   CitiesState({this.recentCities = const<String>[]});
 @override
 // TODO: implement props
 List<Object?> get props => [recentCities];

   factory CitiesState.fromMap(dynamic map) {

    return CitiesState(
      recentCities:map['recentCities'],
    );
  }

   Map<String, dynamic> toMap() {
    return {
      'recentCities': recentCities.map((map) => map).toList(),
    };
  }
}

