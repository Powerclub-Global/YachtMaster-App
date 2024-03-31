import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/constants/enums.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view/widgets/user_data_grid_source.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view/widgets/user_grid.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';
import 'package:yacht_master_admin/utils/widgets/global_functions.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';
import '../../../../../resources/resources.dart';
import '../../../../../utils/text_size.dart';

class UserView extends StatefulWidget {
  const UserView({Key? key}) : super(key: key);

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  FocusNode searchFocus = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var vm = Provider.of<UserVM>(context, listen: false);
      ZBotToast.loadingShow();
      await vm.getAllUsers();
      ZBotToast.loadingClose();
      userDataSource = UserDataGridSource(isWebOrDesktop: true);
      Get.forceAppUpdate();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserVM>(builder: (context, vm, _) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  filterStatusButton(name: 'all', index: 0, vm: vm),
                  filterStatusButton(name: 'active', index: 1, vm: vm),
                  filterStatusButton(name: 'block', index: 2, vm: vm),
                  const Spacer(),
                  SizedBox(
                    height: 35,
                    width: 52.sp,
                    child: Center(child: searchField(vm)),
                  ),
                ],
              ),
              Flexible(
                child: (vm.selectedIndex == 0 &&
                            vm.userList
                                .where((element) =>
                                element.firstName.toString().isCaseInsensitiveContains(vm.searchController.text)
                            ).isEmpty
                ) ||
                        (vm.selectedIndex != 0 &&
                            vm.userList
                                .where((element) {
                             return vm.selectedIndex==0 &&(element.status== UserStatus.active || element.status== UserStatus.blocked) ||
                                  element.status == GlobalFunctions.getUserStatus(selectedIndex: vm.selectedIndex);
                            })
                                .toList()
                                .isEmpty)
                    ? Center(
                        child: Text(
                          LocalizationMap.getTranslatedValues("no_data"),
                          style: R.textStyles.poppins(),
                        ),
                      )
                    : const UserGrid(),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget searchField(UserVM vm) {
    return TextFormField(
      focusNode: searchFocus,
      onTap: () {
        log("__hre");
        userDataSource = UserDataGridSource(isWebOrDesktop: true);
        setState(() {});

      },
      onChanged: (s) {
        userDataSource = UserDataGridSource(isWebOrDesktop: true);
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

  Widget filterStatusButton({required String name, required int index, required UserVM vm}) {
    return InkWell(
      onTap: () {
        setState(() {
          vm.selectedIndex = index;
          debugPrint(vm.selectedIndex.toString());
          userDataSource = UserDataGridSource(isWebOrDesktop: true);
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
