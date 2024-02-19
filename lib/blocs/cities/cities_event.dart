part of 'cities_bloc.dart';

abstract class CitiesEvent extends Equatable {
  const CitiesEvent();
}
class AddCity extends CitiesEvent{
  final String city;

  const AddCity(this.city);

  @override
  // TODO: implement props
  List<Object?> get props => [city];
}
class UpdateCity extends CitiesEvent{
  final String city;
  final int swapToIndex;
  const UpdateCity(this.city,this.swapToIndex);

  @override
  // TODO: implement props
  List<Object?> get props => [city];
}
class SwapCity extends CitiesEvent{
  final String city;
  final int swapToIndex;
  const SwapCity(this.city,this.swapToIndex);

  @override
  // TODO: implement props
  List<Object?> get props => [city];
}
class InsertCity extends CitiesEvent{
  final String city;
  final int swapToIndex;
  const InsertCity(this.city,this.swapToIndex);

  @override
  // TODO: implement props
  List<Object?> get props => [city];
}
