import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../resources/decorations.dart';
import '../resources/resources.dart';
import '../src/base/search/view_model/search_vm.dart';
import '../src/base/settings/view_model/settings_vm.dart';
import 'helper.dart';
import 'mapstyle.dart';
import 'permission_dialog.dart';

class PickLocation extends StatefulWidget {
  LatLng? selectedLatLng;

  PickLocation({this.selectedLatLng});

  @override
  _PickLocationState createState() => _PickLocationState();
}

class _PickLocationState extends State<PickLocation> {
  

  var vm = Provider.of<SettingsVm>(Get.context!, listen: false);
  var searchVm = Provider.of<SearchVm>(Get.context!, listen: false);
  String locationAddress="";
  @override
  void initState() {
    // TODO: implement initState

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      searchVm.newLocationLatLng=null;
      print("_____________________Selecred:${widget.selectedLatLng}");
      if(widget.selectedLatLng!=null && widget.selectedLatLng?.longitude!=0.0 && widget.selectedLatLng?.latitude!=0.0)
      {
        searchVm.newLocationLatLng=widget.selectedLatLng;

        setMarker(searchVm.newLocationLatLng!, true);
      }else{
        print("HERE");
        await getMyLoc();
        setMarker(LatLng(locationData!.latitude, locationData!.longitude), true);
      }

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.selectedLatLng!=null)
    {
      searchVm.newLocationLatLng=widget.selectedLatLng;}
    log("_____________________Selecred:${widget.selectedLatLng}");

    return Consumer2<SearchVm,SettingsVm>(builder: (context, searcVm,model, _) {
      return ModalProgressHUD(
        inAsyncCall: model.isLoading,
        progressIndicator:SpinKitPulse(color: R.colors.themeMud,),
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                )),
            centerTitle: true,
            backgroundColor: R.colors.themeMud,
            leading: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: R.colors.whiteColor,
                  size: 18,
                )),
            title: Text(
              "Select Location",
              style: R.textStyle
                  .helveticaBold()
                  .copyWith(fontSize: 4.w, color: R.colors.whiteColor),
            ),
          ),
          body: Stack(
            children: [
              GoogleMap(
                padding: EdgeInsets.only(top: 10.h),
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                // markers: model.markers,
                onMapCreated: (GoogleMapController controller) {
                  googleController=controller;
                  googleController!.setMapStyle(Utils.mapStyles);
                },
                initialCameraPosition: CameraPosition(
                    target:searchVm.newLocationLatLng!=null?searchVm.newLocationLatLng!:
                    locationData!=null?LatLng(
                        locationData!.latitude??0.0,locationData!.longitude??0.0):
                    LatLng(51.5072,0.1276),
                    zoom: 14.0),

                onTap: (latLng) {
                  moveToLocation(
                    latLng,
                  );
                },
                markers: searchVm.marker,
              ),
              Positioned(
                top: 100,
                left: 30,
                right: 30,
                child: TextFormField(
                  onTap: () async {
                    // model.startLoader();
                    await searchVm.search(searchController,googleController!);
                    // model.stopLoader();

                  },
                  decoration: InputDecoration(
                    filled: true,
                    isDense: true,

                    fillColor: R.colors.whiteColor,
                    hintText: "Search Location",

                    hintStyle: R.textStyle.helveticaBold(),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: R.colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: R.colors.grey,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: R.colors.grey,
                      ),
                    ),
                    //  border: OutlineInputBorder()
                  ),
                  controller: searchController,
                  cursorColor: R.colors.themeMud,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,right: 0,
                child: GestureDetector(
                  onTap: (){
                    locationAddress=searchController.text;
                    model.update();
                    Get.back(result: {"locationAddress":locationAddress,
                      "latlng":searchVm.newLocationLatLng ?? LatLng(locationData?.latitude??0.0,
                        locationData?.longitude??0.0),"city":searchVm.city});
                    searchVm.city="";
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.w,vertical: 2.h),
                    alignment: Alignment.center,
                    height: 6.h,
                    decoration: AppDecorations.buttonDecoration(R.colors.themeMud,30),
                    child: Text(
                      "Select",
                      style: R.textStyle.helveticaBold().copyWith(
                        color:R.colors.whiteColor,fontSize: 3.w,
                      ),
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      );
    });
  }
  GoogleMapController? googleController ;
  // LatLng? selectedLatLng;
  bool? _serviceEnabled;
  // locations.PermissionStatus? _permissionGranted;
  LatLng? locationData;
  /////backend data
  String confirmedLocation = "";
  Map address = {};
  BitmapDescriptor? sourceIcon;


  TextEditingController searchController = new TextEditingController();
  // locations.Location location = new locations.Location();

   takePermissions() async {
    if (await Permission.location.request().isGranted &&
        await Permission.camera.request().isGranted) {
      setSourceAndDestinationIcons();
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();
    print(statuses[Permission.location]);
  }


  //  enableBackgroundMode() async {
  //   bool _bgModeEnabled = await location.isBackgroundModeEnabled();
  //   log("_________________________IS BACKGROUND MODE ENABLE:${_bgModeEnabled}");
  //   if (_bgModeEnabled) {
  //     return true;
  //   } else {
  //     try {
  //       await location.enableBackgroundMode();
  //     } catch (e) {
  //       log(e.toString());
  //     }
  //     try {
  //       _bgModeEnabled = await location.enableBackgroundMode();
  //     } catch (e) {
  //       log(e.toString());
  //     }
  //     log("++++++++++++++++++BG${_bgModeEnabled}"); //True!
  //     return _bgModeEnabled;
  //   }
  // }
  getMyLoc() async {
    try {
      print("___IN GET MY LOC");
      var status = await Permission.location.status;
      print("___status:${status}");

      bool? locCheck = await Helper.checkPermissionStatus(status,);
      print("___locCheck:${locCheck}");

      if(locCheck==true)
        {
          locationData = await Helper.getLocation();
        }
      else{
        Get.dialog(PermissionDialog());
      }
      print("my lat ${locationData!.latitude} my lng ${locationData!.longitude}");
    } on Exception catch (e) {
      print(e.toString());
    }
  }
  
   moveToLocation(
      LatLng latLng,
      ) async {
    log("_______________________MOVE TO LOCATION:${latLng}");
    googleController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target:latLng,
          zoom: 4.0,
        ),
      ),
    );
    setMarker(latLng, true);
  }

  void setMarker(LatLng latLng, bool isGetCityCall) {
    searchVm.marker.clear();
    searchVm.marker.add(Marker(
        markerId:  MarkerId(latLng.toString()), position: latLng));

    log("_________________________________MARKER LEN:${searchVm.marker.length}");
    if (isGetCityCall) {
      searchVm.getCity(latLng, "",searchController);
    }
    googleController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target:latLng,
          zoom: 10.0,
        ),
      ),
    );
    setState(() {

    });
  }
  bool? isLoading=false;
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
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),        R.images.pin,);}
}
