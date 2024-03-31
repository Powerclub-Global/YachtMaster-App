import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/resources/resources.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view/widgets/feedback_data_grid_source.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view/widgets/feedback_grid.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view_model/feedback_vm.dart';

import 'package:yacht_master_admin/utils/text_size.dart';
import 'package:yacht_master_admin/utils/widgets/global_functions.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({Key? key}) : super(key: key);

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  FocusNode searchFocus = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ZBotToast.loadingShow();
      await context.read<FeedbackVm>().getAllFeedback();
      ZBotToast.loadingClose();
      reportsDataGridSource = ReportsDataGridSource(isWebOrDesktop: true);
      Get.forceAppUpdate();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedbackVm>(builder: (context, vm, _) {
      return Scaffold(
        backgroundColor: R.colors.transparent,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.sp, vertical: 3.sp),
          decoration: BoxDecoration(
            color: R.colors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Flexible(
                child: (vm.selectedIndex == 0
                    &&
                    vm.feedbacList
                        // .where((element) =>
                    // element.createdForUser!.fullName.toString().isCaseInsensitiveContains(vm.searchController.text) || element.createdByUser!.fullName.toString().isCaseInsensitiveContains(vm.searchController.text))
                        .isEmpty
                ) ||
                    (vm.selectedIndex != 0 )
                    ? Center(
                        child: Text(
                          LocalizationMap.getTranslatedValues("no_data"),
                          style: R.textStyles.poppins(),
                        ),
                      )
                    : const ReportsGrid(),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget searchField(FeedbackVm vm) {
    return TextFormField(
      focusNode: searchFocus,
      onTap: () {
        setState(() {});
      },
      onChanged: (s) {
        setState(() {});
        Get.forceAppUpdate();
      },
      style: R.textStyles.poppins(
        color: R.colors.offWhite,
        fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 15),
        fw: FontWeight.w300,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: vm.searchController,
      decoration: R.decoration.fieldDecoration(
          hintText: "search",
          preIcon: Icon(
            Icons.search,
            size: 15,
            color: R.colors.hintTextColor,
          )),
    );
  }

  Widget filterStatusButton({required String name, required int index, required FeedbackVm vm}) {
    return InkWell(
      onTap: () {
        setState(() {
          vm.selectedIndex = index;
          debugPrint(vm.selectedIndex.toString());
          reportsDataGridSource = ReportsDataGridSource(isWebOrDesktop: true);
          Get.forceAppUpdate();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.only(top: 5, bottom: 12, right: 10),
        decoration: BoxDecoration(
          color: vm.selectedIndex == index ? R.colors.secondary : R.colors.hintTextColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          LocalizationMap.getTranslatedValues(name),
          style: R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15), color: R.colors.white),
        ),
      ),
    );
  }
}
