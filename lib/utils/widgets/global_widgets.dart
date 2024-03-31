import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/resources/resources.dart';
import 'package:yacht_master_admin/utils/text_size.dart';

class GlobalWidgets {
  static PopupMenuItem popupMenuItem(int val, String title,{bool isShow=true}) {
    return isShow==false?const PopupMenuItem(height: 0, child: SizedBox(),):
      PopupMenuItem(
        height: 0,
        value: val,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            LocalizationMap.getTranslatedValues(title),
            style: R.textStyles.poppins().copyWith(
                  fontWeight: FontWeight.w500,
                  color: R.colors.primary,
                  fontSize: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 11),
                ),
          ),
        ));
  }

  static Widget scrollerWidget({
    required BuildContext context,
    required ScrollController controller,
    required Widget child,
  }) {
    return RawScrollbar(
      controller: controller,
      thickness: 2.4,
      thumbColor: R.colors.secondary,
      trackColor: R.colors.transparent,
      radius: const Radius.circular(5),
      thumbVisibility: false,
      scrollbarOrientation: ScrollbarOrientation.right,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: child,
      ),
    );
  }

  Widget addButton({
    required BuildContext context,
    required final VoidCallback addFn,
  }) {
    return ElevatedButton.icon(
      onPressed: () => addFn(),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(R.colors.secondary),
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: 2.7.sp, horizontal: 2.sp)),
      ),
      icon: Icon(Icons.add, color: R.colors.white, size: 18),
      label: Text(LocalizationMap.getTranslatedValues("add"),
          style: R.textStyles.poppins().copyWith(
              color: R.colors.white,
              fontSize: AdaptiveTextSize.getAdaptiveTextSize(context, 15))),
    );
  }
}
