import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/src/base/profile/model/review_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';


class BaseVm extends ChangeNotifier {

  List<String> bottomIcons = [
    R.images.searchFilled,
    R.images.star,
    R.images.inbox,
    R.images.more
  ];
  int selectedPage = 0;
  bool isHome = true;

  List<ReviewModel> reviews = [];

  update() {
    notifyListeners();
  }

  bool isLoading = false;
  startLoader() {
    isLoading = true;
    notifyListeners();
  }

  stopLoader() {
    isLoading = false;
    notifyListeners();
  }

  List<UserModel> allUsers=[];
  StreamSubscription<List<UserModel>>? userFavouritesStream;
  Future<void> fetchAllUsers()
  async {
    try {
      var ref = FbCollections.user.where("status",isEqualTo:UserStatus.active.index).snapshots().asBroadcastStream();
      var res = ref.map((list) => list.docs.map((e) => UserModel.fromJson(e.data())).toList());
      userFavouritesStream ??= res.listen((user) async {
        allUsers = user;
        notifyListeners();
      });
    } on Exception catch (e) {
      debugPrintStack();
      log(e.toString());
    }
    notifyListeners();
  }
   fetchData()
   async {
     var yachtVm=Provider.of<YachtVm>(Get.context!,listen: false);
     var bookingsVm=Provider.of<BookingsVm>(Get.context!,listen: false);
     var homeVm=Provider.of<HomeVm>(Get.context!,listen: false);
     var inboxVm=Provider.of<InboxVm>(Get.context!,listen: false);
     var settingsVm=Provider.of<SettingsVm>(Get.context!,listen: false);
     await Future.wait([
     bookingsVm.fetchTaxes(),
     yachtVm.fetchCharterOffers(),
    fetchAllUsers(),
     bookingsVm.fetchAppUrls(),
     settingsVm.fetchContent(),
     yachtVm.fetchServices(),
     yachtVm.fetchUserFavourites(),
     yachtVm.fetchYachts(),
     homeVm.fetchAllBookings(),
     inboxVm.fetchNotificatoins(),

     ]);
   }

}
