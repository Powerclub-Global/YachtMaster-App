// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/dummy.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/image_picker_services.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/document_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class PayWithCrypto extends StatefulWidget {
  static String route = "/payWithCrypto";
  const PayWithCrypto({Key? key}) : super(key: key);

  @override
  _PayWithCryptoState createState() => _PayWithCryptoState();
}

class _PayWithCryptoState extends State<PayWithCrypto> {
  DocumentModel? screenShot;
  bool isLoading = false;
  bool? isCompletePayment = false;
  double splitAmount = 0.0;
  late double converRate;
  late double userPaidAmount;
  late bool isBitcoin;

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    splitAmount = args["splitAmount"];
    userPaidAmount = args["userPaidAmount"];
    print(userPaidAmount);
    isCompletePayment = args["isCompletePayment"];
    isBitcoin = args["isBitcoin"];
    converRate = args["converRate"];
    return Consumer<BookingsVm>(builder: (context, provider, _) {
      log("___________${provider.appUrlModel?.adminCryptoEmail}");
      return ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: Scaffold(
          backgroundColor: R.colors.black,
          appBar: GeneralAppBar.simpleAppBar(context,
              "${getTranslated(context, isBitcoin ? "crypto_currency" : "crypto_currency_usdt")?.split("(").first}"),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Get.width * .05, vertical: Get.height * .02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, "payment_through_crypto") ?? "",
                    style: R.textStyle
                        .helveticaBold()
                        .copyWith(color: Colors.white),
                  ),
                  h2,
                  Text(
                    AppDummyData.bitcoinDetail,
                    style: R.textStyle.helvetica().copyWith(
                        height: 1.5, color: Colors.white, fontSize: 10.sp),
                  ),
                  h3,
                  Text(
                    getTranslated(context, "account_details") ?? "",
                    style: R.textStyle
                        .helveticaBold()
                        .copyWith(color: Colors.white),
                  ),
                  h2,
                  Container(
                    width: Get.width,
                    decoration:
                        AppDecorations.buttonDecoration(R.colors.blackDull, 12),
                    padding:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              R.images.crypto,
                              scale: 5.5,
                            ),
                          ),
                        ),
                        w2,
                        Flexible(
                          flex: 8,
                          child: Text(
                            isBitcoin
                                ? provider.appUrlModel?.adminCryptoEmail ?? ""
                                : "0x0Ea128FaD1d1d53895FeB294cAC989e3a1eB1807",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteDull, fontSize: 10.sp),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: isBitcoin
                                        ? provider.appUrlModel
                                                ?.adminCryptoEmail ??
                                            ""
                                        : "0x0Ea128FaD1d1d53895FeB294cAC989e3a1eB1807"));
                                Helper.inSnackBar(
                                    "Copied",
                                    "Your text has been copied",
                                    R.colors.themeMud);
                              },
                              child: Icon(
                                Icons.content_copy,
                                color: R.colors.whiteColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  h1,
                  Container(
                    width: Get.width,
                    decoration:
                        AppDecorations.buttonDecoration(R.colors.blackDull, 12),
                    padding:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                Icons.currency_bitcoin,
                                color: Colors.white,
                              )),
                        ),
                        Flexible(
                          flex: 8,
                          child: Text(
                            "${isBitcoin ? ((userPaidAmount + (userPaidAmount * 0.05)) * converRate).toStringAsPrecision(21) : userPaidAmount.toStringAsFixed(2)} ${isBitcoin ? 'BTC' : 'USDT'}",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteDull, fontSize: 10.sp),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: ((userPaidAmount +
                                                (userPaidAmount * 0.05)) *
                                            converRate)
                                        .toStringAsPrecision(21)));
                                Helper.inSnackBar(
                                    "Copied",
                                    "Your text has been copied",
                                    R.colors.themeMud);
                              },
                              child: Icon(
                                Icons.content_copy,
                                color: R.colors.whiteColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  h3,
                  Text(
                    getTranslated(context, "payment_detail") ?? "",
                    style: R.textStyle
                        .helveticaBold()
                        .copyWith(color: Colors.white),
                  ),
                  h2,
                  Container(
                    width: Get.width,
                    decoration:
                        AppDecorations.buttonDecoration(R.colors.blackDull, 12),
                    padding:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context,
                                  "submit_screen_shot_of_your_payment") ??
                              "",
                          style: R.textStyle.helveticaBold().copyWith(
                              color: R.colors.whiteDull, fontSize: 12.sp),
                        ),
                        h2,
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ["png", "jpg", "jpeg"],
                                  );
                                  if (result != null) {
                                    File file = File(
                                        result.files.single.path.toString());
                                    String fileName = result.files.single.name;
                                    final x =
                                        (await File(file.path).readAsBytes())
                                            .length;
                                    if ((x / (1024 * 1024)) <= 15) {
                                      setState(() {
                                        screenShot = DocumentModel(
                                            fileName,
                                            file.path.split(".").last,
                                            file,
                                            filesize(x),
                                            x / (1024 * 1024));
                                      });
                                    } else {
                                      Helper.inSnackBar(
                                          "Error",
                                          "Maximum size of file should be 15 MB",
                                          R.colors.themeMud);
                                    }

                                    log("______________________NAME:${screenShot?.fileName}____EXT:${screenShot?.ext}________Size:${filesize(x)}____SIZE:${x / (1024 * 1024)}");
                                  } else {
                                    // User canceled the picker
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1.5.h, horizontal: 5.w),
                                  decoration: AppDecorations.buttonDecoration(
                                      R.colors.whiteDull, 25),
                                  child: Text(
                                    getTranslated(context, "choose_file") ?? "",
                                    style: R.textStyle.helveticaBold().copyWith(
                                        color: R.colors.blackDull,
                                        fontSize: 11.sp),
                                  ),
                                ),
                              ),
                            ),
                            w3,
                            Expanded(
                              child: Text(
                                screenShot?.fileName != null
                                    ? screenShot?.fileName ?? ""
                                    : getTranslated(
                                            context, "no_file_chosen") ??
                                        "",
                                style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteDull, fontSize: 10.sp),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: () async {
              if (screenShot != null) {
                startLoader();
                String screenShotUrl = await ImagePickerServices()
                    .uploadSingleImage(screenShot!.file,
                        bucketName: "CryptoReceipt");
                await provider.onClickPaymentMethods(
                  screenShotUrl,
                  context,
                  isCompletePayment,
                  splitAmount,
                  userPaidAmount,
                );
                stopLoader();
              } else {
                Helper.inSnackBar(
                    "Error", "Please upload screenshot", R.colors.themeMud);
              }
            },
            child: Container(
              height: Get.height * .065,
              width: Get.width * .8,
              margin: EdgeInsets.symmetric(horizontal: Get.width * .09),
              decoration: AppDecorations.gradientButton(radius: 30),
              child: Center(
                child: Text(
                  "${getTranslated(context, "pay_now")?.toUpperCase()}",
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      );
    });
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
