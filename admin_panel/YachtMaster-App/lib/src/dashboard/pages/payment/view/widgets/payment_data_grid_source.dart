import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yacht_master_admin/constants/enums.dart';
import 'package:yacht_master_admin/constants/fb_collections.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/model/bookings_model.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view/widgets/booking_dialogue.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view/widgets/booking_grid.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/payment/view/widgets/payment_dialogue.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';
import 'package:yacht_master_admin/utils/widgets/global_functions.dart';
import '../../../../../../resources/resources.dart';
import '../../../../../../utils/syncfusion_data_grid/sample_model.dart';
import '../../../../../../utils/text_size.dart';


/// Set order's data collection to data grid source.
class PaymentDataGridSource extends DataGridSource {
  /// Creates the order data source class with required details.
  PaymentDataGridSource({this.model, required this.isWebOrDesktop}) {
    var vm = Provider.of<BookingsVm>(Get.context!, listen: false);
    tickets = getLists();

    buildDataGridRows(vm);
  }

  /// Determine to decide whether the platform is web or desktop.
  final bool isWebOrDesktop;

  /// Instance of SampleModel.
  final SampleModel? model;

  /// Instance of an order.
  List<BookingsModel> tickets = <BookingsModel>[];

  /// Instance of DataGridRow.
  List<DataGridRow> dataGridRows = <DataGridRow>[];

