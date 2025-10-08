import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin.dart';
import 'package:stripe_identity_plugin/utils/enum.dart';
import 'package:yacht_master/src/base/settings/view/w9_info_screen.dart';
import 'package:yacht_master/services/firebase_auth_service.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/resources.dart';
import '../../../auth/view_model/auth_vm.dart';
import '../../search/view/bookings/view_model/bookings_vm.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../utils/zbot_toast.dart';
import '../../../../resources/decorations.dart';

import '../../../../services/firebase_collections.dart';
import '../../../../utils/helper.dart';
import '../../admin_chat/model/admin_chat_head_model.dart';
import '../../admin_chat/model/admin_chat_model.dart';
import '../../admin_chat/view/admin_chat_view.dart';
import '../../base_vm.dart';
import '../../inbox/view_model/inbox_vm.dart';
import '../../yacht/view_model/yacht_vm.dart';

class BecomeVerified extends StatefulWidget {
  static String route = "/becomeVerified";
  bool isHost;
  BecomeVerified({this.isHost = true});

  @override
  _BecomeVerifiedState createState() => _BecomeVerifiedState();
}

class _BecomeVerifiedState extends State<BecomeVerified> {
  List<String> tabsList = ["invite", "earnings"];
  int selectedTabIndex = 0;
  final stripeIdentity = StripeIdentityPlugin();
  AuthVm? vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm ??= Provider.of(context, listen: true);
  }

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
      vm!.userModel!.email!,
      vm!.userModel!.uid!,
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
          Image.asset(R.images.request, scale: 4),
          h4,
          Text(
            "Request Payouts",
            style: R.textStyle.helveticaBold().copyWith(
              color: Colors.white,
              fontSize: 16.sp,
            ),
          ),
          h2,
          SizedBox(
            width: Get.width * .85,
            child: Text(
              "In order to receive payouts from YachtMaster App you must complete a W-9 Tax form as Mandated by the Federal Tax Commission\n\nPlease verify your Identity and fill out the W-9 form in the app.",
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

          h1P5,
          GestureDetector(
            onTap: () async {
              ZBotToast.loadingShow();
              final (stripeResult, message) =
                  await initiateStripeVerification();
              switch (stripeResult) {
                case VerificationResult.completed:
                  {
                    vm?.isVerifyingForHost = false;
                    Get.to(W9InfoScreen());
                  }

                case VerificationResult.canceled:
                  Helper.inSnackBar(
                    'Error',
                    "Verification was cancelled",
                    R.colors.themeMud,
                  );
                  Get.to(W9InfoScreen());

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
    );
  }

  Future<AdminChatHeadModel?> createChatHead(
    InboxVm chatVm,
    YachtVm yachtVm,
  ) async {
    AdminChatHeadModel? chatHeadModel;
    AdminChatHeadModel chatData = AdminChatHeadModel(
      id: firebaseAuthService.currentUserId,
      lastMessage: AdminChatModel(
        message: "",
        createdAt: Timestamp.now(),
        senderId: firebaseAuthService.currentUserId,
        chatHeadId: firebaseAuthService.currentUserId,
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
        firebaseAuthService.currentUserId ?? "",
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
          id: firebaseAuthService.currentUserId,
          lastMessage: AdminChatModel(
            message: "",
            createdAt: Timestamp.now(),
            senderId: firebaseAuthService.currentUserId,
            chatHeadId: firebaseAuthService.currentUserId,
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
            firebaseAuthService.currentUserId ?? "",
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
      log("getChatHeadModel: " + e.toString());
    }
    return chatHeadModel;
  }
}
