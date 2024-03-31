import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../constants/fb_collections.dart';
import '../model/bookings_model.dart';
import '../model/taxes_model.dart';

class BookingsVm extends ChangeNotifier{
  List<BookingsModel> allBookings=[];
  int serviceFee = 0;
  int taxes = 0;
  int tips = 0;
  int selectedIndex = 0;
  double referralAmount = 0.0;

  Future<void> fetchAllBookings() async {
    allBookings=[];
    try {
      QuerySnapshot ref =await FBCollections.bookings.get();

      if (ref!=null && ref.docs.isNotEmpty) {
        allBookings = ref.docs.map((e) => BookingsModel.fromJson(e.data())).toList();
        notifyListeners();
      }
      log("___bookings:${allBookings.length}");

      notifyListeners();
    } on Exception catch (e) {
      debugPrintStack();
      log(e.toString());
    }
  }

  Future<void> fetchTaxes() async {
    log("/////////////////////IN FETCH Taxes");
    try {
      TaxesModel? taxesModel;
      QuerySnapshot snapshot = await FBCollections.taxes.get();
      if (snapshot.docs.isNotEmpty) {

        taxesModel = TaxesModel.fromJson(snapshot.docs.first.data());
        serviceFee = taxesModel.serviceFee ?? 0;
        taxes = taxesModel.taxes ?? 0;
        tips = taxesModel.tip ?? 0;
        referralAmount = taxesModel.referralAmount ?? 0.0;
        notifyListeners();
      }
      log("__________TAXES Data ${taxesModel?.taxes}");
    } catch (e) {
      log(e.toString());
    }
  }

  update(){
    notifyListeners();
  }
}