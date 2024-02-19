
import 'dart:core';
import 'dart:developer';
import 'dart:io';
import 'package:async_foreach/async_foreach.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'dart:convert';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/mapstyle.dart';

class LatLngModel{
  double lat;
  double lng;
  int id;

  LatLngModel(this.lat, this.lng, this.id);
}
class TestingScreen extends StatefulWidget {
static String route="/testingScreen";
  @override
  _TestingScreenState createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  GoogleMapController? mapController;
  double? lat = 51.5072;
  double? lng = 0.1276;
  String mapStyle = "";
  Set<Marker> marker = new Set();
  BitmapDescriptor? sourceIcon;
  List<LatLngModel> latlngs=[
    LatLngModel(36.45, 78.28, 0),
    LatLngModel(32.45, 75.28, 1),
    LatLngModel(33.45, 76.28, 2),
    LatLngModel(34.45, 77.28, 3),
  ];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await moveToLocation(LatLng(latlngs.first.lat, latlngs.first.lng));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      appBar: GeneralAppBar.simpleAppBar(context, "Testing"),
      body:   Container(
        height: Get.height * .25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: R.colors.blackLight,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            markers: marker,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
                target: LatLng(latlngs.first.lat, latlngs.first.lng),
                zoom: 14.0),
          ),
        ),
      ),
    );
  }
  ///MAP FUNCTIONS
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.setMapStyle(Utils.mapStyles);
    // mapController?.
    //     setMapStyle(mapStyle);
  }

   moveToLocation(
      LatLng latLng,
      ) async {
    await setSourceAndDestinationIcons();
    setState(() {
      lat = latLng.latitude;
      lng = latLng.longitude;
    });

    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 12),
      ),
    );
    await latlngs.asyncForEach((element) async{
      setMarker(LatLng(element.lat, element.lng), false,id: element.id.toString());});
    log("_____________MAKERS LEN___${latlngs.length}____${marker.length}");
    setMarker(latLng, true);
  }

  void setMarker(LatLng latLng, bool isGetCityCall,{String id="0"}) {
    // markers.clear();
    setState(() {
      // marker.clear();
      marker.add(Marker(
          icon: sourceIcon!,
          markerId: MarkerId(id),
          position: latLng));
    });
  }

  setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      R.images.pin,
    );
  }
}
