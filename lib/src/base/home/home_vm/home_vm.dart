import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/firebase_collections.dart';
import '../../../auth/view_model/auth_vm.dart';
import '../../search/view/bookings/model/bookings.dart';

class HomeVm extends ChangeNotifier {
  List<BookingsModel> allBookings = [];
  List walletHistory = [];
  StreamSubscription<List<BookingsModel>>? bookingsStream;
  Future<void> fetchAllBookings() async {
    allBookings = [];
    try {
      var ref = FbCollections.bookings.snapshots().asBroadcastStream();

      var res = ref.map((list) {
        return list.docs.map((e) {
          return BookingsModel.fromJson(e.data());
        }).toList();
      });
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

  Future<void> fetchWalletHistory(BuildContext context) async {
    walletHistory = [];
    var authVm = Provider.of<AuthVm>(context, listen: false);
    var fetchHistory = await FbCollections.wallet_history
        .where('uid', isEqualTo: authVm.userModel!.uid)
        .get();
    walletHistory = fetchHistory.docs
        .map((e) => e.data() as Map<String, dynamic>)
        .toList();
  }

  update() {
    notifyListeners();
  }

  @override
  void dispose() {
    bookingsStream?.cancel();
    bookingsStream = null;
    super.dispose();
  }
}
