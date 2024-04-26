import 'dart:async';
import 'dart:developer';

import 'package:async_foreach/async_foreach.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master/constant/constant.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/image_picker_services.dart';
import 'package:yacht_master/src/auth/model/favourite_model.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/model/services_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/yacht/model/choose_offers.dart';
import 'package:yacht_master/src/base/yacht/model/yachts_model.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/zbot_toast.dart';

class YachtVm extends ChangeNotifier {
  bool isLoading = false;

  ServiceModel? serviceModel = ServiceModel();
  StreamSubscription<List<ServiceModel>>? servicesStream;
  StreamSubscription<List<CharterModel>>? charterStream;
  StreamSubscription<List<YachtsModel>>? yachtStream;
  StreamSubscription<List<FavouriteModel>>? userFavouritesStream;
  CharterModel? charterModel =
      CharterModel(availability: Availability(dates: []));
  YachtsModel? yachtsModel;
  List<ChooseOffers> selectedOffers = [];
  List<ChooseOffers> chooseServicesList = [];
  List<FavouriteModel> userFavouritesList = [];
  List<ServiceModel> allServicesList = [];
  List<ServiceModel> hostServicesList = [];
  List<CharterModel> allCharters = [];
  List<CharterModel> hostCharters = [];
  List<YachtsModel> allYachts = [];
  List<YachtsModel> hostYachts = [];
  List<UserModel> allHosts = [];
  List<String> charterCities = [];
  Future<void> fetchServices() async {
    log("/////////////////////IN FETCH Services");
    hostServicesList = [];
    allServicesList = [];
    AuthVm authVm = Provider.of<AuthVm>(Get.context!, listen: false);
    var ref = FbCollections.services
        // .where("created_by",isEqualTo:authVm.userModel?.uid)
        .snapshots()
        .asBroadcastStream();
    var res = ref.map((list) =>
        list.docs.map((e) => ServiceModel.fromJson(e.data())).toList());
    try {
      servicesStream ??= res.listen((services) async {
        if (services.isNotEmpty) {
          allServicesList =
              services.where((element) => element.status == 0).toList();
          log("__________HOST UID:${FirebaseAuth.instance.currentUser?.uid}");
          hostServicesList = services
              .where((element) =>
                  element.createdBy == FirebaseAuth.instance.currentUser?.uid &&
                  element.status == 0)
              .toList();
          notifyListeners();
          log("//////////////////////////////////////////////All SERVICES :${allServicesList.length}/////host SERVICES :${hostServicesList.length}/////${FirebaseAuth.instance.currentUser?.uid}");
        }
        notifyListeners();
      });
    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log(e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchCharterOffers() async {
    try {
      chooseServicesList = [];
      QuerySnapshot offers = await FbCollections.chartersOffers.get();
      offers.docs.forEach((element) {
        chooseServicesList.add(ChooseOffers.fromJson(element.data()));
      });
      log("___CHARTER OFFERS:${chooseServicesList.length}");
      notifyListeners();
    } on Exception catch (e) {
      log("Error:${e.toString()}");
    }
  }

  Future<void> fetchCharters() async {
    var settingsVm = Provider.of<SettingsVm>(Get.context!, listen: false);

    try {
      hostCharters = [];
      allCharters = [];
      var ref = FbCollections.charterFleet.snapshots().asBroadcastStream();
      var res = ref.map((list) =>
          list.docs.map((e) => CharterModel.fromJson(e.data())).toList());
      charterStream ??= res.listen((charters) async {
        if (charters.isNotEmpty) {
          allCharters = charters
              .where((element) => element.status == CharterStatus.active.index)
              .toList();
          hostCharters = charters
              .where((element) =>
                  element.createdBy == FirebaseAuth.instance.currentUser?.uid &&
                  element.status == CharterStatus.active.index)
              .toList();
          log("Test");
          List<UserModel>? hosts = await fetchAllHost(charters);
          notifyListeners();
          log("Test2");
          log("About to fetch reviews");
          await settingsVm.fetchReviews(hosts);
          notifyListeners();
          await getCitiesList();

          log("//////////////////////All Charters :${allCharters.length}/////host charters :${hostCharters.length}____hosts:${hosts?.length}____");
        }
      });
      notifyListeners();
    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log("${e}Is the error in Reviews");
    }
  }

  Future<CharterModel> fetchCharterById(String id) async {
    DocumentSnapshot ref = await FbCollections.charterFleet.doc(id).get();
    CharterModel charter = CharterModel.fromJson(ref.data());
    return charter;
  }

  Future<List<UserModel>?> fetchAllHost(List<CharterModel> charters) async {
    log("/////////////////IN FETCH ALL HOSTS");
    try {
      await charters.asyncForEach((element) async {
        var doc = await FbCollections.user.doc(element.createdBy).get();
        UserModel hostOfCharter = UserModel.fromJson(doc.data());
        hostOfCharter.rating = 0.0;
        if (!allHosts.any((element) => element.uid == hostOfCharter.uid)) {
          allHosts.add(hostOfCharter);
        }
      });
      update();
      return allHosts;
    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log(e.toString());
      return null;
    }
  }

  sortHostsByBookings() async {
    var homeVm = Provider.of<HomeVm>(Get.context!, listen: false);
    log("___________BEFORE SORTING BY BOOKINGS HOSTS:${allHosts.length}");
    List<UserModel> sortedUser = [];
    allHosts.forEach((hostElement) {
      int count = 0;
      homeVm.allBookings.forEach((element) {
        if ((element.hostUserUid == hostElement.uid &&
                element.bookingStatus == BookingStatus.completed.index) ==
            true) {
          count = count + 1;
          log("////////////////////count here:${count}");
          update();
        }
      });
      log("////////////////////count:${count}");
      var bookingVm = Provider.of<BookingsVm>(Get.context!, listen: false);
      if (count >= (bookingVm.appUrlModel?.superhostminimumbookings ?? 0)) {
        sortedUser.add(hostElement);
        update();
      }
    });
    allHosts = List.from(sortedUser);
    update();
    log("___________AFTER SORTING BY BOOKINGS HOSTS:${allHosts.length}");
  }

  getCitiesList() {
    charterCities = [];
    charterCities = allCharters.map((e) => e.location?.city ?? "").toList();
    charterCities = charterCities.toSet().toList();
    log("___________cities:${charterCities}");
    notifyListeners();
  }

  Future<void> fetchYachts() async {
    try {
      log("/////////////////////IN FETCH Yachts");
      hostYachts = [];
      allYachts = [];
      var ref = FbCollections.yachtForSale.snapshots().asBroadcastStream();
      var res = ref.map((list) =>
          list.docs.map((e) => YachtsModel.fromJson(e.data())).toList());
      yachtStream ??= res.listen((yachts) async {
        if (yachts.isNotEmpty) {
          log("__________YACHT:${yachts.length}");
          allYachts = yachts.where((element) => element.status == 0).toList();
          hostYachts = yachts
              .where((element) =>
                  element.createdBy == FirebaseAuth.instance.currentUser?.uid &&
                  element.status == 0)
              .toList();
          notifyListeners();
          log("//////////////////////////////////////////////All YACHT :${allYachts.length}/////host yachts :${hostYachts.length}");
        }
        notifyListeners();
      });

      notifyListeners();
    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log(e.toString());
    }
  }

  Future<void> fetchUserFavourites() async {
    log("/////////////////////IN FETCH Fav${FirebaseAuth.instance.currentUser?.uid}");
    userFavouritesList = [];
    var ref = FbCollections.user
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("favourite")
        .snapshots()
        .asBroadcastStream();
    var res = ref.map((list) =>
        list.docs.map((e) => FavouriteModel.fromJson(e.data())).toList());
    try {
      userFavouritesStream ??= res.listen((fav) async {
        if (fav.isNotEmpty) {
          userFavouritesList = fav;
          notifyListeners();
          log("//////////////////////////////////////////////USER FAV :${userFavouritesList.length}//");
        }
        notifyListeners();
      });
    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log(e.toString());
    }
    notifyListeners();
  }

  onClickAddService(
      String? city,
      bool isEdit,
      List<XFile> fileImages,
      List<String> networkImagesList,
      List<String> deletedImagesRef,
      String whatYouDoCon,
      String nameCon,
      String locationCon,
      LatLng? locationLatLng,
      BuildContext context) async {
    ZBotToast.loadingShow();

    var authVm = Provider.of<AuthVm>(context, listen: false);
    var searchVm = Provider.of<SearchVm>(context, listen: false);
    log("_____________FILES IMAGES LEN:${fileImages.length}");
    if (fileImages.isNotEmpty) {
      networkImagesList =
          await uploadServiceImages(fileImages, "serviceImages");
    }
    if (networkImagesList.isEmpty) {
      Helper.inSnackBar("Error", "Please upload images", R.colors.themeMud);
    } else {
      log("_____________NETWORK IMAGES LEN:${networkImagesList.length}");
      if (isEdit == true) {
        log("____________________in eidt:${deletedImagesRef.toSet()}");
        try {
          await deletedImagesRef.asyncForEach((element) async {
            await FirebaseStorage.instance.refFromURL(element).delete();
            update();
          });
        } on Exception catch (e) {
          // TODO
          debugPrintStack();
          log("EXECP:${e.toString()}");
        }
        serviceModel?.description = whatYouDoCon;
        serviceModel?.name = nameCon;
        serviceModel?.images = List.from(networkImagesList);
        serviceModel?.location = LocationModel(
            address: locationCon,
            lat: locationLatLng?.latitude,
            log: locationLatLng?.longitude,
            city: city);
        log("____________SERVICE ID:${serviceModel?.id}");
        try {
          await FbCollections.services.doc(serviceModel?.id).update({
            "name": serviceModel?.name,
            "description": serviceModel?.description,
            "location": serviceModel?.location?.toJson(),
            "images": networkImagesList
          });
        } on Exception catch (e) {
          // TODO
          debugPrintStack();
          log("EXCPE:${e.toString()}");
        }
        // servicesList[index]=serviceModel??ServiceModel();
      } else {
        String docID = Timestamp.now().millisecondsSinceEpoch.toString();

        log("______________no edit images:${networkImagesList.length}");
        serviceModel = ServiceModel(
          id: docID,
          status: 0,
          name: nameCon,
          images: networkImagesList,
          createdAt: Timestamp.now(),
          createdBy: authVm.userModel?.uid,
          location: LocationModel(
              address: locationCon,
              lat: locationLatLng?.latitude,
              log: locationLatLng?.longitude,
              city: city),
          description: whatYouDoCon,
        );
        try {
          await FbCollections.services.doc(docID).set(serviceModel?.toJson());
          // searchVm.servicesList.add(serviceModel!);
        } on Exception catch (e) {
          // TODO
          ZBotToast.loadingClose();
          log("__________EXCEP:${e.toString()}");
        }
      }

      update();
      searchVm.update();
      Get.back();
      ZBotToast.loadingClose();
      if (isEdit == true) {
        Get.back();
      }

      Helper.inSnackBar(
          "Success",
          isEdit == true
              ? "Service updated successfully"
              : "Service added successfully",
          R.colors.themeMud);
    }
  }

  uploadServiceImages(List<XFile> fileImages, String bucketName) async {
    List<String> newUploadedImages = [];
    try {
      newUploadedImages =
          await ImagePickerServices().uploadPostImages(fileImages, bucketName);
      update();
      return newUploadedImages;
    } on Exception catch (e) {
      // TODO
      ZBotToast.loadingClose();

      log("__________EXCE:${e.toString()}");
    }
  }

  onClickAddYacht(
      String? city,
      bool isEdit,
      List<XFile> fileImages,
      List<String> networkImagesList,
      List<String> deletedImagesRef,
      String whatYouDoCon,
      String priceCon,
      String nameCon,
      String locationCon,
      LatLng? locationLatLng,
      BuildContext context) async {
    var authVm = Provider.of<AuthVm>(context, listen: false);
    var searchVm = Provider.of<SearchVm>(context, listen: false);
    ZBotToast.loadingShow();
    if (fileImages.isNotEmpty) {
      networkImagesList = await uploadServiceImages(fileImages, "yachtImages");
    }
    if (networkImagesList.isEmpty) {
      Helper.inSnackBar("Error", "Please upload images", R.colors.themeMud);
    } else {
      String docID = Timestamp.now().millisecondsSinceEpoch.toString();

      if (isEdit == true) {
        log("____________________in eidt:");
        try {
          await deletedImagesRef.asyncForEach((element) async {
            await FirebaseStorage.instance.refFromURL(element).delete();
            update();
          });
        } on Exception catch (e) {
          ZBotToast.loadingClose();
          debugPrintStack();
          log(e.toString());
        }
        yachtsModel?.description = whatYouDoCon;
        yachtsModel?.name = nameCon;
        yachtsModel?.price = double.parse(priceCon);
        yachtsModel?.images = List.from(networkImagesList);
        yachtsModel?.location = YachtLocation(
            address: locationCon,
            lat: locationLatLng?.latitude,
            long: locationLatLng?.longitude,
            city: city);
        log("______________YACHT ID:${yachtsModel?.id}");
        await FbCollections.yachtForSale.doc(yachtsModel?.id).update({
          "name": yachtsModel?.name,
          "description": yachtsModel?.description,
          "price": yachtsModel?.price,
          "location": yachtsModel?.location?.toJson(),
          "images": networkImagesList
        });
        // servicesList[index]=serviceModel??ServiceModel();
      } else {
        log("______________no edit images:${networkImagesList.length}");
        yachtsModel = YachtsModel(
          id: docID,
          name: nameCon,
          status: 0,
          images: networkImagesList,
          createdAt: Timestamp.now(),
          createdBy: authVm.userModel?.uid,
          price: double.parse(priceCon),
          location: YachtLocation(
              address: locationCon,
              lat: locationLatLng?.latitude,
              long: locationLatLng?.longitude,
              city: city),
          description: whatYouDoCon,
        );
        try {
          await FbCollections.yachtForSale
              .doc(docID)
              .set(yachtsModel?.toJson());
        } on Exception catch (e) {
          // TODO
          ZBotToast.loadingClose();
          debugPrintStack();
          log("__________EXCEP:${e.toString()}");
        }
      }
      update();
      searchVm.update();
      ZBotToast.loadingClose();
      Get.back();
      if (isEdit == true) {
        Get.back();
      }
      Helper.inSnackBar(
          "Success",
          isEdit == true
              ? "Yacht updated successfully"
              : "Yacht added successfully",
          R.colors.themeMud);
    }
  }

  onClickAddCharter(
      int? isPetAllow,
      String? city,
      bool isEdit,
      List<XFile> fileImages,
      List<String> networkImagesList,
      List<String> deletedImagesRef,
      String subheadingCon,
      String guestCountCon,
      String priceFourCon,
      String priceEightCon,
      String priceFullCon,
      String nameCon,
      String locationCon,
      LatLng? locationLatLng,
      String dockNo,
      String slipNo,
      BuildContext context) async {
    var searchVm = Provider.of<SearchVm>(context, listen: false);
    ZBotToast.loadingShow();
    if (fileImages.isNotEmpty) {
      networkImagesList =
          await uploadServiceImages(fileImages, "charterImages");
    }
    if (networkImagesList.isEmpty) {
      Helper.inSnackBar("Error", "Please upload images", R.colors.themeMud);
    } else {
      String docID = Timestamp.now().millisecondsSinceEpoch.toString();

      charterModel?.name = nameCon;
      charterModel?.isPetAllow = isPetAllow == 0 ? true : false;
      charterModel?.subHeading = subheadingCon;
      charterModel?.guestCapacity = int.parse(guestCountCon);
      charterModel?.images = List.from(networkImagesList);
      charterModel?.location = CharterLocationModel(
          adress: locationCon,
          lat: locationLatLng?.latitude,
          long: locationLatLng?.longitude,
          city: city,
          dockno: dockNo,
          slipno: slipNo);
      charterModel?.priceFullDay =
          priceFullCon.isNotEmpty ? double.parse(priceFullCon) : 0;
      charterModel?.priceHalfDay =
          priceEightCon.isNotEmpty ? double.parse(priceEightCon) : 0;
      charterModel?.priceFourHours =
          priceFourCon.isNotEmpty ? double.parse(priceFourCon) : 0;
      if (isEdit == true) {
        log("____________________in eidt:");
        try {
          await deletedImagesRef.asyncForEach((element) async {
            await FirebaseStorage.instance.refFromURL(element).delete();
            update();
          });
        } on Exception catch (e) {
          ZBotToast.loadingClose();
          debugPrintStack();
          log("Excep:${e.toString()}");
        }

        await FbCollections.charterFleet
            .doc(charterModel?.id)
            .set(charterModel?.toJson());
        // await  FbCollections.charterFleet.doc(charterModel?.id).update({
        //  "name":charterModel?.name,
        //  "sub_heading":charterModel?.subHeading,
        //  "location":charterModel?.location?.toJson(),
        //  "images":networkImagesList,
        //  "yacht_rules":charterModel?.yachtRules?.toJson(),
        //  "health_safety":charterModel?.healthSafety?.toJson(),
        //  "cancelation_policy":charterModel?.cancelationPolicy?.toJson(),
        //  "price_full_day":charterModel?.priceFullDay,
        //  "price_half_day":charterModel?.priceHalfDay,
        //  "price_four_hours":charterModel?.priceFourHours,
        //  "guest_capacity":charterModel?.guestCapacity,
        //  "charters_offers":charterModel?.chartersOffers,
        //  "availability":charterModel?.availability?.toJson(),
        //  "is_pet_allow":charterModel?.isPetAllow,
        //
        // });
        // servicesList[index]=serviceModel??ServiceModel();
      } else {
        charterModel?.createdBy = FirebaseAuth.instance.currentUser?.uid;
        charterModel?.id = docID;
        charterModel?.createdAt = Timestamp.now();
        charterModel?.status = 0;
        charterModel?.availability =
            charterModel?.availability ?? Availability();
        charterModel?.healthSafety =
            charterModel?.healthSafety ?? HealthSafety();
        charterModel?.boardingInstructions =
            charterModel?.boardingInstructions ?? BoardingInstructions();
        charterModel?.yachtRules = charterModel?.yachtRules ?? YachtRules();
        try {
          await FbCollections.charterFleet
              .doc(docID)
              .set(charterModel?.toJson());
          // searchVm.servicesList.add(serviceModel!);
        } on Exception catch (e) {
          // TODO
          ZBotToast.loadingClose();
          log("__________EXCEP:${e.toString()}");
        }
      }

      update();
      searchVm.update();
      ZBotToast.loadingClose();
      Get.back();
      if (isEdit == true) {
        Get.back();
      }
      Helper.inSnackBar(
          "Success",
          isEdit == true
              ? "Charter updated successfully"
              : "Charter Fleet added successfully",
          R.colors.themeMud);
    }
  }

  startLoader() {
    isLoading = true;
    notifyListeners();
  }

  stopLoader() {
    isLoading = false;
    notifyListeners();
  }

  update() {
    notifyListeners();
  }
}
