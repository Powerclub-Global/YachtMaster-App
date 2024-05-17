import 'dart:async';
import 'dart:developer';

import 'package:async_foreach/async_foreach.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../appwrite.dart';
import '../../../../constant/constant.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/update_locale.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../../../auth/model/user_model.dart';
import '../../profile/model/review_model.dart';
import '../model/content_model.dart';
import '../model/payment_payouts_model.dart';
import '../../yacht/view_model/yacht_vm.dart';

class SettingsVm extends ChangeNotifier {
  bool isLoading = false;
  UpdateLocale lang = UpdateLocale();

  int selectedLang = 0;

  List<ReviewModel> allReviews = [];
  List<ContentModel> allContent = [];

  List<ReviewModel> hostReviews = [];
  StreamSubscription<List<ReviewModel>>? reviewStream;

  onChangeLang(String langCode, BuildContext context) {
    lang.language(langCode, context).then((value) => notifyListeners());
  }

  startLoader() {
    isLoading = true;
    notifyListeners();
  }

  stopLoader() {
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchContent() async {
    log("/////////////////////IN FETCH CONTENT");
    try {
      allContent = [];
      QuerySnapshot snapshot = await FbCollections.content.get();
      if (snapshot.docs.isNotEmpty) {
        allContent =
            snapshot.docs.map((e) => ContentModel.fromJson(e.data())).toList();
        notifyListeners();
      }
      log("__________ Data ${allContent.length}");
    } catch (e) {
      debugPrintStack();
      log(e.toString());
    }
  }

  fetchReviews(List<UserModel>? hosts) async {
    try {
      var yachtVm = Provider.of<YachtVm>(Get.context!, listen: false);

      log("/////////////////////IN FETCH REVIEWS:${hosts?.length}");
      allReviews = [];
      hostReviews = [];

      notifyListeners();
      var ref = FbCollections.bookingReviews
          .orderBy("rating", descending: true)
          .snapshots()
          .asBroadcastStream();
      var res = ref.map((list) =>
          list.docs.map((e) => ReviewModel.fromJson(e.data())).toList());
      reviewStream ??= res.listen((reviews) async {
        if (reviews.isNotEmpty) {
          allReviews = reviews;
          hostReviews = reviews
              .where((element) =>
                  element.hostId == appwrite.user.$id)
              .toList();
          await reviews.asyncForEach((element) async {
            log(")))))))))))))))))HOSTS:${hosts?.length}");
            var doc = await FbCollections.user.doc(element.hostId).get();
            UserModel featuredHost = UserModel.fromJson(doc.data());
            featuredHost.rating = element.rating;
            notifyListeners();
            hosts?.forEach((hostEl) {
              if (hostEl.uid == featuredHost.uid) {
                hosts[hosts.indexOf(hostEl)] = featuredHost;
              }
              // hosts?[hosts.indexWhere((hostEl) => hostEl.uid==featuredHost.uid)]=featuredHost;
            });
          });
          notifyListeners();
          log(")))))))))))))))))HOSTS AFTER:${hosts?.length}");

          hosts?.sort((a, b) => b.rating!.compareTo(a.rating!));
          notifyListeners();
          // hosts?.forEach((element) {
          //   log("_____${element.uid}=====${appwrite.user.$id}");
          //   if(element.uid!=appwrite.user.$id)
          //     {
          //       yachtVm.allHosts.add(element);
          //     }
          //   // element.uid!=appwrite.user.$id;
          // });
          yachtVm.allHosts = List.from(hosts?.toList() ?? []);
          notifyListeners();
          log("________FEATURED HOST:${yachtVm.allHosts.length}");
          await yachtVm.sortHostsByBookings();
        }
        log("//////////////////////All Reviews :${allReviews.length}/////host reviews :${hostReviews.length}____FEATURED HOST:${yachtVm.allHosts.length}");
        notifyListeners();
      });
      notifyListeners();
    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log(e.toString());
    }
  }

  averageRating(List<ReviewModel> reviews) {
    double sumRating = 0;
    for (var i = 0; i < reviews.length; i++) {
      sumRating += reviews[i].rating;
    }
    var average = (sumRating / reviews.length); // This is average
    update();
    return average;
  }

  update() {
    notifyListeners();
  }
}
