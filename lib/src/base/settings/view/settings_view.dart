import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/constant.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/view/login.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/admin_chat/model/admin_chat_head_model.dart';
import 'package:yacht_master/src/base/admin_chat/view/admin_chat_view.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/home/view/help_center.dart';
import 'package:yacht_master/src/base/inbox/model/chat_heads_model.dart';
import 'package:yacht_master/src/base/inbox/view/chat.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/src/base/profile/view/host_profile.dart';
import 'package:yacht_master/src/base/profile/view/user_profile.dart';
import 'package:yacht_master/src/base/profile/widgets/edit_profile_bottomsheet.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/settings/model/app_feedback_model.dart';
import 'package:yacht_master/src/base/settings/view/about_app.dart';
import 'package:yacht_master/src/base/settings/view/ask_a_superhost.dart';
import 'package:yacht_master/src/base/settings/view/become_verified.dart';
import 'package:yacht_master/src/base/settings/view/invite_earn/invite_earn.dart';
import 'package:yacht_master/src/base/settings/view/payment_payouts.dart';
import 'package:yacht_master/src/base/settings/view/privacy_policy.dart';
import 'package:yacht_master/src/base/settings/view/privacy_sharing.dart';
import 'package:yacht_master/src/base/settings/view/safety_center.dart';
import 'package:yacht_master/src/base/settings/view/terms_of_services.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/settings/widgets/feedback_bottomsheet.dart';
import 'package:yacht_master/src/base/settings/widgets/logout_sheet.dart';
import 'package:yacht_master/src/base/settings/widgets/translate_bottomsheet.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/zbot_toast.dart';

import '../../../../constant/enums.dart';
import '../../admin_chat/model/admin_chat_model.dart';
import '../../yacht/view/rules_regulations.dart';
import '../widgets/delete_account_sheet.dart';
import 'become_a_host.dart';

