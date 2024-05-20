// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/favourites/view/favourite_view.dart';
import 'package:yacht_master/src/base/home/view/home_screen.dart';
import 'package:yacht_master/src/base/inbox/view/inbox_view.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view/search_screen.dart';
import 'package:yacht_master/src/base/settings/view/settings_view.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/widgets/exit_sheet.dart';
import 'package:yacht_master/utils/zbot_toast.dart';

class BaseView extends StatefulWidget {
  static String route = "/baseViewScreen";
  const BaseView({Key? key}) : super(key: key);

  @override
  _BaseViewState createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ZBotToast.loadingShow();
      
      var bookingsVm = Provider.of<BookingsVm>(Get.context!, listen: false);
      await bookingsVm.fetchAppUrls();
      if (bookingsVm.appUrlModel?.is_enable_permission_dialog == true) {
        await takePhotosNotificationsPermissions();
      }
      var baseVm = Provider.of<BaseVm>(context, listen: false);
      var authVm = Provider.of<AuthVm>(context, listen: false);
      await baseVm.fetchData();
      await authVm.fetchUser();
      baseVm.selectedPage = -1;
      baseVm.isHome = true;
      baseVm.update();
      ZBotToast.loadingClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthVm, BaseVm>(builder: (context, authVm, provider, _) {
      return WillPopScope(
        onWillPop: () async {
          Get.bottomSheet(
              SureBottomSheet(
                title: "Exit App",
                subTitle: getTranslated(
                    context, "are_you_sure_you_want_to_exit_the_app"),
                yesCallBack: () {
                  exit(0);
                },
              ),
              barrierColor: R.colors.grey.withOpacity(.20));
          return false;
        },
        child: Scaffold(
            backgroundColor: R.colors.black,
            body: provider.selectedPage == -1 && provider.isHome
                ? SearchScreen()
                : provider.selectedPage == 0
                    ? HomeView()
                    : provider.selectedPage == 1
                        ? FavouritesView()
                        : provider.selectedPage == 2
                            ? InboxView()
                            : provider.selectedPage == 3
                                ? SettingsView()
                                : Container(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: GestureDetector(
                onTap: () async {
                  provider.isHome = true;
                  provider.selectedPage = -1;
                  provider.update();
                },
                child: Image.asset(
                  R.images.center,
                  height: Get.height * .075,
                )),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                  color: Color(0xff171717),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(provider.bottomIcons.length, (index) {
                  return bottomTabs(
                      index, provider.bottomIcons[index], provider);
                }),
              ),
            )),
      );
    });
  }

  Widget bottomTabs(int index, String img, BaseVm vm) {
    return Expanded(
      child: Consumer<SettingsVm>(builder: (context, settingsVm, _) {
        return InkWell(
          onTap: () {
            vm.selectedPage = index;
            vm.update();
          },
          child: Padding(
            padding: EdgeInsets.only(
                left: index == 1 && settingsVm.selectedLang == 2
                    ? Get.width * .09
                    : index == 2 && settingsVm.selectedLang != 2
                        ? Get.width * .09
                        : 0,
                right: index == 2 && settingsVm.selectedLang == 2
                    ? 9.w
                    : index == 1 && settingsVm.selectedLang != 2
                        ? Get.width * .09
                        : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (vm.selectedPage == index)
                  Image.asset(
                    R.images.indicator,
                    height: Get.height * .007,
                  )
                else
                  SizedBox(height: Get.height * .007),
                Padding(
                  padding: EdgeInsets.only(
                    top: Get.height * .025,
                    bottom: Get.height * .025,
                  ),
                  child: vm.selectedPage == index
                      ? ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(colors: [
                              R.colors.gradMud,
                              R.colors.gradMudLight
                            ]).createShader(bounds);
                          },
                          blendMode: BlendMode.srcATop,
                          child: Image.asset(
                            img,
                            height: Get.height * .03,
                          ))
                      : Image.asset(
                          img,
                          height: Get.height * .03,
                          color: index == 0 ? R.colors.charcoalColor : null,
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  takePhotosNotificationsPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isNotificationAllowed = false;
    bool? isGalleryAllowed = false;
    isNotificationAllowed = prefs.getBool("isNotificationAllowed");
    isGalleryAllowed = prefs.getBool("isGalleryAllowed");
    log("SHARED_________${isNotificationAllowed}___${isGalleryAllowed}");
    if (isNotificationAllowed == false || isNotificationAllowed == null) {
      await checkPermissionNotifications();
    }
    if (isGalleryAllowed == false || isGalleryAllowed == null) {
      await checkPermissionPhotos();
    }
  }

  checkPermissionNotifications() async {
    var status = await Permission.notification.status;
    debugPrint(status.toString());
    switch (status) {
      case PermissionStatus.denied:
        log("+++++++++++++++++++++++++denied");
        Permission.notification.request();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Allow Notifications'),
                content: Text('Allow Permission for notifications？'),
                actions: [
                  CupertinoButton(
                    child: Center(
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    onPressed: () async {
                      await Permission.notification.request();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("isNotificationAllowed", true);
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Center(
                      child: Text('No'),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
        break;
      case PermissionStatus.granted:
        log("+++++++++++++++++++++Permission granted");
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Allow Permissions'),
                content: Text('Allow Permission for notifications？'),
                actions: [
                  CupertinoButton(
                    child: Center(
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    onPressed: () async {
                      await Permission.notification.request();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("isNotificationAllowed", true);
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Center(
                      child: Text('No'),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
        break;
      case PermissionStatus.permanentlyDenied:
        log("+++++++++++++++++++++permanently denied");
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Allow Permissions'),
                content: Text('Allow Permission for notifications？'),
                actions: [
                  CupertinoButton(
                    child: Center(
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    onPressed: () async {
                      await Permission.notification.request();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("isNotificationAllowed", true);
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Center(
                      child: Text('No'),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
        break;
      case PermissionStatus.restricted:
        openAppSettings();
        log("+++++++++++++++++++++++restricted");
        break;
      case PermissionStatus.limited:
        openAppSettings();
        log("+++++++++++++++++++++++++limited");
        break;
      default:
        {
          Permission.notification.request();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("isNotificationAllowed", true);
        }
    }
  }

  checkPermissionPhotos() async {
    var status = await Permission.photos.status;
    debugPrint(status.toString());
    switch (status) {
      case PermissionStatus.denied:
        log("+++++++++++++++++++++++++denied");
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Allow Access to Photos'),
                content: Text('Allow Permission to access photo/gallery？'),
                actions: [
                  CupertinoButton(
                    child: Center(
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    onPressed: () async {
                      await Permission.photos.request();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("isGalleryAllowed", true);
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Center(
                      child: Text('No'),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
        break;
      case PermissionStatus.granted:
        log("+++++++++++++++++++++Permission granted");
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Allow Access to Photos'),
                content: Text('Allow Permission to access photo/gallery？'),
                actions: [
                  CupertinoButton(
                    child: Center(
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    onPressed: () async {
                      await Permission.photos.request();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("isGalleryAllowed", true);
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Center(
                      child: Text('No'),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
        break;
      case PermissionStatus.permanentlyDenied:
        log("+++++++++++++++++++++permanently denied");
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Allow Access to Photos'),
                content: Text('Allow Permission to access photo/gallery？'),
                actions: [
                  CupertinoButton(
                    child: Center(
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    onPressed: () async {
                      await Permission.notification.request();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("isGalleryAllowed", true);
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Center(
                      child: Text('No'),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
        break;
      case PermissionStatus.restricted:
        openAppSettings();
        log("+++++++++++++++++++++++restricted");
        break;
      case PermissionStatus.limited:
        openAppSettings();
        log("+++++++++++++++++++++++++limited");
        break;
      default:
        {
          Permission.photos.request();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("isGalleryAllowed", true);
        }
    }
  }
}
