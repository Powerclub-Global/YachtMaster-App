import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/constants/enums.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view/widgets/booking_data_grid_source.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view/widgets/booking_grid.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view/widgets/user_data_grid_source.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view/widgets/user_grid.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';
import 'package:yacht_master_admin/utils/widgets/global_functions.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';
import '../../../../../resources/resources.dart';
import '../../../../../utils/text_size.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({Key? key}) : super(key: key);

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  FocusNode searchFocus = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var vm = Provider.of<BookingsVm>(context, listen: false);
      ZBotToast.loadingShow();
      await vm.fetchAllBookings();
      ZBotToast.loadingClose();
      bookingGridSource = BookinsgDataGridSource(isWebOrDesktop: true);
      Get.forceAppUpdate();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingsVm>(builder: (context, vm, _) {
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
                  filterStatusButton(name: 'ongoing', index: 0, vm: vm),
                  filterStatusButton(name: 'completed', index: 1, vm: vm),
                  filterStatusButton(name: 'cancelled', index: 2, vm: vm),

                ],
              ),
              Flexible(
                child: (vm.selectedIndex == 0 &&
                    vm.allBookings.isEmpty
                ) ||
                    (vm.selectedIndex != 0 &&
                        vm.allBookings
                            .where((element) =>
                            element.bookingStatus == GlobalFunctions.getBookingStatus(selectedIndex: vm.selectedIndex))
                            .toList()
                            .isEmpty)
                    ? Center(
                  child: Text(
                    LocalizationMap.getTranslatedValues("no_data"),
                    style: R.textStyles.poppins(),
                  ),
                )
                    : const BookingGrid(),
              )
            ],
          ),
        ),
      );
    });
  }


  Widget filterStatusButton({required String name, required int index, required BookingsVm vm}) {
    return InkWell(
      onTap: () {
        setState(() {
          vm.selectedIndex = index;
          debugPrint(vm.selectedIndex.toString());
          bookingGridSource = BookinsgDataGridSource(isWebOrDesktop: true);
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
