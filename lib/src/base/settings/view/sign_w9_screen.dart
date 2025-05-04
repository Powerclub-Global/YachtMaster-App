import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_identity_plugin/stripe_identity_plugin.dart';
import 'package:stripe_identity_plugin/utils/enum.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:yacht_master/appwrite.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/base_view.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/zbot_toast.dart';

class SignW9Screen extends StatelessWidget {
  const SignW9Screen({super.key, required this.pdfBytes});
  final List<int> pdfBytes;

  @override
  Widget build(BuildContext context) {
    final AuthVm vm = Provider.of(context, listen: false);
    GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey();
    final stripeIdentity = StripeIdentityPlugin();

    Future<Map<String, String>> createStripeVerificationSession(
      String email,
      String userId,
    ) async {
      final url = Uri.parse(
        'https://us-central1-yacht-masters.cloudfunctions.net/createVerificationSession',
      );

      // Send the POST request with the data
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Set the content type as JSON
        },
        body: json.encode({'email': email, 'userId': userId}),
      );

      if (response.statusCode == 200) {
        // Successfully received the response
        final responseData = json.decode(response.body);
        return {
          'verificationSessionId': responseData['verificationSessionId'],
          'ephemeralKeySecret': responseData['ephemeralKeySecret'],
        };
      } else {
        return Future.error(
          'Failed to create verification session. Status code: ${response.statusCode}',
        );
      }
    }

    Future<(VerificationResult, String?)> initiateStripeVerification() async {
      ZBotToast.loadingShow();
      Map<String, String> result = await createStripeVerificationSession(
        vm.userModel!.email!,
        vm.userModel!.uid!,
      );
      ZBotToast.loadingClose();
      // log(result.toString());
      final (status, message) = await stripeIdentity.startVerification(
        id: result['verificationSessionId']!,
        key: result['ephemeralKeySecret']!,
        brandLogoUrl:
            'https://raw.githubusercontent.com/Powerclub-Global/YachtMaster-App/refs/heads/dev/assets/images/icon.png', // Optional
      );
      log("____STATUS:$message");
      return (status, message);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AspectRatio(
            aspectRatio: 4,
            child: SfSignaturePad(
              key: signaturePadKey,
              backgroundColor: R.colors.milkyWhite,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final image = await signaturePadKey.currentState!.toImage();
              final byteData = await image.toByteData(
                format: ImageByteFormat.png,
              );
              Uint8List imageBytesList = byteData!.buffer.asUint8List();
              final pdfDocument = PdfDocument(inputBytes: pdfBytes);
              final PdfBitmap pdfImage = PdfBitmap(imageBytesList);
              //Draw the image to the PDF page.
              pdfDocument.pages[0].graphics.drawImage(
                pdfImage,
                const Rect.fromLTWH(125, 575, 100, 25),
              );
              pdfDocument.pages[0].graphics.drawString(
                DateFormat('MM-dd-yyyy').format(DateTime.now().toLocal()),
                PdfStandardFont(
                  PdfFontFamily.helvetica,
                  10,
                  style: PdfFontStyle.bold,
                ),
                bounds: const Rect.fromLTWH(410, 585, 200, 15),
              );
              List<int> signedPdfBytes = await pdfDocument.save();

              final directory = await getApplicationDocumentsDirectory();
              final filePath =
                  '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.pdf';
              final pdfFile = File(filePath);
              await pdfFile.writeAsBytes(signedPdfBytes, flush: true);
              final (stripeResult, message) =
                  await initiateStripeVerification();
              switch (stripeResult) {
                case VerificationResult.completed:
                  {
                    ZBotToast.loadingShow();

                    await db
                        .collection("users")
                        .doc(appwrite.user.$id)
                        .collection("agreements")
                        .doc("host")
                        .set({"time": DateTime.now()});
                    AuthVm vm = Provider.of(context, listen: false);
                    String imageUrl = await vm.uploadHostDocument(pdfFile);
                    vm.userModel?.requestStatus = RequestStatus.requestHost;
                    vm.userModel?.hostDocumentUrl = imageUrl;
                    vm.update();
                    await vm.updateUser(vm.userModel ?? UserModel());
                    ZBotToast.showToastSuccess(
                      message:
                          "Request has been sent to admin.Please wait for the approval!",
                    );
                    Get.toNamed(BaseView.route);

                    ZBotToast.loadingClose();
                  }

                case VerificationResult.canceled:
                  Helper.inSnackBar(
                    'Error',
                    "Verification was cancelled",
                    R.colors.themeMud,
                  );
                case VerificationResult.failed:
                  Helper.inSnackBar(
                    'Error',
                    "Verification Failed: $message",
                    R.colors.themeMud,
                  );
                case VerificationResult.unknown:
                  Helper.inSnackBar(
                    'Error',
                    "Unknown error occured $message",
                    R.colors.themeMud,
                  );
              }
            },
            child: Container(
              height: Get.height * .055,
              width: Get.width * .8,
              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              decoration: AppDecorations.gradientButton(radius: 30),
              child: Center(
                child: Text(
                  getTranslated(context, "continue") ?? "",
                  style: R.textStyle.helvetica().copyWith(
                    color: R.colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
