import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/src/dashboard/pages/settings/vm/settings_vm.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';
import 'package:yacht_master_admin/utils/text_size.dart';
import 'package:yacht_master_admin/utils/widgets/app_button.dart';
import 'package:yacht_master_admin/utils/widgets/global_widgets.dart';
import '../../../../../constants/enums.dart';
import '../../../../../resources/resources.dart';
import '../../pages/terms_conditions/view/widgets/add_terms_dialog.dart';


class CancellationPolicy extends StatefulWidget {
  const CancellationPolicy({Key? key}) : super(key: key);

  @override
  CancellationPolicyState createState() => CancellationPolicyState();
}

class CancellationPolicyState extends State<CancellationPolicy> {
  ScrollController sc = ScrollController();
  int termsIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: R.colors.transparent,
        body: Column(
          children: [
            topWidget(
              title: "cancellation_policy",
            ),
            Flexible(
              child: Container(
                width: 100.w,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: R.colors.primary,
                ),
                child: GlobalWidgets.scrollerWidget(
                  context: context,
                  controller: sc,
                  child: ListView(
                    controller: sc,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    children: [
                      HtmlWidget(
                        context.read<SettingsVM>().allContent.firstWhereOrNull((element) => element.type==AppContentType.cancellationPolicy.index)?.content ?? "",
                        textStyle: TextStyle(color: R.colors.offWhite),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget topWidget({required String title}) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.fromLTRB(12,12,12,ResponsiveWidget.isLargeScreen(context)?12:0),
      padding: EdgeInsets.symmetric(vertical: ResponsiveWidget.isLargeScreen(context)?22:15, horizontal: ResponsiveWidget.isLargeScreen(context)?25:18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: R.colors.primary,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LocalizationMap.getTranslatedValues(title),
            style: R.textStyles.poppins(
              fs: AdaptiveTextSize.getAdaptiveTextSize(context, 18),
              fw: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: Get.width*.07,
            child: AppButton(
                borderRadius:10,
                textColor: R.colors.white,
                buttonTitle: 'edit',
                textSize:AdaptiveTextSize.getAdaptiveTextSize(context, 15) ,
                onTap: ()  {
                  Get.dialog(AddTermsDialog(text:context.read<SettingsVM>().allContent.firstWhereOrNull((element) => element.type==AppContentType.cancellationPolicy.index)?.content ?? "",label: "cancellation_policy",contentType: AppContentType.cancellationPolicy, docId: "znYi6xHCmVGWXGBVtkEj",)).then((value) => setState((){}));
                }
            ),
          )

        ],
      ),
    );
  }


}