class SettingsView extends StatefulWidget {
  static String route = "/settingsView";

  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthVm>(builder: (context, authVm, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * .04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                h9,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircularProfileAvatar(
                              "",
                              radius: 28.sp,
                              child: CachedNetworkImage(
                                imageUrl: authVm.userModel?.imageUrl?.isEmpty ==
                                            true ||
                                        authVm.userModel?.imageUrl == null
                                    ? R.images.dummyDp
                                    : authVm.userModel?.imageUrl ?? "",
                                fit: BoxFit.cover,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        SpinKitPulse(
                                  color: R.colors.themeMud,
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                            Image.asset(
                              R.images.check,
                              height: Get.height * .026,
                            )
                          ],
                        ),
                        h2,
                        Text(
                          authVm.userModel?.firstName ?? "",
                          style: R.textStyle
                              .helveticaBold()
                              .copyWith(color: R.colors.whiteColor),
                        ),
                        h2,
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(48, 158, 158, 158)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  authVm.userModel?.username ?? "",
                                  style: R.textStyle
                                      .helveticaBold()
                                      .copyWith(color: R.colors.whiteColor),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(
                                          text: authVm.userModel?.username ??
                                              ""));
                                      Helper.inSnackBar(
                                          "Copied",
                                          "Your text has been copied",
                                          R.colors.themeMud);
                                    },
                                    icon: Icon(
                                      Icons.copy,
                                      size: 24,
                                    ))
                              ],
                            ),
                          ),
                        ),
                        h3,
                        Text(
                          authVm.userModel?.email ?? "",
                          style: R.textStyle.helveticaBold().copyWith(
                              fontSize: 11.5.sp, color: R.colors.whiteDull),
                        ),
                        h0P9,
                        Text(
                          "${authVm.userModel?.dialCode} ${authVm.userModel?.number}",
                          style: R.textStyle.helveticaBold().copyWith(
                              fontSize: 11.5.sp, color: R.colors.whiteDull),
                        ),
                        h2,
                        GestureDetector(
                          onTap: () {
                            Get.bottomSheet(EditProfile());
                          },
                          child: Container(
                            height: Get.height * .05,
                            width: Get.width * .6,
                            decoration:
                                AppDecorations.gradientButton(radius: 30),
                            child: Center(
                              child: Text(
                                "${getTranslated(context, "edit_profile")?.toUpperCase()}",
                                style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.black,
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                h3,
                Text(
                  getTranslated(context, "account_settings") ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.whiteColor, fontWeight: FontWeight.bold),
                ),
                h1,
                Container(
                  decoration: BoxDecoration(
                      color: R.colors.blackDull,
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * .04, vertical: Get.height * .03),
                  child: Column(
                    children: [
                      tiles(0, "invite_earn", R.images.link),
                      tiles(1, "payment_status", R.images.credit,
                          isDivider: false),
                      // tiles(2, "translation", R.images.translate,isDivider:false),
                      // tiles(3, "privacy_and_sharing", R.images.pp,
                      //     isDivider: false),
                    ],
                  ),
                ),
                h3,
                Text(
                  getTranslated(context, "hosting") ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.whiteColor, fontWeight: FontWeight.bold),
                ),
                h1,
                Container(
                  decoration: BoxDecoration(
                      color: R.colors.blackDull,
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * .04, vertical: Get.height * .03),
                  child: Column(
                    children: [
                      tiles(
                          4,
                          context.read<AuthVm>().userModel?.requestStatus ==
                                  RequestStatus.host
                              ? "host_profile"
                              : "become_a_host",
                          R.images.switchToHost),
                      tiles(5, "host_support_center", R.images.ask,
                          isDivider: false),
                    ],
                  ),
                ),
                h3,
                Text(
                  getTranslated(context, "account_center") ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.whiteColor, fontWeight: FontWeight.bold),
                ),
                h1,
                Container(
                  decoration: BoxDecoration(
                      color: R.colors.blackDull,
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * .04, vertical: Get.height * .03),
                  child: Column(
                    children: [
                      tiles(6, "how_yachtmaster_works", R.images.shield),
                      tiles(7, "safety_center", R.images.shield),
                      tiles(8, "yachtmaster_support", R.images.support),
                      tiles(9, "give_us_feedback", R.images.feedback,
                          isDivider: false),
                    ],
                  ),
                ),
                h3,
                Text(
                  getTranslated(context, "legal") ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.whiteColor, fontWeight: FontWeight.bold),
                ),
                h1,
                Container(
                  decoration: BoxDecoration(
                      color: R.colors.blackDull,
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * .04, vertical: Get.height * .03),
                  child: Column(
                    children: [
                      tiles(10, "terms_of_services", R.images.shield),
                      tiles(
                        11,
                        "privacy_policy",
                        R.images.pp,
                      ),
                      tiles(
                        13,
                        "cancellation_policy",
                        R.images.cancel,
                      ),
                      tiles(14, "refund_policy", R.images.refund,
                          isDivider: false),
                    ],
                  ),
                ),
                h3,
                Container(
                  decoration: BoxDecoration(
                      color: R.colors.blackDull,
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * .04, vertical: Get.height * .02),
                  child: Column(
                    children: [
                      tiles(15, "delete_account", R.images.bin,
                          isDivider: true, isShowArrow: false),
                      tiles(12, "logout", R.images.logout,
                          isDivider: false, isShowArrow: false),
                    ],
                  ),
                ),
                h9,
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget tiles(int index, String title, String img,
      {bool isDivider = true, bool isShowArrow = true}) {
    return GestureDetector(
      onTap: () async {
        var settingsVm = Provider.of<SettingsVm>(context, listen: false);
        var authVm = Provider.of<AuthVm>(context, listen: false);
        switch (index) {
          case 0:
            Get.toNamed(InviteAndEarn.route);
            break;
          case 1:
            Get.toNamed(PaymentPayouts.route);
            break;
          case 4:
            {
              if (authVm.userModel?.requestStatus ==
                  RequestStatus.requestHost) {
                ZBotToast.showToastError(
                    message: "Please wait your request to be host in process");
              } else if (authVm.userModel?.requestStatus ==
                  RequestStatus.host) {
                Get.toNamed(HostProfile.route);
              } else {
                Get.toNamed(BecomeHost.route);
              }
              break;
            }
          case 5:
            {
              var InboxPro = Provider.of<InboxVm>(context, listen: false);
              var yachtVm = Provider.of<YachtVm>(context, listen: false);
              AdminChatHeadModel? chatHead =
                  await createChatHead(InboxPro, yachtVm);
              setState(() {});
              Get.toNamed(AdminChatView.route,
                  arguments: {"chatHeadModel": chatHead});
              // Get.toNamed(HelpCenter.route);
            }
            break;
          case 6:
            Get.toNamed(AboutApp.route);
            break;
          case 7:
            Get.toNamed(SafetyCenter.route);
            break;
          case 8:
            Get.toNamed(HelpCenter.route);
            break;
          case 9:
            Get.bottomSheet(SettingsFeedbackSheet(
              submitCallBack: (rating, desc) async {
                String docID =
                    Timestamp.now().millisecondsSinceEpoch.toString();
                AppFeedbackModel appFeedbackModel = AppFeedbackModel(
                    id: docID,
                    feedback: desc,
                    userId: FirebaseAuth.instance.currentUser?.uid,
                    rating: rating,
                    createdAt: Timestamp.now());
                try {
                  Get.back();
                  await FbCollections.appFeedBack
                      .doc(docID)
                      .set(appFeedbackModel.toJson());
                } on Exception catch (e) {
                  // TODO
                  debugPrintStack();
                  log(e.toString());
                }
              },
            ));
            break;
          case 10:
            Get.toNamed(TermsOfServices.route);
            break;
          case 11:
            Get.toNamed(PrivacyPolicy.route);
            break;
          case 12:
            Get.bottomSheet(LogoutBottomSheet(),
                barrierColor: R.colors.grey.withOpacity(.10));
            break;
          case 13:
            Get.toNamed(RulesRegulations.route, arguments: {
              "appBarTitle": settingsVm.allContent
                      .where((element) =>
                          element.type ==
                          AppContentType.cancellationPolicy.index)
                      .first
                      .title ??
                  "",
              "title": "",
              "desc": settingsVm.allContent
                      .where((element) =>
                          element.type ==
                          AppContentType.cancellationPolicy.index)
                      .first
                      .content ??
                  "",
              "textStyle": R.textStyle
                  .helvetica()
                  .copyWith(color: R.colors.whiteDull, fontSize: 14.sp)
            });
            break;
          case 14:
            Get.toNamed(RulesRegulations.route, arguments: {
              "appBarTitle": settingsVm.allContent
                      .where((element) =>
                          element.type == AppContentType.refundPolicy.index)
                      .first
                      .title ??
                  "",
              "title": "",
              "desc": settingsVm.allContent
                      .where((element) =>
                          element.type == AppContentType.refundPolicy.index)
                      .first
                      .content ??
                  "",
              "textStyle": R.textStyle
                  .helvetica()
                  .copyWith(color: R.colors.whiteDull, fontSize: 14.sp)
            });

            break;
          case 15:
            Get.bottomSheet(DeleteAccountSheet());
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

  Future<AdminChatHeadModel?> createChatHead(
      InboxVm chatVm, YachtVm yachtVm) async {
    AdminChatHeadModel? chatHeadModel;
    AdminChatHeadModel chatData = AdminChatHeadModel(
      id: FirebaseAuth.instance.currentUser?.uid,
      createdAt: Timestamp.now(),
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
          createdAt: Timestamp.now(),
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
