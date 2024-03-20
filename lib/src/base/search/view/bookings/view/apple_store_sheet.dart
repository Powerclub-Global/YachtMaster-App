
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/dummy.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/utils/heights_widths.dart';

import '../../../../../../resources/decorations.dart';

class AppleStoreSheet extends StatefulWidget {
  Function()? callBack;

  AppleStoreSheet({this.callBack});

  @override
  _AppleStoreSheetState createState() =>
      _AppleStoreSheetState();
}

class _AppleStoreSheetState extends State<AppleStoreSheet> {
 bool isLoading=false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: SpinKitPulse(color: R.colors.themeMud,),
      child: SingleChildScrollView(
        child: Container(
          width: Get.width,
          decoration:  BoxDecoration(
            color: R.colors.black,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              topLeft: Radius.circular(40),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: Get.height * .02, horizontal: Get.width * .07),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
               h1P5,
                Text("App Store",
                    style: R.textStyle.helveticaBold().copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Get.width * .05)),
               h5,
                Row(
                  children: [
                    Image.asset(R.images.logo,scale: 7,),
                    w3,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Amigos Membership",
                          style: R.textStyle.helveticaBold().copyWith(
                            color: Colors.white,
                            fontSize: Get.width * .04,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        h0P5,
                        Text(
                          "Amigos making friendship easier.",
                          style: R.textStyle.helvetica().copyWith(
                            color: Colors.white,
                            fontSize: Get.width * .03,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
        
                  ],
                ),
                h3,
                tiles("Policy", AppDummyData.mediumText),
                h2,
                tiles("Account", "charlesbown@icloud.com"),
                h2,
                tiles("Time", "Monthly"),
                h2,
                tiles("Price", "\$x per month"),
                h5,
                GestureDetector(
                  onTap: () async {
                    startLoader();
                    await widget.callBack!();
                    stopLoader();
                  },
                  child: Container(
                    height: Get.height*.055,width: Get.width*.8,
                    decoration: AppDecorations.gradientButton(radius: 30),
                    child: Center(
                      child: Text("${getTranslated(context, "pay_now")?.toUpperCase()}",
                        style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                            fontSize: 12.sp,fontWeight: FontWeight.bold
                        ) ,),
                    ),
                  ),
                ),
                h2,
        
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget tiles(String title,String subtitle)
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: R.textStyle.helveticaBold().copyWith(
              color: Colors.white,
              fontSize: Get.width * .04,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        w1,
        Expanded(flex: 3,
          child: Text(
            subtitle,
            style: R.textStyle.helvetica().copyWith(
              color: Colors.white,
              fontSize: Get.width * .03,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
  ///LOADER
  startLoader() {
    isLoading = true;
    setState(() {});
  }

  stopLoader() {
    isLoading = false;
    setState(() {});
  }
}