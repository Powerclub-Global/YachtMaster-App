import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view_model/feedback_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';
import '../../../../../resources/resources.dart';
import '../../../../../utils/text_size.dart';
import '../../../vm/base_vm.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  List<String> statIconList = [
    R.images.totalUsers,
    R.images.totalUsers,
    R.images.totalUsers,
    R.images.terms,
    R.images.terms,
    R.images.terms,
    R.images.terms,
  ];

  List<String> statTitleList = [
    'total_users',
    'total_requests',
    'total_reports',
    'total_bookings',
    'total_charters',
    'total_yachts',
    'total_services',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer4<BookingsVm,UserVM, BaseVm , FeedbackVm>(builder: (context, bvm,userVM, vmBase,reportsVM, _) {
      return Scaffold(
        backgroundColor: R.colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.start,
              children: [
                statsWidget(
                    vm: vmBase,
                    index: 1,
                    gradient: R.colors.appGradient,
                    image: statIconList[0],
                    title: statTitleList[0],
                    stats: userVM.userList.length),
                statsWidget(
                    vm: vmBase,
                    index: 2,
                    gradient: R.colors.appGradient,
                    image: statIconList[1],
                    title: statTitleList[1],
                    stats: userVM.userList
                        .where((element) =>
                        (element.requestStatus?.index??0)>0
                    ).length),
                statsWidget(
                    vm: vmBase,
                    index: 5,
                    gradient: R.colors.appGradient,
                    image: statIconList[2],
                    title: statTitleList[2],
                    stats: reportsVM.feedbacList.length),
                statsWidget(
                    vm: vmBase,
                    index: 3,
                    gradient: R.colors.appGradient,
                    image: statIconList[3],
                    title: statTitleList[3],
                    stats: bvm.allBookings.length),
                statsWidget(
                    vm: vmBase,
                    index: 4,
                    gradient: R.colors.appGradient,
                    image: statIconList[3],
                    title: statTitleList[4],
                    stats: userVM.allCharters.length),
                statsWidget(
                    vm: vmBase,
                    index: 7,
                    gradient: R.colors.appGradient,
                    image: statIconList[3],
                    title: statTitleList[5],
                    stats: userVM.allYachts.length),
                statsWidget(
                    vm: vmBase,
                    index: 6,
                    gradient: R.colors.appGradient,
                    image: statIconList[3],
                    title: statTitleList[6],
                    stats: userVM.allServicesList.length),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget statsWidget({
    required String image,
    required int stats,
    required String title,
    required Gradient gradient,
    required int index,
    required BaseVm vm,
  }) {
    return InkWell(
      onTap: () {
        if(index==4 || index==6 || index == 7)
          {

          }
       else{
          vm.selectedIndex = index;
          vm.pageController.jumpToPage(index);
          vm.update();
        }
      },
      child: Container(
        constraints: BoxConstraints(
            minWidth: ResponsiveWidget.isLargeScreen(context) ? 250 : 200,
            maxWidth: ResponsiveWidget.isLargeScreen(context) ? 251 : 201),
        decoration: BoxDecoration(
          color: R.colors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child:index==1?
                  Icon(Icons.store,color:  R.colors.white ,size: 5.sp,):
              Image.asset(
                image,
                color: R.colors.white,
                height: 5.h,
                width: 5.h,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationMap.getTranslatedValues(title),
                    style: R.textStyles.poppins(
                      fs: AdaptiveTextSize.getAdaptiveTextSize(context, 13),
                      fw: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ResponsiveWidget.isLargeScreen(context) ? 10 : 5),
                  Text(
                    stats.toString(),
                    style: R.textStyles.rubik(
                      fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                      color: R.colors.greyColor,
                      fw: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