  /// Building DataGridRows
  void buildDataGridRows(BookingsVm vm) {
    if (vm.selectedIndex == 2) {
      dataGridRows = tickets.toList()
          .map<DataGridRow>((BookingsModel model) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<BookingsModel>(columnName: 'sr_no', value: model),
          DataGridCell<BookingsModel>(columnName: 'booked_by', value: model),
          DataGridCell<BookingsModel>(columnName: 'charter_owner', value: model),
          DataGridCell<BookingsModel>(columnName: 'info', value: model),
          DataGridCell<BookingsModel>(columnName: 'created_at', value: model),
          DataGridCell<BookingsModel>(columnName: 'status', value: model),
          // DataGridCell<BookingsModel>(columnName: 'action', value: model),
        ]);
      }).toList();
    } else {
      dataGridRows = tickets
          .where((element) =>element.paymentDetail?.paymentStatus == GlobalFunctions.getPaymentStatus(selectedIndex: vm.selectedIndex))
          .toList()
          .map<DataGridRow>((BookingsModel model) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<BookingsModel>(columnName: 'sr_no', value: model),
          DataGridCell<BookingsModel>(columnName: 'booked_by', value: model),
          DataGridCell<BookingsModel>(columnName: 'charter_owner', value: model),
          DataGridCell<BookingsModel>(columnName: 'info', value: model),
          DataGridCell<BookingsModel>(columnName: 'created_at', value: model),
          DataGridCell<BookingsModel>(columnName: 'status', value: model),
          // DataGridCell<BookingsModel>(columnName: 'action', value: model),
        ]);
      }).toList();
    }
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int rowIndex = dataGridRows.indexOf(row);
    Color backgroundColor = R.colors.greyBlack;
    // if (model != null && (rowIndex % 2) == 0) {
    //   backgroundColor = model!.backgroundColor.withOpacity(0.07);
    // }
    if (isWebOrDesktop) {
      BookingsModel model = row.getCells()[0].value;
      DateTime now = DateTime.now();
      var vm = Provider.of<UserVM>(Get.context!, listen: false);
      return DataGridRowAdapter(color: backgroundColor, cells: <Widget>[
        /// Serial Number
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(
            "${rowIndex + 1}",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style:
                R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 12), fw: FontWeight.w500),
          ),
        ),

        /// Picture
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: Text(
            Provider.of<UserVM>(Get.context!,listen: false).userList.firstWhereOrNull((element) => element.uid==model.createdBy)?.firstName??"",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: R.textStyles.poppins(
                fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 12),
                color: R.colors.secondary,
                fw: FontWeight.w600),
          ),
        ),

        /// Name
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: Text(
          Provider.of<UserVM>(Get.context!,listen: false).userList.firstWhereOrNull((element) => element.uid==model.hostUserUid)?.firstName??"",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: R.textStyles.poppins(
                fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 12),
                color: R.colors.secondary,
                fw: FontWeight.w600),
          ),
        ),

        /// Description
        InkWell(
          onTap: () {
            Get.dialog(PaymentDialogue(
              model: model,
            ));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Icon(
              Icons.info,
              color: R.colors.white,
            ),
          ),
        ),


        // /// Total Friends
        // Container(
        //   padding: const EdgeInsets.all(8),
        //   alignment: Alignment.center,
        //   child: Text(
        //      "0",
        //     overflow: TextOverflow.ellipsis,
        //     textAlign: TextAlign.left,
        //     style:
        //         R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 12), fw: FontWeight.w500),
        //   ),
        // ),
        //
        // /// Groups Joined
        // Container(
        //   padding: const EdgeInsets.all(8),
        //   alignment: Alignment.center,
        //   child: Text(
        //     "0",
        //     overflow: TextOverflow.ellipsis,
        //     textAlign: TextAlign.left,
        //     style:
        //         R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 12), fw: FontWeight.w500),
        //   ),
        // ),

        /// Created At
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: Text(
            GlobalFunctions.getDateTime(model.createdAt?.toDate() ?? now),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style:
                R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 12), fw: FontWeight.w500),
          ),
        ),

        /// Status
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 2.sp, vertical: 1.sp),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
              model.paymentDetail?.paymentStatus == PaymentPayoutsStatus.pending.index ? R.colors.yellowDark :
              R.colors.greenButton,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              model.paymentDetail?.paymentStatus == PaymentPayoutsStatus.pending.index
                  ? LocalizationMap.getTranslatedValues("pending") : LocalizationMap.getTranslatedValues("paid"),
              style: R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 11)),
            ),
          ),
        ),

        // /// Action
        // PopupMenuButton(
        //   offset: const Offset(-40, 45),
        //   child: Container(
        //     margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        //     height: 6.sp,
        //     width: 6.sp,
        //     decoration: BoxDecoration(
        //       color: R.colors.offWhite,
        //       borderRadius: BorderRadius.circular(6),
        //     ),
        //     child: Icon(
        //       Icons.more_horiz,
        //       color: R.colors.black,
        //     ),
        //   ),
        //   onSelected: (val) async {
        //     ZBotToast.loadingShow();
        //     switch (val) {
        //       case 0:
        //         model.bookingStatus=BookingStatus.ongoing.index;
        //         await updateStatus(model.id ?? "", 0);
        //         break;
        //       case 1:
        //         model.bookingStatus=BookingStatus.completed.index;
        //         await updateStatus(model.id ?? "", 1);
        //         break;
        //       case 2:
        //         model.bookingStatus=BookingStatus.cancelled.index;
        //         await updateStatus(model.id ?? "", 2);
        //         break;
        //     }
        //     await vm.getAllUsers();
        //     ZBotToast.loadingClose();
        //     bookingGridSource = BookinsgDataGridSource(isWebOrDesktop: isWebOrDesktop);
        //     Get.forceAppUpdate();
        //   },
        //   itemBuilder: (context){
        //     return List.generate(3, (index) {
        //       return GlobalWidgets.popupMenuItem(
        //           index,BookingStatus.values[index].name,isShow: model.bookingStatus!=index);
        //     }
        //     );
        //   }
        // ),
      ]);
    }
    else {
      Widget buildWidget({
        AlignmentGeometry alignment = Alignment.center,
        EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
        TextOverflow textOverflow = TextOverflow.ellipsis,
        required Object value,
      }) {
        return Container(
          padding: padding,
          alignment: alignment,
          child: Text(
            value.toString(),
            overflow: textOverflow,
          ),
        );
      }

      return DataGridRowAdapter(
          color: backgroundColor,
          cells: row.getCells().map<Widget>((DataGridCell dataCell) {
            if (dataCell.columnName == 'id' || dataCell.columnName == 'UserId') {
              return buildWidget(alignment: Alignment.centerRight, value: dataCell.value!);
            } else {
              return buildWidget(value: dataCell.value!);
            }
          }).toList(growable: false));
    }
  }

  @override
  Future<void> handleLoadMoreRows() async {
    var vm = Provider.of<BookingsVm>(Get.context!, listen: false);
    await Future<void>.delayed(const Duration(seconds: 5));
    tickets = getLists();
    buildDataGridRows(vm);
    notifyListeners();
  }

  @override
  Future<void> handleRefresh() async {
    var vm = Provider.of<BookingsVm>(Get.context!, listen: false);
    await Future<void>.delayed(const Duration(seconds: 5));
    tickets = getLists();
    buildDataGridRows(vm);
    notifyListeners();
  }

  @override
  Widget? buildTableSummaryCellWidget(GridTableSummaryRow summaryRow, GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex, String summaryValue) {
    Widget buildCell(String value, EdgeInsets padding, Alignment alignment) {
      return Container(
        padding: padding,
        alignment: alignment,
        child: Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      );
    }

    if (summaryRow.showSummaryInRow) {
      return buildCell(summaryValue, const EdgeInsets.all(16.0), Alignment.centerLeft);
    } else if (summaryValue.isNotEmpty) {
      if (summaryColumn!.columnName == 'freight') {
        summaryValue = double.parse(summaryValue).toStringAsFixed(2);
      }

      summaryValue =
          'Sum: ${NumberFormat.currency(locale: 'en_US', decimalDigits: 0, symbol: r'$').format(double.parse(summaryValue))}';

      return buildCell(summaryValue, const EdgeInsets.all(8.0), Alignment.centerRight);
    }
    return null;
  }

  List<BookingsModel> getLists() {
    return Provider.of<BookingsVm>(Get.context!, listen: false).allBookings;
  }

  Future<void> updateStatus(String id, int status) async {
    try {
      await FBCollections.bookings.doc(id).update({"booking_status": status});
    } catch (e) {
      debugPrintStack();
    }
  }

}
