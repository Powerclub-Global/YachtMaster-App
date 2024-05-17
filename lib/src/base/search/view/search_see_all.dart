import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:geocoding/geocoding.dart';
import 'package:async_foreach/async_foreach.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../appwrite.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../../../../services/time_schedule_service.dart';
import '../../../auth/model/favourite_model.dart';
import '../../home/home_vm/home_vm.dart';
import '../model/charter_model.dart';
import '../model/services_model.dart';
import 'bookings/view_model/bookings_vm.dart';
import '../view_model/search_vm.dart';
import '../widgets/charter_widget.dart';
import '../widgets/host_widget.dart';
import '../widgets/yacht_widget.dart';
import '../../yacht/model/yachts_model.dart';
import '../../yacht/view/charter_detail.dart';
import '../../yacht/view/service_detail.dart';
import '../../yacht/view/yacht_detail.dart';
import '../../yacht/view_model/yacht_vm.dart';
import '../../../../utils/data/result.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../utils/helper.dart';
import '../../../../utils/data/error.dart';
import '../../../../utils/mapstyle.dart';

import '../../../../utils/empty_screem.dart';

class SearchSeeAll extends StatefulWidget {
  static String route = '/searchSeeAll';
  const SearchSeeAll({Key? key}) : super(key: key);

  @override
  _SearchSeeAllState createState() => _SearchSeeAllState();
}

class _SearchSeeAllState extends State<SearchSeeAll> {
  TextEditingController searchCon = TextEditingController();
  GoogleMapController? mapController;

  double? lat = 25.7716239;
  double? lng = -80.1397398;
  String mapStyle = "";
  Set<Marker> marker = new Set();
  bool isReserve = false;
  int seeAllType = -1;
  int index = 0;
  String keyword = "location";
  Error? error;
  List<Result>? places;
  Position? _currentPosition;
  BitmapDescriptor? sourceIcon;
  List<CharterModel> filterCharters = [];
  var pro = Provider.of<SearchVm>(Get.context!, listen: false);
  var yachtVm = Provider.of<YachtVm>(Get.context!, listen: false);
  var mostOccurredCity = Map();
  List<String> priceFilterList = [
    "\$ 0 - \$ 2,500",
    "\$ 2,500 - \$ 5,000",
    "\$ 5,900 - Above"
  ];
  List<String> placeFilterList = [];
  bool isLoading = false;
  bool enablePriceDropDown = false;
  int? selectedPrice;
  int? selectedPlace;
  bool enablePlaceDropDown = false;
  final GlobalKey pricePopUpKey = GlobalKey();
  final GlobalKey placePopUpKey = GlobalKey();
  bool isMapView = false;
  startLoader() {
    setState(() {
      isLoading = true;
    });
  }

  stopLoader() {
    setState(() {
      isLoading = false;
    });
  }

  priceFilter(int priceIndex) async {
    marker.clear();
    setState(() {});
    int startPrice = getPriceFromString(priceFilterList[priceIndex], true);
    int lastPrice = getPriceFromString(priceFilterList[priceIndex], false);
    await yachtVm.allCharters.asyncForEach((element) async {
      if (lastPrice == -1) {
        if ((startPrice <= element.priceHalfDay!)) {
          await moveToLocation(
              LatLng(
                  element.location?.lat ?? 0.0, element.location?.long ?? 0.0),
              element);
        }
      } else {
        if ((startPrice <= element.priceHalfDay!) &&
            (element.priceHalfDay! <= lastPrice)) {
          await moveToLocation(
              LatLng(
                  element.location?.lat ?? 0.0, element.location?.long ?? 0.0),
              element);
        }
      }
    });
  }

  List<CharterModel> priceFilterListView(int priceIndex) {
    List<CharterModel> tempCharters = [];
    int startPrice = getPriceFromString(priceFilterList[priceIndex], true);
    int lastPrice = getPriceFromString(priceFilterList[priceIndex], false);
    yachtVm.allCharters.forEach((element) {
      if (lastPrice == -1) {
        if ((startPrice <= (element.priceHalfDay ?? 0))) {
          tempCharters.add(element);
        }
      } else {
        if ((startPrice <= (element.priceHalfDay ?? 0)) &&
            ((element.priceHalfDay ?? 0) <= lastPrice)) {
          tempCharters.add(element);
        }
      }
    });
    log("___LEN:${tempCharters.length}");
    return tempCharters;
  }

