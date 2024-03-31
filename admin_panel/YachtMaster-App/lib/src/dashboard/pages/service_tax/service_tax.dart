import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/settings/vm/settings_vm.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';
import '../../../../../../resources/resources.dart';
import '../../../../../../resources/validator.dart';
import '../../../../../../utils/text_size.dart';
import '../../../../../../utils/widgets/app_button.dart';
import '../../../auth/vm/auth_vm.dart';
import '../../vm/base_vm.dart';


class ServiceTax extends StatefulWidget {
  const ServiceTax({Key? key}) : super(key: key);

  @override
  ServiceTaxState createState() => ServiceTaxState();
}

class ServiceTaxState extends State<ServiceTax> {
  final _settingsFormKey = GlobalKey<FormState>();

  final TextEditingController serviceFeeCon = TextEditingController();
  final TextEditingController taxCon = TextEditingController();
  final TextEditingController tipCon = TextEditingController();
  final TextEditingController referralCon = TextEditingController();

  final FocusNode serviceFeeFn = FocusNode();
  final FocusNode referralFn = FocusNode();
  final FocusNode taxFn = FocusNode();
  final FocusNode tipFn = FocusNode();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BookingsVm bvm=Provider.of(context,listen: false);
      serviceFeeCon.text=bvm.serviceFee.toString();
      taxCon.text=bvm.taxes.toString();
      tipCon.text=bvm.tips.toString();
      referralCon.text=bvm.referralAmount.toString();
      setState(() {

      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SettingsVM, BaseVm, AuthVM>(
        builder: (context, settingsVm, baseVm, authVm, _) {
          return Scaffold(
            backgroundColor: R.colors.dividerColor,
            body: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _settingsFormKey,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: EdgeInsets.symmetric(vertical: ResponsiveWidget.isLargeScreen(context)?32:20, horizontal: ResponsiveWidget.isLargeScreen(context)?35:23),
                decoration: BoxDecoration(
                    color: R.colors.primary, borderRadius: BorderRadius.circular(12)),
                child: servicesWidget(settingsVm),
              ),
            ),
          );
        });
  }

  Widget servicesWidget(SettingsVM vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveWidget.isLargeScreen(context)?20:10),
        Text(
          LocalizationMap.getTranslatedValues('service_and_taxes'),
          style: R.textStyles.poppins(
            fs: AdaptiveTextSize.getAdaptiveTextSize(context, ResponsiveWidget.isLargeScreen(context)?26:18),
            fw: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveWidget.isLargeScreen(context)?20:10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding:
                    EdgeInsets.only(left: 2.sp, bottom: 1.sp, top: 5.sp),
                    child: Text(
                      LocalizationMap.getTranslatedValues('referral_amount'),
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          fw: FontWeight.w500),
                    ),
                  ),
                  TextFormField(
                    style: R.textStyles.poppins(),
                    focusNode: referralFn,
                    validator: FieldValidator.validateEmpty,
                    onTap: () {
                      setState(() {});
                    },
                    onFieldSubmitted: (val){
                      FocusScope.of(context).requestFocus(taxFn);
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: referralCon,
                    decoration: R.decoration.fieldDecoration(
                      hintText: 'enter_referral_amount',

                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding:
                    EdgeInsets.only(left: 2.sp, bottom: 1.sp, top: 5.sp),
                    child: Text(
                      LocalizationMap.getTranslatedValues('service_fee'),
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          fw: FontWeight.w500),
                    ),
                  ),
                  TextFormField(
                    style: R.textStyles.poppins(),
                    focusNode: serviceFeeFn,
                    validator: FieldValidator.validateEmpty,
                    onTap: () {
                      setState(() {});
                    },
                    onFieldSubmitted: (val){
                      FocusScope.of(context).requestFocus(taxFn);
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: serviceFeeCon,
                    decoration: R.decoration.fieldDecoration(
                        hintText: 'enter_service_fee',

                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding:
                    EdgeInsets.only(left: 2.sp, bottom: 1.sp, top: 5.sp),
                    child: Text(
                      LocalizationMap.getTranslatedValues('tax'),
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          fw: FontWeight.w500),
                    ),
                  ),
                  TextFormField(
                    style: R.textStyles.poppins(),
                    focusNode: taxFn,
                    validator: FieldValidator.validateEmpty,
                    onTap: () {
                      setState(() {});
                    },
                    onFieldSubmitted: (val){
                      FocusScope.of(context).requestFocus(tipFn);
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: taxCon,
                    decoration: R.decoration.fieldDecoration(
                      hintText: 'enter_tax',

                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding:
                    EdgeInsets.only(left: 2.sp, bottom: 1.sp, top: 5.sp),
                    child: Text(
                      LocalizationMap.getTranslatedValues('tips'),
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          fw: FontWeight.w500),
                    ),
                  ),
                  TextFormField(
                    style: R.textStyles.poppins(),
                    focusNode: tipFn,
                    validator: FieldValidator.validateEmpty,
                    onTap: () {
                      setState(() {});
                    },
                    onFieldSubmitted: (val){
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: tipCon,
                    decoration: R.decoration.fieldDecoration(
                      hintText: 'enter_tip',

                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveWidget.isLargeScreen(context)?40:20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: Get.width*.1,
              child: AppButton(
                textColor: R.colors.white,
                buttonTitle: 'save',
                onTap: () async {
                  if (_settingsFormKey.currentState!.validate()) {

                      ZBotToast.loadingShow();
                      await vm
                          .updateServiceFee(double.parse(referralCon.text),double.parse(serviceFeeCon.text),
                          double.parse(taxCon.text),double.parse(tipCon.text));
                      ZBotToast.loadingClose();


                  }
                },
              ),
            )
          ],
        ),
      ],
    );
  }
}
