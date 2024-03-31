///Package imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
/// Core theme import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view/widgets/booking_data_grid_source.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view/widgets/user_data_grid_source.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';

import '../../../../../../resources/localization/localization_map.dart';
import '../../../../../../resources/resources.dart';
import '../../../../../../utils/syncfusion_data_grid/sample_view.dart';
import '../../../../../../utils/text_size.dart';

late UserDataGridSource userDataSource;

class UserGrid extends SampleView {
  const UserGrid({Key? key}) : super(key: key);

  @override
  UserGridState createState() => UserGridState();
}

class UserGridState extends SampleViewState {
  static const double dataPagerHeight = 60;
  int _rowsPerPage = 10;
  bool isWebOrDesktop = true;

  @override
  void initState() {
    userDataSource =
        UserDataGridSource(isWebOrDesktop: isWebOrDesktop);
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget _buildDataGrid() {
    return SfDataGridTheme(
      data: SfDataGridThemeData(
        headerColor: R.colors.greyBlack,
        gridLineColor: R.colors.offWhite,
        rowHoverColor: R.colors.secondary.withOpacity(0.1),
        sortIcon: Icon(
          Icons.sort,
          color: R.colors.offWhite,
        ),
      ),
      child: SfDataGrid(
        headerRowHeight: 56,
        source: userDataSource,
        rowsPerPage: _rowsPerPage,
        allowSorting: true,
        isScrollbarAlwaysShown: false,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columns: <GridColumn>[
          _gridColumn(columnName: 'sr_no', width: 90),
          _gridColumn(columnName: 'picture', width: 120),
          _gridColumn(columnName: 'name', width: 160),
          _gridColumn(columnName: 'description', width: 160),
          // _gridColumn(columnName: 'email_caps', width: 200),
          // _gridColumn(columnName: 'phone_number', width: 200),
          // _gridColumn(columnName: 'total_friends', width: 160),
          // _gridColumn(columnName: 'groups_joined', width: 160),
          _gridColumn(columnName: 'created_at', width: 160),
          _gridColumn(columnName: 'status', width: 100),
          _gridColumn(columnName: 'action', width: 100),
        ],
      ),
    );
  }

  GridColumn _gridColumn(
      {double? width,
      required String columnName,
      AlignmentGeometry? alignment}) {
    return GridColumn(
      width: width ?? 100,
      autoFitPadding: const EdgeInsets.all(8),
      columnName: LocalizationMap.getTranslatedValues(columnName),
      label: Container(
        padding: const EdgeInsets.all(8),
        alignment: alignment ?? Alignment.centerLeft,
        child: Text(
          LocalizationMap.getTranslatedValues(columnName),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: R.textStyles.poppins(
              fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15)),
        ),
      ),
    );
  }

  Widget _buildDataPager() {
    return SfDataPagerTheme(
      data: SfDataPagerThemeData(
          itemColor: R.colors.primary,
          selectedItemColor: R.colors.primary,
          backgroundColor: R.colors.greyBlack,
          disabledItemColor: R.colors.primary.withOpacity(0.5),
          itemBorderColor: R.colors.greyBlack,
          dropdownButtonBorderColor: R.colors.primary,
          itemTextStyle: R.textStyles.poppins(color: R.colors.greyColor),
          disabledItemTextStyle: R.textStyles.poppins(color: R.colors.white),
          selectedItemTextStyle: R.textStyles.poppins(color: R.colors.white)),
      child: SfDataPager(
        direction: Axis.horizontal,
        delegate: userDataSource,
        availableRowsPerPage: const <int>[10, 20, 25],
        visibleItemsCount: 5,
        pageCount:
            (userDataSource.tickets.length / _rowsPerPage).ceilToDouble(),
        onRowsPerPageChanged: (int? rowsPerPage) {
          setState(() {
            _rowsPerPage = rowsPerPage!;
          });
        },
      ),
    );
  }

  Widget _buildLayoutBuilder() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
      return Column(
        children: [
          SizedBox(
            height: constraint.maxHeight - dataPagerHeight,
            width: constraint.maxWidth,
            child: _buildDataGrid(),
          ),
          Container(
            height: dataPagerHeight,
            decoration: BoxDecoration(
              color: R.colors.greyBlack,
            ),
            child: Align(alignment: Alignment.center, child: _buildDataPager()),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayoutBuilder();
  }
}
