import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/src/auth/view/login.dart';

import '../../../../../../../resources/resources.dart';
import '../../../../../../../utils/heights_widths.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/decorations.dart';
import '../../../../services/firebase_collections.dart';
import '../../../../utils/validation.dart';
import '../../../../utils/zbot_toast.dart';
import '../../../auth/view_model/auth_vm.dart';

class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({Key? key}) : super(key: key);

  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  bool isObscure = true;
  TextEditingController passwordC = TextEditingController();
  FocusNode passwordFN = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthVm>(builder: (context, vm, _) {
      return GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {

          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: R.colors.black,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(26))),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                h3,
                Image.asset(
                  R.images.bin,
                  scale: 2,color: R.colors.whiteColor,
                ),
                h3,
                Text(
                  getTranslated(context,"delete_account")??"",
                  style: R.textStyle
                      .helveticaBold()
                      .copyWith(color: R.colors.whiteColor, fontSize: 16.sp),
                ),
                h2,
                Text(
                  getTranslated(context,"delete_account_desc")??"",
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.whiteDull,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),

                h5,
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          height: Get.height * .055,
                          width: Get.width * .8,
                          margin: EdgeInsets.only(bottom: Get.height * .015),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: R.colors.blueGrey),
                          child: Center(
                            child: Text(
                              "${getTranslated(context, "no")?.toUpperCase()}",
                              style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.black,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await onTapDeleteFN(vm);
                        },
                        child: Container(
                          height: Get.height * .055,
                          width: Get.width * .8,
                          margin: EdgeInsets.only(bottom: Get.height * .015),
                          decoration: AppDecorations.gradientButton(radius: 30),
                          child: Center(
                            child: Text(
                              "${getTranslated(context, "yes")?.toUpperCase()}",
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

                h2,
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> onTapDeleteFN(AuthVm vm) async {
    if (vm.userModel?.isSocialLogin ?? false) {
      await deleteUserAccount(isSocialLogin:true);
    } else {
      await deleteUserAccount();
    }
  }
  Future<void> deleteUserAccount({bool isSocialLogin=false}) async {
    try {
      AuthVm vm=Provider.of(context,listen: false);
      if (FirebaseAuth.instance.currentUser != null || isSocialLogin==true) {
        await FirebaseAuth.instance.currentUser!.delete();
        await FbCollections.user
            .doc(vm.userModel?.uid)
            .update({"status": UserStatus.deleted.index});
        await vm.logoutUser(isUpdateUser: false);
        Get.offAllNamed(LoginScreen.route);
        ZBotToast.showToastSuccess(message:getTranslated(context,"user_has_been_deleted_successfully"));

        ZBotToast.loadingClose();
      }
      else{
        await reAuthenticateAndDelete();
      }

    } on FirebaseAuthException catch (e) {
      log(e.toString());

      if (e.code == "requires-recent-login") {
        await reAuthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
      ZBotToast.loadingClose();
      debugPrint(e.toString());
      if(e.toString().contains("The given sign-in provider is disabled for this Firebase project"))
      {
        ZBotToast.showToastError(message: "Kindly login again to complete the process");

      }
      else{
        ZBotToast.showToastError(message: e.toString().split('] ').last);

      }
    }
  }
  Future reAuthenticateAndDelete() async {
    try {
      AuthVm vm=Provider.of(context,listen: false);

      ZBotToast.loadingShow();
      UserCredential? credentials=  await FirebaseAuth.instance.currentUser?.reauthenticateWithProvider(PhoneAuthProvider());

      if (credentials!.user != null) {
        await FbCollections.user
            .doc(vm.userModel?.uid)
            .update({"status": UserStatus.deleted.index});
        FirebaseAuth.instance.currentUser!.delete();
        Get.offAllNamed(LoginScreen.route);
        await vm.logoutUser(isUpdateUser: false);
        ZBotToast.showToastSuccess(message: getTranslated(context,"user_has_been_deleted_successfully"));

        ZBotToast.loadingClose();
        return true;
      }
      ZBotToast.loadingClose();
    } catch (e) {
      ZBotToast.loadingClose();
      debugPrint(e.toString());
      if(e.toString().contains("The given sign-in provider is disabled for this Firebase project"))
        {
          ZBotToast.showToastError(message: "Kindly login again to complete the process");

        }
      else{
        ZBotToast.showToastError(message: e.toString().split('] ').last);

      }
      return null;
    }
  }


}
