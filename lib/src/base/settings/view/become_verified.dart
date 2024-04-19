import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/blocs/bloc_exports.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/widgets/agreement_sheet.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/zbot_toast.dart';
import '../../../../resources/decorations.dart';

import '../../../../services/firebase_collections.dart';
import '../../../../utils/helper.dart';
import '../../admin_chat/model/admin_chat_head_model.dart';
import '../../admin_chat/model/admin_chat_model.dart';
import '../../admin_chat/view/admin_chat_view.dart';
import '../../base_vm.dart';
import '../../inbox/view_model/inbox_vm.dart';
import '../../search/view/bookings/model/document_model.dart';
import '../../yacht/view_model/yacht_vm.dart';

class BecomeVerified extends StatefulWidget {
  static String route = "/becomeVerified";
  bool isHost;
  BecomeVerified({
    this.isHost = true,
  });

  @override
  _BecomeVerifiedState createState() => _BecomeVerifiedState();
}

class _BecomeVerifiedState extends State<BecomeVerified> {
  List<String> tabsList = ["invite", "earnings"];
  int selectedTabIndex = 0;
  DocumentModel? screenShot;
  final _flutterMediaDownloaderPlugin = MediaDownload();
  @override
  Widget build(BuildContext context) {
    log("____FILE:${context.read<BookingsVm>().appUrlModel?.hostPolicies}");
    return Scaffold(
      appBar: GeneralAppBar.simpleAppBar(context, "Document Verification"),
      backgroundColor: R.colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          h5,
          Image.asset(
            R.images.request,
            scale: 4,
          ),
          h4,
          Text(
            "Request Payouts",
            style: R.textStyle
                .helveticaBold()
                .copyWith(color: Colors.white, fontSize: 16.sp),
          ),
          h2,
          SizedBox(
            width: Get.width * .85,
            child: Text(
              "In order to receive payouts from YachtMaster App you must complete a W-9 Tax form as Mandated by the Federal Tax Commission\n\nPlease Download the W-9 Form provided below, and upload the completed document to request Payouts.",
              style: R.textStyle.helvetica().copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: Colors.white,
                  fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          if (screenShot != null)
            DottedBorder(
                borderType: BorderType.RRect,
                radius: Radius.circular(12),
                color: R.colors.whiteColor,
                dashPattern: [4, 2],
                strokeWidth: 1.4,
                child: Container(
                  width: Get.width * .85,
                  height: Get.height * .07,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: R.colors.blackDull),
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Image.asset(
                              R.images.pdf,
                              scale: 6,
                            ),
                            w3,
                            Flexible(
                              child: Text(
                                screenShot?.fileName ?? "",
                                style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteColor,
                                    fontSize: 11.sp),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          screenShot = null;
                          setState(() {});
                        },
                        child: Icon(
                          Icons.cancel_outlined,
                          color: R.colors.whiteColor,
                          size: 24,
                        ),
                      )
                    ],
                  ),
                )),
          h3,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ZBotToast.loadingShow();
                      _flutterMediaDownloaderPlugin
                          .downloadMedia(
                        context,
                        context.read<BookingsVm>().appUrlModel?.hostPolicies ??
                            "",
                      )
                          .then((value) {
                        ZBotToast.showToastSuccess(
                          message: "Host Policy downloaded successfully!",
                        );
                      });
                      ZBotToast.loadingClose();
                    },
                    child: Container(
                      height: Get.height * .055,
                      width: Get.width * .8,
                      margin: EdgeInsets.symmetric(
                        horizontal: 1.2.w,
                      ),
                      decoration: AppDecorations.gradientButton(radius: 30),
                      child: Center(
                        child: Text(
                          getTranslated(context, "download") ?? "",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ["pdf", "jpeg", "jpg", "png"],
                      );
                      if (result != null) {
                        File file = File(result.files.single.path.toString());
                        String fileName = result.files.single.name;
                        final x = (await File(file.path).readAsBytes()).length;
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
                      } else {
                        // User canceled the picker
                      }
                    },
                    child: Container(
                      height: Get.height * .055,
                      width: Get.width * .8,
                      margin: EdgeInsets.symmetric(horizontal: 1.2.w),
                      decoration: AppDecorations.gradientButton(radius: 30),
                      child: Center(
                        child: Text(
                          getTranslated(context, "upload") ?? "",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          h1P5,
          GestureDetector(
            onTap: () async {
              ZBotToast.loadingShow();
              if (screenShot == null || screenShot?.fileName == "") {
                ZBotToast.showToastError(
                    message:
                        "Please upload the required document mentioned in the Host Policy");
              } else {
                AuthVm vm = Provider.of(context, listen: false);
                String imageUrl = await vm.uploadHostDocument(screenShot?.file);
                vm.userModel?.inviteStatus = 1;
                vm.userModel?.hostDocumentUrl = imageUrl;
                vm.update();
                await vm.updateUser(vm.userModel ?? UserModel());
                ZBotToast.showToastSuccess(
                    message:
                        "Request has been sent to admin.Please wait for the approval!");
                Get.back();
              }
              ZBotToast.loadingClose();
            },
            child: Container(
              height: Get.height * .055,
              width: Get.width * .8,
              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              decoration: AppDecorations.gradientButton(radius: 30),
              child: Center(
                child: Text(
                  getTranslated(context, "request") ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          h1,
          GestureDetector(
            onTap: () async {
              var InboxPro = Provider.of<InboxVm>(context, listen: false);
              var yachtVm = Provider.of<YachtVm>(context, listen: false);
              AdminChatHeadModel? chatHead =
                  await createChatHead(InboxPro, yachtVm);
              setState(() {});
              Get.toNamed(AdminChatView.route,
                  arguments: {"chatHeadModel": chatHead});
            },
            child: Center(
              child: Text(
                getTranslated(context, "contact") ?? "",
                style: R.textStyle.helvetica().copyWith(
                    color: R.colors.themeMud,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          h3
        ],
      ),
    );
  }

  Future<AdminChatHeadModel?> createChatHead(
      InboxVm chatVm, YachtVm yachtVm) async {
    AdminChatHeadModel? chatHeadModel;
    AdminChatHeadModel chatData = AdminChatHeadModel(
      id: FirebaseAuth.instance.currentUser?.uid,
      lastMessage: AdminChatModel(
          message: "",
          createdAt: Timestamp.now(),
          senderId: FirebaseAuth.instance.currentUser?.uid,
          chatHeadId: FirebaseAuth.instance.currentUser?.uid,
          type: 0,
          isSeen: false,
          receiverId: Provider.of<BaseVm>(context, listen: false)
                  .allUsers
                  .firstWhereOrNull((element) => element.role == UserType.admin)
                  ?.uid ??
              ""),
      status: 0,
      users: [
        FirebaseAuth.instance.currentUser?.uid ?? "",
        Provider.of<BaseVm>(context, listen: false)
                .allUsers
                .firstWhereOrNull((element) => element.role == UserType.admin)
                ?.uid ??
            ""
      ],
    );
    chatHeadModel = await createChatHeadDoc(chatData);
    setState(() {});
    return chatHeadModel;
  }

  Future<AdminChatHeadModel?> createChatHeadDoc(
      AdminChatHeadModel chatData) async {
    AdminChatHeadModel? chatHeadModel;
    try {
      DocumentSnapshot doc =
          await FbCollections.adminChat.doc(chatData.id).get();

      if (doc.data() == null) {
        chatHeadModel = AdminChatHeadModel(
          id: FirebaseAuth.instance.currentUser?.uid,
          lastMessage: AdminChatModel(
              message: "",
              createdAt: Timestamp.now(),
              senderId: FirebaseAuth.instance.currentUser?.uid,
              chatHeadId: FirebaseAuth.instance.currentUser?.uid,
              type: 0,
              isSeen: false,
              receiverId: Provider.of<BaseVm>(context, listen: false)
                      .allUsers
                      .firstWhereOrNull(
                          (element) => element.role == UserType.admin)
                      ?.uid ??
                  ""),
          status: 0,
          users: [
            FirebaseAuth.instance.currentUser?.uid ?? "",
            Provider.of<BaseVm>(context, listen: false)
                    .allUsers
                    .firstWhereOrNull(
                        (element) => element.role == UserType.admin)
                    ?.uid ??
                ""
          ],
        );
      } else {
        chatHeadModel = AdminChatHeadModel.fromJson(doc.data());
      }
    } catch (e) {
      log(e.toString());
    }
    return chatHeadModel;
  }
}
