import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../resources/resources.dart';
import 'my_loader.dart';

class ZBotToast {
  static loadingShow() async {
    BotToast.showCustomLoading(
        toastBuilder: (func) {
          return MyLoader(
            color: R.colors.themeMud,
          );
        },
        allowClick: false,
        clickClose: false,
        backgroundColor: Colors.transparent);
    Future.delayed(const Duration(seconds: 60), () => loadingClose());
  }

  static Future loadingClose() async {
    BotToast.cleanAll();
    await Future.delayed(const Duration(milliseconds: 100));
  }

    static showToastSuccess(
      {@required String? message, Duration? duration}) async {
    await loadingClose();

    BotToast.showCustomText(
        toastBuilder: (func) {
          return Column(
            children: <Widget>[
              const Spacer(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
                padding: EdgeInsets.symmetric(
                    horizontal: Get.width * 0.01, vertical: Get.height * 0.02),
                decoration: BoxDecoration(
                    color: const Color(0xff85BB65),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            message!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
        clickClose: true,
        crossPage: true,
        align: Alignment.bottomRight,
        animationReverseDuration: const Duration(seconds: 1),
        animationDuration: const Duration(seconds: 1),
        duration: duration ?? const Duration(seconds: 3));
  }

  static showToastError({required String message, Duration? duration}) async {
    await loadingClose();

    BotToast.showCustomText(
        toastBuilder: (func) {
          return Column(
            children: <Widget>[
              const Spacer(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: Get.width * 0.08),
                padding: EdgeInsets.symmetric(
                    horizontal: Get.width * 0.01, vertical: Get.height * 0.01),
                decoration: BoxDecoration(
                    color: const Color(0xFFE6532D),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.white),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Oops!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            message.contains('<!DOCTYPE ')
                                ? "Something went wrong"
                                : message,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          );
        },
        clickClose: true,
        crossPage: true,
        align: Alignment.bottomRight,
        animationReverseDuration: const Duration(seconds: 1),
        animationDuration: const Duration(seconds: 1),
        duration: duration ?? const Duration(seconds: 2));
  }
  
  static showToastSomethingWentWrong({Duration? duration}) async {
    await loadingClose();

    BotToast.showCustomText(
        toastBuilder: (func) {
          return Column(
            children: <Widget>[
              const Spacer(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                    color: const Color(0xFFE6532D),
                    borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.circle, color: Colors.white),
                    SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Oops!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(
                            'Something went wrong',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          );
        },
        clickClose: true,
        crossPage: true,
        animationReverseDuration: const Duration(seconds: 1),
        animationDuration: const Duration(seconds: 1),
        duration: duration ?? const Duration(seconds: 5));
  }
}
