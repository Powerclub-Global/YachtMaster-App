import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/breakpoint.dart';
import 'package:responsive_framework/max_width_box.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:responsive_framework/responsive_framework.dart' as condition;
import 'package:responsive_framework/responsive_scaled_box.dart';
import 'package:responsive_framework/responsive_value.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/resources.dart';
import 'package:yacht_master_admin/src/auth/vm/auth_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/chat/vm/chat_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view_model/feedback_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/picture/vm/picture_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/settings/vm/settings_vm.dart';
import 'package:yacht_master_admin/src/dashboard/vm/base_vm.dart';
import 'package:yacht_master_admin/src/landing_pages/view/splash_view.dart';

import 'src/auth/view/auth_view.dart';
import 'src/dashboard/view/base_view.dart';

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  showDialog(
    context: Get.context!,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title ?? "TITLE"),
      content: Text(body ?? "BODY"),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('Ok'),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
            // await Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => SecondScreen(payload),
            //   ),
            // );
          },
        )
      ],
    ),
  );
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
  }
  // await Navigator.push(
  //   Get.context!,
  //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  // );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAMsdps8YdyQemF6d7bDHydjY98dPpVB0I",
          authDomain: "yacht-masters.firebaseapp.com",
          projectId: "yacht-masters",
          storageBucket: "yacht-masters.appspot.com",
          messagingSenderId: "634115072396",
          appId: "1:634115072396:web:81059a7f61d6577a5536a9",
          measurementId: "G-MFSD0MFPHK"));
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthVM()),
        ChangeNotifierProvider(create: (context) => BaseVm()),
        ChangeNotifierProvider(create: (context) => UserVM()),
        ChangeNotifierProvider(create: (context) => SettingsVM()),
        ChangeNotifierProvider(create: (context) => FeedbackVm()),
        ChangeNotifierProvider(create: (context) => BookingsVm()),
        ChangeNotifierProvider(create: (context) => ChatVM()),
        ChangeNotifierProvider(create: (context) => PictureVM()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return ResponsiveBreakpoints.builder(
        breakpoints: [
          const Breakpoint(start: 1250, end: double.infinity, name: '4K'),
        ],
        child: GetMaterialApp(
          //builder: BotToastInit(),
          builder: (context, child) {
            child = BotToastInit()(context, child);
            child = MaxWidthBox(
              maxWidth: 100.w,
              background: Container(color: R.colors.white),
              child: ResponsiveScaledBox(
                  width: ResponsiveValue<double>(context, conditionalValues: [
                    condition.Condition.between(
                        start: 500, end: 700, value: 1000),
                    condition.Condition.between(
                        start: 701, end: 1500, value: 1500),
                    condition.Condition.between(
                        start: 1501, end: 5000, value: 2000),
                  ]).value,
                  child: child),
            );
            return child;
          },
          title: "YACHTMASTER",
          navigatorObservers: [BotToastNavigatorObserver()],
          scrollBehavior: MyCustomScrollBehavior(),
          fallbackLocale: const Locale('en', 'US'),
          supportedLocales: const [
            Locale('en', 'US'),
          ],
          debugShowCheckedModeBanner: false,
          initialRoute: SplashView.route,
          getPages: [
            GetPage(name: "/", page: () => const SplashView()),
            GetPage(name: SplashView.route, page: () => const SplashView()),
            GetPage(name: AuthView.route, page: () => const AuthView()),
            GetPage(
                name: DashboardView.route, page: () => const DashboardView()),
          ],
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
        ),
      );
    });
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
