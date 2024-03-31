import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';
import 'package:yacht_master_admin/utils/widgets/app_button.dart';

import '../../../../resources/resources.dart';
import '../../../../utils/text_size.dart';
import '../../../auth/vm/auth_vm.dart';
import '../../vm/base_vm.dart';

class SideBarWidget extends StatefulWidget {
  const SideBarWidget({Key? key}) : super(key: key);

  @override
  State<SideBarWidget> createState() => _SideBarWidgetState();
}

class _SideBarWidgetState extends State<SideBarWidget> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer2<BaseVm, AuthVM>(builder: (context, baseVm, authVm, _) {
      return ResponsiveWidget.isLargeScreen(context)
          ? largeWidget(baseVm, authVm)
          : smallWidget(baseVm, authVm);
    });
  }

  Widget largeWidget(BaseVm baseVm, AuthVM authVm) {
    return Container(
      color: R.colors.greyBlack,
      child: Column(
        children: [
          userWidget(baseVm),
          Divider(
            color: R.colors.white,
            thickness: 1,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.sp),
              child: RawScrollbar(
                thickness: 2,
                thumbColor: R.colors.secondary,
                radius: const Radius.circular(5),
                thumbVisibility: false,
                controller: scrollController,
                scrollbarOrientation: ScrollbarOrientation.right,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      sideBarContainer(
                        indexCount: 0,
                        image: R.images.dashboard,
                        title: 'dashboard',
                        baseVm: baseVm,
                      ),
                      if (!baseVm.isMini)
                        titleText(
                          title: "user_management",
                          baseVm: baseVm,
                        ),
                      sideBarContainer(
                        indexCount: 1,
                        image: R.images.maleUsers,
                        title: 'users',
                        baseVm: baseVm,
                      ),
                      if (!baseVm.isMini)
                        titleText(
                          title: "request_management",
                          baseVm: baseVm,
                        ),
                      sideBarContainer(
                        indexCount: 2,
                        image: R.images.maleUsers,
                        title: 'requests',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 14,
                        image: R.images.maleUsers,
                        title: 'payment_verification_requests',
                        baseVm: baseVm,
                      ),
                      if (!baseVm.isMini)
                        titleText(
                          title: "booking_management",
                          baseVm: baseVm,
                        ),
                      sideBarContainer(
                        indexCount: 3,
                        image: R.images.terms,
                        title: 'bookings',
                        baseVm: baseVm,
                      ),
                      if (!baseVm.isMini)
                        titleText(
                          title: "payment_management",
                          baseVm: baseVm,
                        ),
                      sideBarContainer(
                        indexCount: 4,
                        image: R.images.terms,
                        title: 'payment',
                        baseVm: baseVm,
                      ),
                      if (!baseVm.isMini)
                        titleText(
                          title: "feedback_management",
                          baseVm: baseVm,
                        ),
                      sideBarContainer(
                        indexCount: 5,
                        icon: Icons.store,
                        isIcon: true,
                        title: 'feedback',
                        baseVm: baseVm,
                      ),
                      Visibility(
                        visible: false,
                        child: sideBarContainer(
                          indexCount: 6,
                          icon: Icons.store,
                          isIcon: true,
                          title: 'report_types',
                          baseVm: baseVm,
                        ),
                      ),
                      if (!baseVm.isMini)
                        titleText(
                          title: "content_management",
                          baseVm: baseVm,
                        ),
                      sideBarContainer(
                        indexCount: 7,
                        image: R.images.terms,
                        title: 'terms_and_condition',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 8,
                        image: R.images.terms,
                        title: 'privacy_policy',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 9,
                        image: R.images.terms,
                        title: 'cancellation_policy',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 10,
                        image: R.images.terms,
                        title: 'refund_policy',
                        baseVm: baseVm,
                      ),
                      if (!baseVm.isMini)
                        titleText(
                          title: "service_tax",
                          baseVm: baseVm,
                        ),
                      sideBarContainer(
                        indexCount: 11,
                        image: R.images.terms,
                        title: 'service_and_taxes',
                        baseVm: baseVm,
                      ),
                      if (!baseVm.isMini)
                        titleText(
                          title: "chats",
                          baseVm: baseVm,
                        ),
                      sideBarContainer(
                        indexCount: 12,
                        image: R.images.inbox,
                        title: 'chat',
                        baseVm: baseVm,
                      ),
                      if (!baseVm.isMini)
                        titleText(
                          title: "settings",
                          baseVm: baseVm,
                        ),
                      sideBarContainer(
                        indexCount: 13,
                        image: R.images.password,
                        title: 'change_password',
                        baseVm: baseVm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          logoutBtn(baseVm, authVm),
        ],
      ),
    );
  }

  Widget smallWidget(BaseVm baseVm, AuthVM authVm) {
    return Container(
      color: R.colors.greyBlack,
      child: Column(
        children: [
          smallUserWidget(baseVm),
          Divider(
            color: R.colors.white,
            thickness: 1,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.sp),
              child: RawScrollbar(
                thickness: 2,
                thumbColor: R.colors.secondary,
                radius: const Radius.circular(5),
                thumbVisibility: false,
                controller: scrollController,
                scrollbarOrientation: ScrollbarOrientation.right,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      smallSideBarContainer(
                        indexCount: 0,
                        image: R.images.dashboard,
                        title: 'dashboard',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 1,
                        image: R.images.maleUsers,
                        title: 'users',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 2,
                        image: R.images.maleUsers,
                        title: 'requests',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 14,
                        image: R.images.maleUsers,
                        title: 'payment_verification_requests',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 3,
                        image: R.images.maleUsers,
                        title: 'bookings',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 4,
                        image: R.images.terms,
                        title: 'payment',
                        baseVm: baseVm,
                      ),
                      smallSideBarContainer(
                        indexCount: 5,
                        icon: Icons.store,
                        isIcon: true,
                        title: 'feedbacks',
                        baseVm: baseVm,
                      ),
                      smallSideBarContainer(
                        indexCount: 6,
                        icon: Icons.store,
                        isIcon: true,
                        title: 'report_types',
                        baseVm: baseVm,
                      ),
                      smallSideBarContainer(
                        indexCount: 7,
                        image: R.images.terms,
                        title: 'terms_and_condition',
                        baseVm: baseVm,
                      ),
                      smallSideBarContainer(
                        indexCount: 8,
                        image: R.images.terms,
                        title: 'privacy_policy',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 9,
                        image: R.images.terms,
                        title: 'cancellation_policy',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 10,
                        image: R.images.terms,
                        title: 'refund_policy',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 11,
                        image: R.images.terms,
                        title: 'service_and_taxes',
                        baseVm: baseVm,
                      ),
                      sideBarContainer(
                        indexCount: 12,
                        image: R.images.inbox,
                        title: 'chat',
                        baseVm: baseVm,
                      ),
                      smallSideBarContainer(
                        indexCount: 13,
                        image: R.images.password,
                        title: 'change_password',
                        baseVm: baseVm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          smallLogoutBtn(baseVm, authVm),
        ],
      ),
    );
  }

  Widget sideBarContainer({
    String? image,
    IconData? icon,
    bool? isIcon = false,
    required String title,
    required int indexCount,
    required BaseVm baseVm,
  }) {
    return InkWell(
      onTap: () {
        BookingsVm bvm = Provider.of(context, listen: false);
        baseVm.selectedIndex = indexCount;
        if (baseVm.selectedIndex == 2) {
          bvm.selectedIndex = 3;
          bvm.update();
        } else if (baseVm.selectedIndex == 4) {
          bvm.selectedIndex = 2;
          bvm.update();
        } else {
          bvm.selectedIndex = 0;
          bvm.update();
        }
        baseVm.pageController.jumpToPage(indexCount);
        baseVm.update();
      },
      child: Container(
        alignment: baseVm.isMini ? Alignment.center : Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 2.h),
        padding: EdgeInsets.all(3.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: baseVm.selectedIndex == indexCount ? R.colors.primary : null,
        ),
        child: Row(
          mainAxisAlignment: baseVm.isMini == true
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 4.sp,
              height: 4.sp,
              child: isIcon == true
                  ? Icon(
                      icon,
                      color: baseVm.selectedIndex == indexCount
                          ? R.colors.white
                          : R.colors.sideIconColor,
                      size: 4.sp,
                    )
                  : Image.asset(
                      image ?? '',
                      color: baseVm.selectedIndex == indexCount
                          ? R.colors.white
                          : R.colors.lightGreyColor2,
                    ),
            ),
            if (!baseVm.isMini) SizedBox(width: 4.sp),
            if (!baseVm.isMini)
              Expanded(
                child: Text(
                  LocalizationMap.getTranslatedValues(title),
                  style: R.textStyles.poppins().copyWith(
                        color: baseVm.selectedIndex == indexCount
                            ? R.colors.white
                            : R.colors.lightGreyColor2,
                        fontSize:
                            AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget smallSideBarContainer({
    String? image,
    IconData? icon,
    bool? isIcon = false,
    required String title,
    required int indexCount,
    required BaseVm baseVm,
  }) {
    return InkWell(
      onTap: () {
        baseVm.selectedIndex = indexCount;
        baseVm.pageController.jumpToPage(indexCount);
        baseVm.update();
      },
      child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 2.h),
          padding: EdgeInsets.all(2.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color:
                baseVm.selectedIndex == indexCount ? R.colors.secondary : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 5.sp,
                height: 5.sp,
                child: isIcon == true
                    ? Icon(
                        icon,
                        color: baseVm.selectedIndex == indexCount
                            ? R.colors.white
                            : R.colors.sideIconColor,
                        size: 5.sp,
                      )
                    : Image.asset(
                        image ?? '',
                        color: baseVm.selectedIndex == indexCount
                            ? R.colors.white
                            : R.colors.lightGreyColor2,
                      ),
              ),
            ],
          )),
    );
  }

  Widget userWidget(BaseVm baseVm) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          baseVm.isMini ? 2.sp : 5.sp, 5.sp, baseVm.isMini ? 0 : 5.sp, 2.sp),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            margin: EdgeInsets.only(right: baseVm.isMini ? 0 : 7),
            decoration: BoxDecoration(
              color: R.colors.lightYellowColor,
              border: Border.all(color: R.colors.white, width: 1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              R.images.splashIcon,
              height: 5.h,
            ),
          ),
          if (!baseVm.isMini)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationMap.getTranslatedValues("yachtmaster"),
                  style: R.textStyles.poppins(
                    color: R.colors.white,
                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                      context,
                      18,
                    ),
                    fw: FontWeight.w600,
                  ),
                ),
                Text(
                  LocalizationMap.getTranslatedValues("admin"),
                  style: R.textStyles.poppins(
                    color: R.colors.hintTextColor,
                    fs: baseVm.isMini
                        ? AdaptiveTextSize.getAdaptiveTextSize(context, 10)
                        : AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                    fw: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget smallUserWidget(BaseVm baseVm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: R.colors.lightYellowColor,
          border: Border.all(color: R.colors.white, width: 1),
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          R.images.splashIcon,
          height: 5.h,
        ),
      ),
    );
  }

  Widget logoutBtn(BaseVm baseVm, AuthVM authVm) {
    return baseVm.isMini
        ? Container(
            width: Get.width,
            height: 7.h,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: R.colors.secondary),
            child: IconButton(
              onPressed: () async {
                baseVm.selectedIndex = 0;
                await authVm.logout();
              },
              icon: Icon(
                Icons.power_settings_new,
                color: R.colors.white,
                size: 16,
              ),
            ),
          )
        : Container(
            width: Get.width,
            height: 7.h,
            margin: const EdgeInsets.all(10),
            child: AppButton(
              buttonTitle: "logout",
              onTap: () async {
                baseVm.selectedIndex = 0;
                await authVm.logout();
              },
            ),
          );
  }

  Widget smallLogoutBtn(BaseVm baseVm, AuthVM authVm) {
    return Container(
      width: Get.width,
      height: 7.h,
      margin: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: R.colors.secondary),
      child: IconButton(
        onPressed: () async {
          baseVm.selectedIndex = 0;
          await authVm.logout();
        },
        icon: Icon(
          Icons.power_settings_new,
          color: R.colors.white,
          size: 12,
        ),
      ),
    );
  }

  Widget titleText({
    required String title,
    required BaseVm baseVm,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(left: 3.sp, top: 1.sp, bottom: 1.sp, right: 1.sp),
      child: Text(
        '--${LocalizationMap.getTranslatedValues(title).toUpperCase()}',
        style: R.textStyles.montserrat(
          color: R.colors.lightGrey,
          fs: AdaptiveTextSize.getAdaptiveTextSize(
              context, baseVm.isMini ? 9 : 13),
          fw: FontWeight.w400,
        ),
      ),
    );
  }
}