  placeFilter(int placeIndex) async {
    marker.clear();
    setState(() {});
    log("______________Selected index:${placeIndex}_____${placeFilterList[placeIndex]}");
    await yachtVm.allCharters.asyncForEach((element) async {
      if (element.location.city == placeFilterList[placeIndex]) {
        await moveToLocation(
            LatLng(element.location?.lat ?? 0.0, element.location?.long ?? 0.0),
            element);
        log("________________MARKERS LEN:${marker.length}");
      }
    });
  }

  List<CharterModel> placeFilterListView(int placeIndex) {
    List<CharterModel> tempCharters = [];
    yachtVm.allCharters.forEach((element) {
      if (element.location?.city == placeFilterList[placeIndex]) {
        tempCharters.add(element);
      }
    });
    return tempCharters;
  }

  searchPlace(List<dynamic> list) async {
    marker.clear();
    var provider = Provider.of<SearchVm>(context, listen: false);
    await provider.search(searchCon, mapController!);
    log("_______________AFTER NEW LAT LNG:${provider.newLocationLatLng}___${provider.city}");
    list.forEach((element) async {
      if (seeAllType == SeeAllType.service.index) {
        log("______________lat:${element.location?.lat}____${element.location?.log}_____${element.name}");
        if (element.location?.lat?.toStringAsFixed(2) ==
                provider.newLocationLatLng?.latitude.toStringAsFixed(2) &&
            element.location?.log?.toStringAsFixed(2) ==
                provider.newLocationLatLng?.longitude.toStringAsFixed(2)) {
          log("_____________IF MATCH Lat:${provider.newLocationLatLng}");
          await moveToLocation(provider.newLocationLatLng!, element);
        }
      } else {
        if (element.location?.lat?.toStringAsFixed(2) ==
                provider.newLocationLatLng?.latitude.toStringAsFixed(2) &&
            element.location?.long?.toStringAsFixed(2) ==
                provider.newLocationLatLng?.longitude.toStringAsFixed(2)) {
          log("_____________IF MATCH Lat:${provider.newLocationLatLng}");
          await moveToLocation(provider.newLocationLatLng!, element);
        }
      }
    });
  }

