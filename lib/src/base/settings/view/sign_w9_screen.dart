import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
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
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/zbot_toast.dart';

class SignW9Screen extends StatelessWidget {
  const SignW9Screen({super.key, required this.pdfBytes});
  final List<int> pdfBytes;

  @override
  Widget build(BuildContext context) {
    final AuthVm vm = Provider.of(context, listen: false);
    GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey();

    return Scaffold(
      appBar: GeneralAppBar.simpleAppBar(context, "Sign W-9 Tax Form"),
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
              AuthVm vm = Provider.of(context, listen: false);
              ZBotToast.loadingShow();
              if (vm.isVerifyingForHost) {
                await db
                    .collection("users")
                    .doc(appwrite.user.$id)
                    .collection("agreements")
                    .doc("host")
                    .set({"time": DateTime.now()});

                String imageUrl = await vm.uploadHostDocument(pdfFile);
                vm.userModel?.requestStatus = RequestStatus.requestHost;
                vm.userModel?.hostDocumentUrl = imageUrl;
                vm.update();
                await vm.updateUser(vm.userModel ?? UserModel());
                ZBotToast.showToastSuccess(
                  message:
                      "Request has been sent to admin.Please wait for the approval!",
                );
              } else {
                String imageUrl = await vm.uploadHostDocument(pdfFile);
                vm.userModel?.inviteStatus = 1;
                vm.userModel?.hostDocumentUrl = imageUrl;
                vm.update();
                await vm.updateUser(vm.userModel ?? UserModel());
                ZBotToast.showToastSuccess(
                  message:
                      "Request has been sent to admin.Please wait for the approval!",
                );
              }
              Get.toNamed(BaseView.route);
              ZBotToast.loadingClose();
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
