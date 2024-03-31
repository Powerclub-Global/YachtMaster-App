import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yacht_master_admin/constants/enums.dart';
import 'package:yacht_master_admin/constants/fb_collections.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/resources/resources.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/model/reports_data.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view/widgets/feedback_dialogue.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view_model/feedback_vm.dart';
import 'package:yacht_master_admin/utils/syncfusion_data_grid/sample_model.dart';
import 'package:yacht_master_admin/utils/text_size.dart';
import 'package:yacht_master_admin/utils/widgets/global_functions.dart';

import '../../../../../../utils/widgets/show_image.dart';

class ReportsDataGridSource extends DataGridSource {
  /// Creates the order data source class with required details.
  ReportsDataGridSource({this.model, required this.isWebOrDesktop}) {
    var vm = Provider.of<FeedbackVm>(Get.context!, listen: false);
    tickets = getLists();

    buildDataGridRows(vm);
  }

  /// Determine to decide whether the platform is web or desktop.
  final bool isWebOrDesktop;

  /// Instance of SampleModel.
  final SampleModel? model;

  /// Instance of an order.
  List<AppFeedbackModel> tickets = <AppFeedbackModel>[];

  /// Instance of DataGridRow.
  List<DataGridRow> dataGridRows = <DataGridRow>[];

  /// Building DataGridRows
  void buildDataGridRows(FeedbackVm vm) {
    if (vm.selectedIndex == 0) {
      dataGridRows = tickets
          // .where((element) => element.createdForUser!.fullName.toString().isCaseInsensitiveContains(vm.searchController.text) || element.createdByUser!.fullName.toString().isCaseInsensitiveContains(vm.searchController.text))
          .toList()
          .map<DataGridRow>((AppFeedbackModel model) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<AppFeedbackModel>(columnName: 'sr_no', value: model),
          DataGridCell<AppFeedbackModel>(columnName: 'picture', value: model),
          DataGridCell<AppFeedbackModel>(columnName: 'user_name', value: model),
          DataGridCell<AppFeedbackModel>(columnName: 'description', value: model),
          DataGridCell<AppFeedbackModel>(columnName: 'created_date', value: model),
          // DataGridCell<AppFeedbackModel>(columnName: 'status', value: model),
        ]);
      }).toList();
    } else {
      dataGridRows = tickets
          // .where((element) => element.createdForUser!.fullName.toString().isCaseInsensitiveContains(vm.searchController.text) || element.createdByUser!.fullName.toString().isCaseInsensitiveContains(vm.searchController.text))
          // .where((element) => element.status == GlobalFunctions.getReportStatus(selectedIndex: vm.selectedIndex))
          .toList()
          .map<DataGridRow>((AppFeedbackModel model) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<AppFeedbackModel>(columnName: 'sr_no', value: model),
          DataGridCell<AppFeedbackModel>(columnName: 'picture', value: model),
          DataGridCell<AppFeedbackModel>(columnName: 'user_name', value: model),
          DataGridCell<AppFeedbackModel>(columnName: 'description', value: model),
          DataGridCell<AppFeedbackModel>(columnName: 'created_date', value: model),
          // DataGridCell<AppFeedbackModel>(columnName: 'status', value: model),
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
      AppFeedbackModel model = row.getCells()[0].value;


      DateTime now = DateTime.now();
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

        /// Created by
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: SizedBox(
              height: 30,
              width: 30,
              child: DisplayImage.showImage(
                model.pricture,
              ),
            ),
          ),
        ),

        /// Created for
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: Text(
            model.userName ?? "",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style:
                R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 12), fw: FontWeight.w500),
          ),
        ),

        /// Description
        InkWell(
          onTap: () {
            Get.dialog(FeedBackDetailDialogue(
              model: model,
            ));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Icon(
              Icons.visibility,
              color: R.colors.white,
            ),
          ),
        ),

        /// Reported At
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

        // /// Status
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Container(
        //     alignment: Alignment.center,
        //     padding: EdgeInsets.symmetric(horizontal: 2.sp, vertical: 1.sp),
        //     margin: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color:
        //       // model.status == ReportStatusType.pending ? R.colors.pinkRed :
        //       R.colors.greenButton,
        //       borderRadius: BorderRadius.circular(6),
        //     ),
        //     child: Text(
        //       model.status == ReportStatusType.pending
        //           ? LocalizationMap.getTranslatedValues("pending")
        //           : LocalizationMap.getTranslatedValues("completed"),
        //       style: R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 11)),
        //     ),
        //   ),
        // ),
      ]);
    } else {
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
    var vm = Provider.of<FeedbackVm>(Get.context!, listen: false);
    await Future<void>.delayed(const Duration(seconds: 5));
    tickets = getLists();
    buildDataGridRows(vm);
    notifyListeners();
  }

  @override
  Future<void> handleRefresh() async {
    var vm = Provider.of<FeedbackVm>(Get.context!, listen: false);
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

  List<AppFeedbackModel> getLists() {
    return Provider.of<FeedbackVm>(Get.context!, listen: false).feedbacList;
  }

  Future<void> updateStatus(String id, int status) async {
    try {
      await FBCollections.users.doc(id).update({"status": status});
    } catch (e) {
      debugPrintStack();
    }
  }
}