  bool isFilter = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //loading map style JSON from asset file
    // moveToLocation(LatLng(lat ?? 25.7716239, lng ?? -80.1397398));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var provider = Provider.of<BookingsVm>(context, listen: false);
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      isReserve = args["isReserve"];
      index = args["index"];
      seeAllType = args["seeAllType"];
      marker.clear();
      mostOccurredCity.clear();
      if (isReserve) {
        isMapView = true;
        setState(() {});
      }
      setSourceAndDestinationIcons();
      await takePermissions();
      // await getCurrentLocation();
      placeFilterList = List.from(yachtVm.charterCities);
      if (seeAllType == SeeAllType.charter.index || seeAllType == -1) {
        await yachtVm.allCharters.asyncForEach((charterElement) async {
          // mostOccurredCity.clear();
          // String moveToCity=await getMostOccurredCity(yachtVm.allCharters);
          // log("_______________MOST OCCURRED CITY:${moveToCity}");
          // lat=  yachtVm.allCharters.where((element) => element.location?.city==moveToCity).first.location?.lat;
          // lng=  yachtVm.allCharters.where((element) => element.location?.city==moveToCity).first.location?.long;
          // log("___________LATLNG:${lat}____${lng}");

          if (seeAllType == -1) {
            List<Location> locations = await locationFromAddress(
                Provider.of<SearchVm>(context, listen: false).selectedCity ??
                    "");
            await moveToLocation(
                LatLng(locations.first.latitude, locations.first.longitude),
                charterElement);

            log("_______________${charterElement.location.city.toString().toLowerCase()}____${pro.selectedCity?.toLowerCase().removeAllWhitespace}___");
            if (charterElement.location.city
                        .toString()
                        .toLowerCase()
                        .removeAllWhitespace ==
                    pro.selectedCity?.toLowerCase().removeAllWhitespace &&
                (provider.bookingsModel.totalGuest ?? 0) <=
                    charterElement.guestCapacity) {
              log("__________________SEE ALL TYPE:${provider.bookingsModel.schedule?.startTime}___${provider.bookingsModel.schedule?.endTime}______${seeAllType}___${charterElement.location.city}___${pro.selectedCity}____${charterElement.name}");
              List<HalfDaySlots> halfDaySlots = [];
              List<FullDaySlots> fullDaySlots = [];
              charterElement?.availability?.halfDaySlots
                  ?.forEach((halfSlotEle) {
                String charterStart =
                    "${(int.parse(halfSlotEle.start.toString().split(":").first)).formatHour()}:${(int.parse(halfSlotEle.start.toString().split(":").last.split(" ").first)).formatMint()} ${halfSlotEle.start.toString().split(":").last.split(" ").last}";
                String charterEndTime =
                    "${(int.parse(halfSlotEle.end.toString().split(":").first)).formatHour()}:${(int.parse(halfSlotEle.end.toString().split(":").last.split(" ").first)).formatMint()} ${halfSlotEle.end.toString().split(":").last.split(" ").last}";
                halfDaySlots.add(
                    HalfDaySlots(start: charterStart, end: charterEndTime));
              });
              charterElement?.availability?.fullDaySlots
                  ?.forEach((fullDaySlot) {
                String charterStart =
                    "${(int.parse(fullDaySlot.start.toString().split(":").first)).formatHour()}:${(int.parse(fullDaySlot.start.toString().split(":").last.split(" ").first)).formatMint()} ${fullDaySlot.start.toString().split(":").last.split(" ").last}";
                String charterEndTime =
                    "${(int.parse(fullDaySlot.end.toString().split(":").first)).formatHour()}:${(int.parse(fullDaySlot.end.toString().split(":").last.split(" ").first)).formatMint()} ${fullDaySlot.end.toString().split(":").last.split(" ").last}";
                fullDaySlots.add(
                    FullDaySlots(start: charterStart, end: charterEndTime));
              });
              log("___________NEW HALF DAYS:${halfDaySlots.map((e) => e.start)}____${fullDaySlots.length}");
              if ((provider.bookingsModel.durationType ==
                          CharterDayType.multiDay.index &&
                      provider.isValidBetween(
                          charterElement?.availability?.startTime ?? "",
                          charterElement?.availability?.endTime ?? "",
                          provider.bookingsModel.schedule?.startTime ?? "")) ||
                  (provider.bookingsModel.durationType == CharterDayType.halfDay.index &&
                      halfDaySlots.any((element) =>
                              element.start ==
                                  provider.bookingsModel.schedule?.startTime &&
                              element.end ==
                                  provider.bookingsModel.schedule?.endTime) ==
                          true) ||
                  (provider.bookingsModel.durationType == CharterDayType.fullDay.index &&
                      fullDaySlots.any((element) =>
                              element.start ==
                                  provider.bookingsModel.schedule?.startTime &&
                              element.end ==
                                  provider.bookingsModel.schedule?.endTime) ==
                          true)) {
                log("_________________TIME IS VALIED");
                log("______________CHARTERS ID:${charterElement.id}");
                List<DateTime> bookedDates =
                    await getBookedDates(charterElement);
                List<DateTime> availableDates = [];
                setState(() {});
                if (bookedDates.length > 0) {
                  log("_______________BOOKED DATES LEN:${bookedDates.length}");
                  charterElement.availability.dates.forEach((date) {
                    log("________BOOKED:${bookedDates.first}____CHARTE DATE:${date.toDate()}");
                    if (!bookedDates.any((booked) => booked == date.toDate())) {
                      availableDates.add(date.toDate());
                    }
                  });
                } else {
                  availableDates = List.from(charterElement.availability.dates
                          .map((e) => e.toDate())
                          .toList() ??
                      []);
                }

                setState(() {});
                log("__________AVAILABLE DAYES:${availableDates.toSet()}");
                // List<Placemark> placemarks =
                //     await placemarkFromCoordinates(charterElement.location?.lat??0.0, charterElement.location?.long??0.0);
                // var first = placemarks.first;
                log("___________CHARTER CITIES:${charterElement.location.city}____Charter nane:${charterElement.name}");
                if (provider.bookingsModel.schedule?.dates?.every((element) =>
                        availableDates.contains(element.toDate())) ==
                    true) {
                  log("___________TRUE${charterElement.location?.lat}____${charterElement.location?.long}");
                  await moveToLocation(
                      LatLng(charterElement.location?.lat ?? 0.0,
                          charterElement.location?.long ?? 0.0),
                      charterElement);
                }
              } else {
                log("_________________TIME IS NOT VALIED");
              }
            }
          } else if (seeAllType == SeeAllType.charter.index) {
            log("________________________ELSE PART");
            await moveToLocation(
                LatLng(charterElement.location?.lat ?? 0.0,
                    charterElement.location?.long ?? 0.0),
                charterElement);
          }
        });
      } else if (seeAllType == SeeAllType.service.index) {
        await yachtVm.allServicesList.asyncForEach((serviceElement) async {
          mostOccurredCity.clear();
          String moveToCity =
              await getMostOccurredCity(yachtVm.allServicesList);
          lat = yachtVm.allServicesList
              .where((element) => element.location?.city == moveToCity)
              .first
              .location
              ?.lat;
          lng = yachtVm.allServicesList
              .where((element) => element.location?.city == moveToCity)
              .first
              .location
              ?.log;
          await moveToLocation(
              LatLng(serviceElement.location?.lat ?? 0.0,
                  serviceElement.location?.log ?? 0.0),
              serviceElement);
        });
      } else if (seeAllType == SeeAllType.yacht.index) {
        await yachtVm.allYachts.asyncForEach((serviceElement) async {
          mostOccurredCity.clear();
          String moveToCity = await getMostOccurredCity(yachtVm.allYachts);
          lat = yachtVm.allYachts
              .where((element) => element.location?.city == moveToCity)
              .first
              .location
              ?.lat;
          lng = yachtVm.allYachts
              .where((element) => element.location?.city == moveToCity)
              .first
              .location
              ?.long;
          await moveToLocation(
              LatLng(serviceElement.location?.lat ?? 0.0,
                  serviceElement.location?.long ?? 0.0),
              serviceElement);
        });
      }
      setState(() {});
      pro.update();
      Get.forceAppUpdate();
    });
  }

  Future<String> getMostOccurredCity(List<dynamic> list) async {
    String moveToCity = "";
    log("______________LIST LEN:${list.length}");
    await list.asyncForEach((charterElement) async {
      if (!mostOccurredCity.containsKey(charterElement.location?.city)) {
        mostOccurredCity[charterElement.location?.city] = 1;
      } else {
        mostOccurredCity[charterElement.location?.city] += 1;
      }
      setState(() {});
    });
    moveToCity = mostOccurredCity.keys.first;
    for (int i = 0; i < mostOccurredCity.entries.length - 1; i++) {
      if (mostOccurredCity.values.elementAt(i) >=
          mostOccurredCity.values.elementAt(i + 1)) {
        moveToCity = mostOccurredCity.keys.elementAt(i);
      }
    }
    log("__________________placefilterlist:${mostOccurredCity}");
    return moveToCity;
  }

  Future<List<DateTime>> getBookedDates(CharterModel? charter) async {
    var homeVm = Provider.of<HomeVm>(context, listen: false);
    List<DateTime> bookedDates = [];
    await homeVm.allBookings.asyncForEach((element) async {
      log("________BOOKING iD:${element.id}_______${element.charterFleetDetail == charter?.id}______${element.bookingStatus == BookingStatus.ongoing.index}___${(element.schedule?.dates?.length ?? 0) > 1}");
      if (element.charterFleetDetail == charter?.id &&
          element.bookingStatus == BookingStatus.ongoing.index &&
          (element.schedule?.dates?.length ?? 0) > 1) {
        log("__________________-IF TRUE");
        bookedDates = List.from(
            element.schedule?.dates?.map((e) => e.toDate()).toList() ?? []);
        setState(() {});
      }
    });
    log("____________BOOKED DATES LENgth:${bookedDates.length}");
    return bookedDates;
  }

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    isReserve = args["isReserve"];
    index = args["index"];
    seeAllType = args["seeAllType"];
    final Size windowSize = MediaQueryData.fromWindow(window).size;
    return Consumer<SearchVm>(builder: (context, provider, _) {
      return ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: isMapView ? R.colors.whiteColor : R.colors.black,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                  seeAllType == SeeAllType.service.index ||
                          seeAllType == SeeAllType.yacht.index
                      ? 90
                      : 120),
              child: Container(
                color: R.colors.black,
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leadingWidth: 50,
                      titleSpacing: 0,
                      leading: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: R.colors.whiteColor,
                          size: 20,
                        ),
                      ),
                      title: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: R.colors.blackDull),
                        child: TextFormField(
                          controller: searchCon,
                          onTap: () async {
                            // if(seeAllType!=-1)
                            //   {
                            //
                            //   }
                            searchPlace(seeAllType == SeeAllType.charter.index
                                ? yachtVm.allCharters
                                : seeAllType == SeeAllType.service.index
                                    ? yachtVm.allServicesList
                                    : yachtVm.allYachts);
                          },
                          cursorColor: Colors.white,
                          // readOnly: true,
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteColor, fontSize: 12.sp),
                          decoration: InputDecoration(
                              prefixIcon: Image.asset(
                                R.images.search,
                                scale: 7,
                              ),
                              hintText:
                                  "${getTranslated(context, "search")}...",
                              hintStyle: R.textStyle.helvetica().copyWith(
                                  color: R.colors.lightGrey,
                                  fontSize: 13.sp,
                                  height: 1.4),
                              border: InputBorder.none),
                        ),
                      ),
                      actions: [
                        GestureDetector(
                          onTap: () {
                            isMapView = !isMapView;
                            setState(() {});
                            log("____is map:${isMapView}");
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 15),
                            child: Image.asset(
                              isMapView == false
                                  ? R.images.mapView
                                  : R.images.listView,
                              height: isMapView ? 25 : 20,
                              width: isMapView ? 25 : 20,
                            ),
                          ),
                        )
                      ],
                    ),
                    if (seeAllType == SeeAllType.service.index ||
                        seeAllType == SeeAllType.yacht.index)
                      SizedBox()
                    else
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            PopupMenuButton(
                              key: pricePopUpKey,
                              enabled: enablePriceDropDown,
                              offset: Offset(windowSize.width / 15, 30),
                              elevation: 2,
                              color: R.colors.black,
                              itemBuilder: (BuildContext context) =>
                                  priceFilterList
                                      .map(
                                        (e) => PopupMenuItem(
                                          value: priceFilterList.indexOf(e),
                                          padding: EdgeInsets.only(left: 0.9.w),
                                          child: Center(
                                            child: Text(
                                              e,
                                              style: R.textStyle
                                                  .helveticaBold()
                                                  .copyWith(
                                                      color: selectedPrice ==
                                                              priceFilterList
                                                                  .indexOf(e)
                                                          ? R.colors.themeMud
                                                          : Colors.white,
                                                      fontSize: 11.sp,
                                                      height: 1.2),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onSelected: (int priceIndex) async {
                                startLoader();
                                setState(() {
                                  selectedPrice = priceIndex;
                                  enablePriceDropDown = false;
                                  enablePlaceDropDown = false;
                                  selectedPlace = null;
                                });
                                await priceFilter(priceIndex);
                                stopLoader();
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onCanceled: () {
                                setState(() {
                                  enablePriceDropDown = false;
                                });
                              },
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    dynamic state = pricePopUpKey.currentState;
                                    state.showButtonMenu();
                                    enablePriceDropDown = true;
                                    Get.forceAppUpdate();
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      getTranslated(context, "price") ?? "",
                                      style: R.textStyle
                                          .helveticaBold()
                                          .copyWith(
                                              color: enablePriceDropDown
                                                  ? R.colors.themeMud
                                                  : Colors.white,
                                              fontSize: 12.5.sp,
                                              height: 1.2),
                                    ),
                                    w2,
                                    Image.asset(
                                      R.images.drop,
                                      color: enablePriceDropDown
                                          ? R.colors.themeMud
                                          : Colors.white,
                                      height: Get.height * .01,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuButton(
                              key: placePopUpKey,
                              enabled: enablePriceDropDown,
                              offset: Offset(windowSize.width / 5, 30),
                              elevation: 2,
                              color: R.colors.black,
                              itemBuilder: (BuildContext context) =>
                                  placeFilterList
                                      .map((e) => PopupMenuItem(
                                            value: placeFilterList.indexOf(e),
                                            padding: EdgeInsets.only(
                                                left: 2.w, right: 2.w),
                                            child: Center(
                                              child: Text(
                                                e,
                                                style: R.textStyle
                                                    .helveticaBold()
                                                    .copyWith(
                                                        color: selectedPlace ==
                                                                placeFilterList
                                                                    .indexOf(e)
                                                            ? R.colors.themeMud
                                                            : Colors.white,
                                                        fontSize: 11.sp,
                                                        height: 1.2),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                              onSelected: (int placeIndex) async {
                                startLoader();
                                setState(() {
                                  selectedPlace = placeIndex;
                                  enablePlaceDropDown = false;
                                  enablePriceDropDown = false;
                                  selectedPrice = null;
                                });
                                await placeFilter(placeIndex);
                                stopLoader();
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onCanceled: () {
                                setState(() {
                                  enablePlaceDropDown = false;
                                });
                              },
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    dynamic state = placePopUpKey.currentState;
                                    state.showButtonMenu();
                                    enablePlaceDropDown = true;
                                    Get.forceAppUpdate();
                                  });
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        getTranslated(context, "place") ?? "",
                                        style: R.textStyle
                                            .helveticaBold()
                                            .copyWith(
                                                color: enablePlaceDropDown
                                                    ? R.colors.themeMud
                                                    : Colors.white,
                                                fontSize: 12.5.sp,
                                                height: 1.2),
                                      ),
                                      w2,
                                      Image.asset(
                                        R.images.drop,
                                        color: enablePlaceDropDown
                                            ? R.colors.themeMud
                                            : Colors.white,
                                        height: Get.height * .01,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isMapView == true)
                      SizedBox()
                    else
                      Divider(
                        color: R.colors.grey.withOpacity(.40),
                        thickness: 2,
                        height: Get.height * .02,
                      )
                  ],
                ),
              ),
            ),
            body: isMapView == false &&
                    (seeAllType == SeeAllType.charter.index || seeAllType == -1)
                ? charterListView()
                : isMapView == false && seeAllType == SeeAllType.service.index
                    ? serviceListView()
                    : isMapView == false && seeAllType == SeeAllType.yacht.index
                        ? yachtListView()
                        : Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              GoogleMap(
                                myLocationButtonEnabled: true,
                                myLocationEnabled: true,
                                zoomGesturesEnabled: true,
                                markers: marker,
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                        lat ?? 25.7716239, lng ?? -80.1397398),
                                    zoom: 12.0),
                              ),

                              // DraggableScrollableSheet(
                              //   initialChildSize: 0.45,
                              //   minChildSize: 0.15,
                              //   builder: (BuildContext context, ScrollController scrollController) {
                              //     return SingleChildScrollView(
                              //       controller: scrollController,
                              //       child: CustomScrollViewContent(provider),
                              //     );
                              //   },
                              // ),
                            ],
                          ),
          ),
        ),
      );
    });
  }

  Widget charterPopups(
    CharterModel charterModel,
  ) {
    log("____ISMAP:${isMapView}");
    return Consumer<SearchVm>(builder: (context, provider, _) {
      return FutureBuilder(
          future: provider.getCharterFromBooking(charterModel),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var charter = snapshot.data as CharterModel;
              return GestureDetector(
                  onTap: () async {
                    Get.back();

                    setState(() {});

                    Get.toNamed(CharterDetail.route, arguments: {
                      "yacht": charter,
                      "isReserve": isReserve,
                      "index": index,
                      "isEdit": false
                    });
                  },
                  child: CharterWidget(
                    charter: charterModel,
                    width: Get.width * .85,
                    height: Get.height * .2,
                    isSmall: false,
                    isPopUp: isMapView ? true : false,
                    isFav: yachtVm.userFavouritesList.any((element) =>
                        element.favouriteItemId == charter.id &&
                        element.type == FavouriteType.charter.index),
                    isFavCallBack: () async {
                      FavouriteModel favModel = FavouriteModel(
                          creaatedAt: Timestamp.now(),
                          favouriteItemId: charterModel.id,
                          id: charterModel.id,
                          type: FavouriteType.charter.index);
                      if (yachtVm.userFavouritesList
                          .any((element) => element.id == charter.id)) {
                        yachtVm.userFavouritesList.removeAt(index);
                        yachtVm.update();
                        await FbCollections.user
                            .doc(appwrite.user.$id)
                            .collection("favourite")
                            .doc(charter.id)
                            .delete();
                      } else {
                        await FbCollections.user
                            .doc(appwrite.user.$id)
                            .collection("favourite")
                            .doc(charter.id)
                            .set(favModel.toJson());
                      }
                      provider.update();
                    },
                  ));
            } else {
              return SizedBox();
            }
          });
    });
  }

  Widget servicePopups(ServiceModel service) {
    return Consumer<SearchVm>(builder: (context, provider, _) {
      return Container(
        height: Get.height * .3,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () {
            Get.toNamed(ServiceDetail.route, arguments: {
              "service": service,
              "isHostView": false,
              "index": index
            });
          },
          child: HostWidget(
            service: service,
            width: isMapView ? Get.width * .3 : Get.width * .85,
            height: Get.height * .2,
            isShowRating: false,
            isShowStar: true,
            isFav: yachtVm.userFavouritesList.any((element) =>
                element.favouriteItemId == service.id &&
                element.type == FavouriteType.service.index),
            isFavCallBack: () async {
              FavouriteModel favModel = FavouriteModel(
                  creaatedAt: Timestamp.now(),
                  favouriteItemId: service.id,
                  id: service.id,
                  type: FavouriteType.service.index);
              if (yachtVm.userFavouritesList
                  .any((element) => element.id == service.id)) {
                yachtVm.userFavouritesList.removeAt(index);
                yachtVm.update();
                await FbCollections.user
                    .doc(appwrite.user.$id)
                    .collection("favourite")
                    .doc(service.id)
                    .delete();
              } else {
                await FbCollections.user
                    .doc(appwrite.user.$id)
                    .collection("favourite")
                    .doc(service.id)
                    .set(favModel.toJson());
              }
              provider.update();
            },
          ),
        ),
      );
    });
  }

  Widget yachtPopups(YachtsModel yacht) {
    return Consumer<SearchVm>(builder: (context, provider, _) {
      return GestureDetector(
        onTap: () {
          Get.toNamed(YachtDetail.route,
              arguments: {"yacht": yacht, "isEdit": false, "index": -1});
        },
        child: Padding(
          padding: EdgeInsets.only(right: 10),
          child: YachtWidget(
              yacht: yacht,
              width: Get.width * .9,
              height: Get.height * .2,
              isSmall: false,
              isPopUp: isMapView ? true : false),
        ),
      );
    });
  }

  Widget charterListView() {
    return Consumer<YachtVm>(builder: (context, yachtVm, _) {
      return (selectedPlace != null &&
                  placeFilterListView(selectedPlace ?? 0).isEmpty) ||
              (selectedPrice != null &&
                  priceFilterListView(selectedPrice ?? 0).isEmpty) ||
              (yachtVm.allCharters.isEmpty)
          ? EmptyScreen(
              title: "no_charter",
              subtitle: "no_charter_has_been_saved_yet",
              img: R.images.noFav,
            )
          : ModalProgressHUD(
              inAsyncCall: yachtVm.isLoading,
              progressIndicator: SpinKitPulse(
                color: R.colors.themeMud,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Get.height * .02),
                child: SingleChildScrollView(
                  child: Center(
                    child: Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      children: List.generate(
                          selectedPlace != null
                              ? placeFilterListView(selectedPlace ?? 0).length
                              : selectedPrice != null
                                  ? priceFilterListView(selectedPrice ?? 0)
                                      .length
                                  : yachtVm.allCharters.length, (index) {
                        CharterModel model = selectedPlace != null
                            ? placeFilterListView(selectedPlace ?? 0)
                                .toList()[index]
                            : selectedPrice != null
                                ? priceFilterListView(selectedPrice ?? 0)
                                    .toList()[index]
                                : yachtVm.allCharters[index];
                        return charterPopups(model);
                      }),
                    ),
                  ),
                ),
              ),
            );
    });
  }

  Widget serviceListView() {
    return Consumer<YachtVm>(builder: (context, yachtVm, _) {
      return (yachtVm.allServicesList.isEmpty)
          ? EmptyScreen(
              title: "no_charter",
              subtitle: "no_charter_has_been_saved_yet",
              img: R.images.noFav,
            )
          : ModalProgressHUD(
              inAsyncCall: yachtVm.isLoading,
              progressIndicator: SpinKitPulse(
                color: R.colors.themeMud,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Get.height * .02),
                child: SingleChildScrollView(
                  child: Center(
                    child: Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      children: List.generate(
                          selectedPlace != null
                              ? placeFilterListView(selectedPlace ?? 0).length
                              : selectedPrice != null
                                  ? priceFilterListView(selectedPrice ?? 0)
                                      .length
                                  : yachtVm.allServicesList.length, (index) {
                        ServiceModel model = yachtVm.allServicesList[index];
                        return servicePopups(model);
                      }),
                    ),
                  ),
                ),
              ),
            );
    });
  }

  Widget yachtListView() {
    return Consumer<YachtVm>(builder: (context, yachtVm, _) {
      return (yachtVm.allYachts.isEmpty)
          ? EmptyScreen(
              title: "no_charter",
              subtitle: "no_charter_has_been_saved_yet",
              img: R.images.noFav,
            )
          : ModalProgressHUD(
              inAsyncCall: yachtVm.isLoading,
              progressIndicator: SpinKitPulse(
                color: R.colors.themeMud,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Get.height * .02),
                child: SingleChildScrollView(
                  child: Center(
                    child: Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      children:
                          List.generate(yachtVm.allYachts.length, (index) {
                        YachtsModel model = yachtVm.allYachts[index];
                        return yachtPopups(model);
                      }),
                    ),
                  ),
                ),
              ),
            );
    });
  }

  ///MAP FUNCTIONS
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.setMapStyle(Utils.mapStyles);
    // mapController?.
    //     setMapStyle(mapStyle);
  }

  moveToLocation(LatLng latLng, dynamic charterModel) async {
    log("___________________IN MOVE LOCATION");
    setState(() {
      lat = latLng.latitude;
      lng = latLng.longitude;
    });

    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat ?? 0.0, lng ?? 0.0), zoom: 10),
      ),
    );
    setMarker(latLng, charterModel);
  }

  void setMarker(LatLng latLng, dynamic charterModel) {
    // markers.clear();
    log("__________________IN SET MARLKER ID:${charterModel.id ?? ""}____${charterModel.name}");
    setState(() {
      marker.add(
        Marker(
          icon: sourceIcon!,
          markerId: MarkerId(charterModel.id ?? ""),
          position: latLng,
          infoWindow: InfoWindow(title: charterModel.name),
          onTap: () {
            if (seeAllType == -1 || seeAllType == SeeAllType.charter.index) {
              Get.bottomSheet(charterPopups(charterModel));
            } else if (seeAllType == SeeAllType.service.index) {
              Get.bottomSheet(servicePopups(charterModel));
            } else if (seeAllType == SeeAllType.yacht.index) {
              Get.bottomSheet(yachtPopups(charterModel));
            }
          },
        ),
      );
    });
  }

  getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        lat = position.latitude;
        lng = position.longitude;
        print('CURRENT POS: $_currentPosition');
        print('CURRENT Laritude: $lat');
        // _sourceMarker(latitude, longitude);
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 12.0,
            ),
          ),
        );
      });
      // await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  takePermissions() async {
    if (await Permission.location.request().isGranted &&
        await Permission.camera.request().isGranted) {
      setSourceAndDestinationIcons();
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
    ].request();
    print(statuses[Permission.camera]);
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      R.images.pin,
    );
  }
}
