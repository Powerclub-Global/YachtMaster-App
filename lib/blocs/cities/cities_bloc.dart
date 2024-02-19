
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'cities_event.dart';
part 'cities_state.dart';

class CitiesBloc extends HydratedBloc<CitiesEvent, CitiesState> {
  CitiesBloc() : super(CitiesState()) {
    on<AddCity>(_onAddCity);
    on<SwapCity>(_onSwapCity);
    on<UpdateCity>(_onUpdateCity);
    on<InsertCity>(_onInsertCity);
  }
  void _onAddCity(AddCity event,Emitter<CitiesState> emit)
  {
    final state=this.state;
    emit(CitiesState(recentCities: List.from(state.recentCities)..add(event.city)));
  }
  void _onSwapCity(SwapCity event,Emitter<CitiesState> emit)
  {
    final state=this.state;
    String tempCity = state.recentCities[0];
    state.recentCities[0] =
    state.recentCities[event.swapToIndex];
    state.recentCities[event.swapToIndex] = tempCity;
    emit(CitiesState(recentCities:state.recentCities));
  }
  void _onUpdateCity(UpdateCity event,Emitter<CitiesState> emit)
  {
    final state=this.state;
    state.recentCities[event.swapToIndex] = event.city;
    emit(CitiesState(recentCities:state.recentCities));
  }
  void _onInsertCity(InsertCity event,Emitter<CitiesState> emit)
  {
    final state=this.state;
    List<String> tempCities=[];
    tempCities.add(event.city);
    state.recentCities.forEach((element) {
      tempCities.add(element);
    });
    emit(CitiesState(recentCities:tempCities));
  }

  @override
  CitiesState? fromJson(Map<String, dynamic> json) {
    return CitiesState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(CitiesState state) {
   return state.toMap();
  }

}
