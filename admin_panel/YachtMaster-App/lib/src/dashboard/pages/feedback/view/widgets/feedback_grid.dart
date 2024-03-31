// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/resources/resources.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view/widgets/feedback_data_grid_source.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view_model/feedback_vm.dart';
import 'package:yacht_master_admin/utils/syncfusion_data_grid/sample_view.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:yacht_master_admin/utils/text_size.dart';

late ReportsDataGridSource reportsDataGridSource;

class ReportsGrid extends SampleView {
  const ReportsGrid({Key? key}) : super(key: key);

  @override
  ReportsGridState createState() => ReportsGridState();
}

class ReportsGridState extends SampleViewState {
  static const double dataPagerHeight = 60;
  int _rowsPerPage = 10;
  bool isWebOrDesktop = true;

  @override
  void initState() {
    reportsDataGridSource =
        ReportsDataGridSource(isWebOrDesktop: isWebOrDesktop);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FeedbackVm vm = Provider.of<FeedbackVm>(context, listen: false);
      vm.searchController.addListener(() {
        debugPrint(vm.searchController.text);
        reportsDataGridSource = ReportsDataGridSource(isWebOrDesktop: isWebOrDesktop);
        vm.update();
      });
    });
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
        source: reportsDataGridSource,
        rowsPerPage: _rowsPerPage,
        allowSorting: true,
        isScrollbarAlwaysShown: false,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columns: <GridColumn>[
          _gridColumn(columnName: 'sr_no', width: 90),
          _gridColumn(columnName: 'picture', width: 160),
          _gridColumn(columnName: 'user_name', width: 160),
          _gridColumn(columnName: 'description', width: 160),
          _gridColumn(columnName: 'created_date', width: 160),
          // _gridColumn(columnName: 'status', width: 160),
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
        delegate: reportsDataGridSource,
        availableRowsPerPage: const <int>[10, 20, 25],
        visibleItemsCount: 5,
        pageCount:
        (reportsDataGridSource.tickets.length / _rowsPerPage).ceilToDouble(),
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