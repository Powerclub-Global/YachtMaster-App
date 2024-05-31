import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/src/base/settings/widgets/delete_account_sheet.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/resources.dart';
import '../../../../utils/general_app_bar.dart';

class ManageAccount extends StatefulWidget {
  static String route = "/manageAccount";
  const ManageAccount({Key? key}) : super(key: key);

  @override
  _ManageAccountState createState() => _ManageAccountState();
}

class _ManageAccountState extends State<ManageAccount> {
  @override
  Widget build(BuildContext context) {
    print("here in safety screen");
    return Scaffold(
      backgroundColor: R.colors.black,
      appBar: GeneralAppBar.simpleAppBar(
          context, getTranslated(context, "manage_account")!),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: R.colors.blackDull,
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(
                  horizontal: Get.width * .04, vertical: Get.height * .03),
              child: Column(
                children: [
                  tiles(0, "delete_account", R.images.bin,
                      isDivider: false, isShowArrow: false)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tiles(int index, String title, String img,
      {bool isDivider = true, bool isShowArrow = true}) {
    return GestureDetector(
      onTap: () async {
        switch (index) {
          case 0:
            Get.bottomSheet(DeleteAccountSheet());
            break;
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      img,
                      height: Get.height * .015,
                      color: R.colors.whiteColor,
                    ),
                    w4,
                    Text(
                      "${getTranslated(context, title)}",
                      style: R.textStyle
                          .helveticaBold()
                          .copyWith(color: R.colors.whiteDull, fontSize: 12.sp),
                    ),
                  ],
                ),
                if (isShowArrow == false)
                  SizedBox()
                else
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: R.colors.whiteColor, size: 14.sp)
              ],
            ),
            if (isDivider == false)
              SizedBox()
            else
              Container(
                height: Get.height * .04,
                width: Get.width,
                child: Divider(
                  color: R.colors.grey.withOpacity(.30),
                  thickness: 2,
                ),
              )
          ],
        ),
      ),
    );
  }
}
