import 'package:flutter/material.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';

class AdaptiveTextSize {
  const AdaptiveTextSize();

  static getAdaptiveTextSize(BuildContext context, dynamic value) {
    if (ResponsiveWidget.isLargeScreen(context)) {
      return value;
    } else if (ResponsiveWidget.isMediumScreen(context)) {
      return value-2;
    } else {
      return (value / 720) * MediaQuery.of(context).size.height+2;
    }
  }


  /*static getAdaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
    return (value / 720) * MediaQuery.of(context).size.height;
  }*/


}
