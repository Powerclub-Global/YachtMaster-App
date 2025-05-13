import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/src/base/settings/view/fill_w9_screen.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/resources.dart';
import '../../../auth/view_model/auth_vm.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../resources/decorations.dart';


class W9InfoScreen extends StatefulWidget {
  static String route = "/w9InfoScreen";

  const W9InfoScreen();

  @override
  _W9InfoScreenState createState() => _W9InfoScreenState();
}

class _W9InfoScreenState extends State<W9InfoScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm ??= Provider.of(context, listen: true);
  }

  AuthVm? vm;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar.simpleAppBar(
          context,
          "W-9 Tax Form for Host Access",
        ),
        backgroundColor: R.colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            h5,
            Image.asset(R.images.request, scale: 4),
            h4,

            SizedBox(
              width: Get.width * .85,
              child: Text(
                "In order to receive payouts from YachtMaster App you must complete a W-9 Tax form as Mandated by the Federal Tax Commission\n\nPlease press the button below to continue",
                style: R.textStyle.helvetica().copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),

            GestureDetector(
              onTap: () async {
                Get.to(FillW9Screen());
              },
              child: Container(
                height: Get.height * .055,
                width: Get.width * .8,
                margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: AppDecorations.gradientButton(radius: 30),
                child: Center(
                  child: Text(
                    getTranslated(context, "fill_w9") ?? "",
                    style: R.textStyle.helvetica().copyWith(
                      color: R.colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            h1,

            h3,
          ],
        ),
      ),
    );
  }
}
