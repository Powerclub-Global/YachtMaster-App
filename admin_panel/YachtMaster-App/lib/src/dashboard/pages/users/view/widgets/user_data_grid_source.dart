import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yacht_master_admin/constants/enums.dart';
import 'package:yacht_master_admin/constants/fb_collections.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/model/reports_data.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view/widgets/user_dialogue.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view/widgets/user_grid.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';
import 'package:yacht_master_admin/utils/widgets/global_functions.dart';
import 'package:yacht_master_admin/utils/widgets/global_widgets.dart';
import 'package:yacht_master_admin/utils/widgets/show_image.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';
import '../../../../../../resources/resources.dart';
import '../../../../../../utils/syncfusion_data_grid/sample_model.dart';
import '../../../../../../utils/text_size.dart';
import '../../../feedback/view/widgets/feedback_dialogue.dart';
import '../../model/user_data.dart';

/// Set order's data collection to data grid source.
class UserDataGridSource extends DataGridSource {
  /// Creates the order data source class with required details.
  UserDataGridSource({this.model, required this.isWebOrDesktop}) {
    var vm = Provider.of<UserVM>(Get.context!, listen: false);
    tickets = getLists();

    buildDataGridRows(vm);
  }

  /// Determine to decide whether the platform is web or desktop.
  final bool isWebOrDesktop;

  /// Instance of SampleModel.
  final SampleModel? model;

  /// Instance of an order.
  List<UserModel> tickets = <UserModel>[];

  /// Instance of DataGridRow.
  List<DataGridRow> dataGridRows = <DataGridRow>[];

  /// Building DataGridRows
  void buildDataGridRows(UserVM vm) {
    if (vm.selectedIndex == 0) {
      dataGridRows = tickets
          .where((element) => element.firstName.toString().isCaseInsensitiveContains(vm.searchController.text))
          .toList()
          .map<DataGridRow>((UserModel model) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<UserModel>(columnName: 'sr_no', value: model),
          DataGridCell<UserModel>(columnName: 'picture', value: model),
          DataGridCell<UserModel>(columnName: 'name', value: model),
          DataGridCell<UserModel>(columnName: 'description', value: model),
          // DataGridCell<UserModel>(columnName: 'email_caps', value: model),
          // DataGridCell<UserModel>(columnName: 'phone_number', value: model),
          // DataGridCell<UserModel>(columnName: 'total_friends', value: model),
          // DataGridCell<UserModel>(columnName: 'groups_joined', value: model),
          DataGridCell<UserModel>(columnName: 'created_at', value: model),
          DataGridCell<UserModel>(columnName: 'status', value: model),
          DataGridCell<UserModel>(columnName: 'action', value: model),
        ]);
      }).toList();
    } else {
      dataGridRows = tickets
          .where((element) => element.firstName.toString().isCaseInsensitiveContains(vm.searchController.text))
          .where((element) => element.status == GlobalFunctions.getUserStatus(selectedIndex: vm.selectedIndex))
          .toList()
          .map<DataGridRow>((UserModel model) {
        return DataGridRow(cells: <DataGridCell>[
          DataGridCell<UserModel>(columnName: 'sr_no', value: model),
          DataGridCell<UserModel>(columnName: 'picture', value: model),
          DataGridCell<UserModel>(columnName: 'name', value: model),
          DataGridCell<UserModel>(columnName: 'description', value: model),
          // DataGridCell<UserModel>(columnName: 'email_caps', value: model),
          // DataGridCell<UserModel>(columnName: 'phone_number', value: model),
          // DataGridCell<UserModel>(columnName: 'total_friends', value: model),
          // DataGridCell<UserModel>(columnName: 'groups_joined', value: model),
          DataGridCell<UserModel>(columnName: 'created_at', value: model),
          DataGridCell<UserModel>(columnName: 'status', value: model),
          DataGridCell<UserModel>(columnName: 'action', value: model),
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
      UserModel model = row.getCells()[0].value;
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
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: SizedBox(
              height: 30,
              width: 30,
              child: DisplayImage.showImage(
                model.imageUrl ?? "",
              ),
            ),
          ),
        ),

        /// Name
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: Text(
            model.firstName ?? "",
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
            Get.dialog(UserDialogue(
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
              model.status == UserStatus.active ? R.colors.greenButton :
              R.colors.pinkRed,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              model.status == UserStatus.active
                  ? LocalizationMap.getTranslatedValues("active")
                  :
              LocalizationMap.getTranslatedValues("block"),
              style: R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 11)),
            ),
          ),
        ),

        /// Action
        PopupMenuButton(
          offset: const Offset(-40, 45),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
            height: 6.sp,
            width: 6.sp,
            decoration: BoxDecoration(
              color: R.colors.offWhite,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.more_horiz,
              color: R.colors.black,
            ),
          ),
          onSelected: (val) async {
            ZBotToast.loadingShow();
            switch (val) {
              case 0:
                model.status=UserStatus.active;
                await updateStatus(model.uid ?? "", UserStatus.active);
                break;
              case 1:
                model.status=UserStatus.blocked;
                await updateStatus(model.uid ?? "", UserStatus.blocked);
                break;
            }
            await vm.getAllUsers();
            ZBotToast.loadingClose();
            userDataSource = UserDataGridSource(isWebOrDesktop: isWebOrDesktop);
            Get.forceAppUpdate();
          },
          itemBuilder: (context) => <PopupMenuItem>[
            if (model.status != UserStatus.active)
              GlobalWidgets.popupMenuItem(0, "active")
            else
              GlobalWidgets.popupMenuItem(1, "block")
          ],
        ),
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
    var vm = Provider.of<UserVM>(Get.context!, listen: false);
    await Future<void>.delayed(const Duration(seconds: 5));
    tickets = getLists();
    buildDataGridRows(vm);
    notifyListeners();
  }

  @override
  Future<void> handleRefresh() async {
    var vm = Provider.of<UserVM>(Get.context!, listen: false);
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

  List<UserModel> getLists() {
    return Provider.of<UserVM>(Get.context!, listen: false).userList;
  }

  Future<void> updateStatus(String id, UserStatus status) async {
    try {
      await FBCollections.users.doc(id).update({"status": status.index});
    } catch (e) {
      debugPrintStack();
    }
  }
}
