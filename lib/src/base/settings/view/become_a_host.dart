import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/src/base/settings/view/fill_w9_screen.dart';
import '../../../../appwrite.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/resources.dart';
import '../../../auth/view_model/auth_vm.dart';
import '../../search/view/bookings/view_model/bookings_vm.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../resources/decorations.dart';

import '../../../../services/firebase_collections.dart';
import '../../admin_chat/model/admin_chat_head_model.dart';
import '../../admin_chat/model/admin_chat_model.dart';
import '../../admin_chat/view/admin_chat_view.dart';
import '../../base_vm.dart';
import '../../inbox/view_model/inbox_vm.dart';
import '../../search/view/bookings/model/document_model.dart';
import '../../yacht/view_model/yacht_vm.dart';

class BecomeHost extends StatefulWidget {
  static String route = "/becomeHost";
  bool isHost;
  BecomeHost({this.isHost = true});

  @override
  _BecomeHostState createState() => _BecomeHostState();
}

class _BecomeHostState extends State<BecomeHost> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm ??= Provider.of(context, listen: true);
  }

  List<String> tabsList = ["invite", "earnings"];
  int selectedTabIndex = 0;
  DocumentModel? screenShot;
  AuthVm? vm;
  final _flutterMediaDownloaderPlugin = MediaDownload();
  @override
  Widget build(BuildContext context) {
    log("____FILE:${context.read<BookingsVm>().appUrlModel?.hostPolicies}");
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar.simpleAppBar(
          context,
          getTranslated(context, "become_a_host") ?? "",
        ),
        backgroundColor: R.colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            h5,
            Image.asset(R.images.request, scale: 4),
            h4,
            Text(
              getTranslated(context, "request_host_access") ?? "",
              style: R.textStyle.helveticaBold().copyWith(
                color: Colors.white,
                fontSize: 16.sp,
              ),
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
                  fontSize: 12.sp,
                ),
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
                    color: R.colors.blackDull,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Image.asset(R.images.pdf, scale: 6),
                            w3,
                            Flexible(
                              child: Text(
                                screenShot?.fileName ?? "",
                                style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.whiteColor,
                                  fontSize: 11.sp,
                                ),
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
                      ),
                    ],
                  ),
                ),
              ),
            h3,

            GestureDetector(
              onTap:
                  vm!.isLoading
                      ? () {}
                      : () async {
                        Get.to(FillW9Screen());
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            h1,
            GestureDetector(
              onTap: () async {
                var InboxPro = Provider.of<InboxVm>(context, listen: false);
                var yachtVm = Provider.of<YachtVm>(context, listen: false);
                AdminChatHeadModel? chatHead = await createChatHead(
                  InboxPro,
                  yachtVm,
                );
                setState(() {});
                Get.toNamed(
                  AdminChatView.route,
                  arguments: {"chatHeadModel": chatHead},
                );
              },
              child: Center(
                child: Text(
                  getTranslated(context, "contact") ?? "",
                  style: R.textStyle.helvetica().copyWith(
                    color: R.colors.themeMud,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            h3,
          ],
        ),
      ),
    );
  }

  Future<AdminChatHeadModel?> createChatHead(
    InboxVm chatVm,
    YachtVm yachtVm,
  ) async {
    AdminChatHeadModel? chatHeadModel;
    AdminChatHeadModel chatData = AdminChatHeadModel(
      id: appwrite.user.$id,
      lastMessage: AdminChatModel(
        message: "",
        createdAt: Timestamp.now(),
        senderId: appwrite.user.$id,
        chatHeadId: appwrite.user.$id,
        type: 0,
        isSeen: false,
        receiverId:
            Provider.of<BaseVm>(context, listen: false).allUsers
                .firstWhereOrNull((element) => element.role == UserType.admin)
                ?.uid ??
            "",
      ),
      status: 0,
      users: [
        appwrite.user.$id ?? "",
        Provider.of<BaseVm>(context, listen: false).allUsers
                .firstWhereOrNull((element) => element.role == UserType.admin)
                ?.uid ??
            "",
      ],
    );
    chatHeadModel = await createChatHeadDoc(chatData);
    setState(() {});
    return chatHeadModel;
  }

  Future<AdminChatHeadModel?> createChatHeadDoc(
    AdminChatHeadModel chatData,
  ) async {
    AdminChatHeadModel? chatHeadModel;
    try {
      DocumentSnapshot doc =
          await FbCollections.adminChat.doc(chatData.id).get();

      if (doc.data() == null) {
        chatHeadModel = AdminChatHeadModel(
          id: appwrite.user.$id,
          lastMessage: AdminChatModel(
            message: "",
            createdAt: Timestamp.now(),
            senderId: appwrite.user.$id,
            chatHeadId: appwrite.user.$id,
            type: 0,
            isSeen: false,
            receiverId:
                Provider.of<BaseVm>(context, listen: false).allUsers
                    .firstWhereOrNull(
                      (element) => element.role == UserType.admin,
                    )
                    ?.uid ??
                "",
          ),
          status: 0,
          users: [
            appwrite.user.$id ?? "",
            Provider.of<BaseVm>(context, listen: false).allUsers
                    .firstWhereOrNull(
                      (element) => element.role == UserType.admin,
                    )
                    ?.uid ??
                "",
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
