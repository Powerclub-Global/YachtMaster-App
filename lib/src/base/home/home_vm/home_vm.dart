import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';

class HomeVm extends ChangeNotifier {
  List<BookingsModel> allBookings = [];
  StreamSubscription<List<BookingsModel>>? bookingsStream;
  Future<void> fetchAllBookings() async {
    print("=============== Starting to fetch all bookings =================");
    allBookings = [];
    try {
      var ref = FbCollections.bookings.snapshots().asBroadcastStream();
      var bookingsData = await FbCollections.bookings.get();
      print(allBookings);
      var res = ref.map((list) =>
          list.docs.map((e) => BookingsModel.fromJson(e.data())).toList());
      bookingsStream ??= res.listen((bookings) async {
        if (bookings.isNotEmpty) {
          allBookings = bookings;
          notifyListeners();
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

  update() {
    notifyListeners();
  }
}
