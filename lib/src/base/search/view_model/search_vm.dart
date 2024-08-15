import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import '../../../../services/time_schedule_service.dart';
import '../view/bookings/model/bookings.dart';
import '../view/bookings/model/time_slot_model.dart';
import '../view/bookings/view_model/bookings_vm.dart';
import '../../../../utils/helper.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../constant/enums.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../model/charter_model.dart';
import '../model/charters_day_model.dart';
import '../model/city_model.dart';

class SearchVm extends ChangeNotifier {
  ///HOLIDAY
  Set<DateTime>? selectedBookingDays;
  Set<DateTime>? charterAvailableDates;

  Set<DateTime>? availabilityDays;
  List<String> halfDayTimeList=[
    "07:00 - 10:00",
    "10:00 - 02:00",
    "03:00 - 07:00",
    "08:00 - 12:00",
  ];
  List<String> fullDayTimeList=["10:00 - 02:00",
    "03:00 - 07:00",];
  DateTime? start;
  DateTime? end;
  List<DateTime> holidayFormat = [];
  TimeSlotModel? selectedBookingTime;
  // String selectedTrip = "";
  CharterDayModel? selectedCharterDayType;
  String? selectedCity;
  String searchText = "";

  int adultsCount = 0;
  int childrenCount = 0;
  int infantsCount = 0;
  int petsCount = 0;
  DateTime? pickedDate;
  DateTime? startDate;
  DateTime? endDate;

  List<CityModel> cities = [
    CityModel("Lahore", R.images.v1, "MIAMI BEACH"),
    CityModel("Karachi", R.images.v2, "SHOAL BAY"),
    CityModel("Islamabad", R.images.v3, "CALA SOANA"),
    CityModel("Multan", R.images.v1, "GLASS BEACH"),
    CityModel("Sialkot", R.images.v2, "STARFISH BEACH"),
    CityModel("Gujranwala", R.images.v3, "FAKISTRA BEACH"),
  ];
  List<String> recentSearchCities = [
    // CityModel("Lahore", R.images.v1, "MIAMI BEACH"),
    // CityModel("Karachi", R.images.v2, "SHOAL BAY"),
    // CityModel("Islamabad", R.images.v3, "CALA SOANA"),
  ];
  List<CharterDayModel> charterDayList = [
    CharterDayModel("Half Day Charter", "4 Hours", R.images.v2,CharterDayType.halfDay.index),
    CharterDayModel("Full Day Charter", "8 Hours", R.images.v3,CharterDayType.fullDay.index),
    CharterDayModel("24 Hours", "Stays and Expeditions", R.images.v1,CharterDayType.multiDay.index),
  ];

  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Helper.mapApiKey);
  Set<Marker> marker = new Set();
  LatLng? newLocationLatLng;
  String? city="";
  void onError(PlacesAutocompleteResponse response) {
    debugPrint("\nMap Error = " + response.errorMessage! + "\n\n\n");
  }
  getCharterFromBooking(charterModel)
  async {
    var bookingsVm=Provider.of<BookingsVm>(Get.context!,listen: false);
    bookingsVm.bookingsModel.charterFleetDetail=CharterFleetDetail(id: charterModel.id,location: charterModel.location?.adress,
        name: charterModel.name,image: charterModel.images?.first);
    DocumentSnapshot charterDoc=await FbCollections.charterFleet.doc(bookingsVm.bookingsModel.charterFleetDetail?.id).get();
    CharterModel charter=CharterModel.fromJson(charterDoc.data());
    return charter;
  }
  getCity(LatLng latLng, String searchAddress,TextEditingController searchController,) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    var first = placemarks.first;
    String address;
    newLocationLatLng = latLng;

    debugPrint(first.subLocality);

    if (searchAddress.isEmpty) {
      searchController.text =
      "${(first.subLocality)!.isEmpty ? first.name : ''} ${first.subLocality},${first.locality}";
      address = "${first.subLocality},${first.locality}";
      city=first.locality??"";
    } else {
      searchController.text = searchAddress;
      address = searchAddress;
      city=first.locality??"";
    }

    log("_______________CITYYYYY${city}");

    log("\ncomplete Address: $address");
   update();
  }

  Future<Prediction> displayPrediction(
      Prediction p,GoogleMapController? googleController,TextEditingController searchController,) async {
      marker.clear();

    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;
      newLocationLatLng=LatLng(lat, lng);
      log("______________NEW LOCATION LAT:${newLocationLatLng}");
      print('place:${p.description}');
      googleController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: 4.0,
          ),
        ),
      );
      marker.add(Marker(
        markerId: MarkerId("id"),
        position: LatLng(lat, lng),
      ));

      await getCity(LatLng(lat, lng), p.description!,searchController);

    }

    return p;
  }
   search(TextEditingController searchController,GoogleMapController googleController) async {
    Prediction? p = await PlacesAutocomplete.show(
      context: Get.context!,
      apiKey: Helper.mapApiKey,
      onError: onError,
      mode: Mode.overlay,
      language: "en",
      types: [],
      strictbounds: false,
      components: [],
    );
    log("this is prediction value : $p");
    p = await displayPrediction(
      p!,googleController,searchController
    );

    log(searchController.text);

  }

   pickDate(
    bool isStart,
    DateTime initialDate,
    DateTime firstDate,
    DateTime lastDate,
    BuildContext context,
    TextEditingController startController,
    TextEditingController endController,
  ) async {
    pickedDate=DateTime.now();
    final DateTime? picked = await showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
            data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.fromSwatch(
                    primarySwatch:
                    Helper.createMaterialColor(R.colors.themeMud))),
            child: child!);
      },
      context: context,
      initialDate: initialDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: firstDate,
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      pickedDate = picked;
      if (isStart) {
        startDate=pickedDate;
        startController.text = DateFormat("EEE, MMM dd yyyy").format(pickedDate??now);
      } else {
        endDate=pickedDate;
        endController.text = DateFormat("EEE, MMM dd yyyy").format(pickedDate??now);
      }
    }
    notifyListeners();
  }
  update() {
    notifyListeners();
  }
}
