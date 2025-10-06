import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../src/base/inbox/view/inbox_view.dart';

import '../constant/constant.dart';

/// top-level function to  handle  background/terminated messages

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint('Handling a background message ');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Application extends StatefulWidget {
  final Widget page;
  const Application({super.key, required this.page});
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  bool _initialized = false;

  Future<void> requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
  }

  Future<void> _cacheFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      Constants.fcmToken = token;
      log('FCM token refreshed', name: 'FMSGHandler');
    }
  }

  handlePushNavigation(Map data) async {
    Get.to(const InboxView(), arguments: {"selectedTabIndex": 1});
  }

  Future<void> onInit() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    log("___INIT FCM");
    await requestPermissions();
    log("___REQ FCM");

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    await FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        _handleMessage(message);
      }
    });
    await _cacheFcmToken();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              priority: Priority.max,
              importance: Importance.max,
              icon: '@mipmap/launcher_icon',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    log('Handling opened push notification', name: 'FMSGHandler');
    await handlePushNavigation(message.data);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(onInit);
  }

  @override
  Widget build(BuildContext context) {
    return widget.page;
  }
}
