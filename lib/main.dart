import 'dart:async';
import 'dart:developer';
import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/blocs/bloc_exports.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/services/fmsg_handler.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/auth/view/create_username.dart';
import 'package:yacht_master/src/auth/view/login.dart';
import 'package:yacht_master/src/auth/view/sign_up.dart';
import 'package:yacht_master/src/auth/view/social_signup.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/admin_chat/view/admin_chat_view.dart';
import 'package:yacht_master/src/base/admin_chat/vm/admin_chat_vm.dart';
import 'package:yacht_master/src/base/base_view.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/favourites/view_model/favourites_vm.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/home/view/help_center.dart';
import 'package:yacht_master/src/base/home/view/home_screen.dart';
import 'package:yacht_master/src/base/home/view/previous_bookings.dart';
import 'package:yacht_master/src/base/inbox/view/chat.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/src/base/profile/view/host_profile.dart';
import 'package:yacht_master/src/base/profile/view/host_profile_others.dart';
import 'package:yacht_master/src/base/profile/view/review_screen.dart';
import 'package:yacht_master/src/base/profile/view/user_profile.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/add_credit_card.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/bookings_detail_customer.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/host_booking_detail.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/pay_with_crypto.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/pay_with_wallet.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/payments_methods.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/split_payment.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/tip_payment_methods.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/yacht_reserve_payment.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view/search_screen.dart';
import 'package:yacht_master/src/base/search/view/search_see_all.dart';
import 'package:yacht_master/src/base/search/view/see_all_host.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/search/view/when_will_be_there.dart';
import 'package:yacht_master/src/base/search/view/what_looking_for.dart';
import 'package:yacht_master/src/base/search/view/where_going.dart';
import 'package:yacht_master/src/base/search/view/whos_coming.dart';
import 'package:yacht_master/src/base/settings/view/about_app.dart';
import 'package:yacht_master/src/base/settings/view/ask_a_superhost.dart';
import 'package:yacht_master/src/base/settings/view/become_a_host.dart';
import 'package:yacht_master/src/base/settings/view/become_verified.dart';
import 'package:yacht_master/src/base/settings/view/invite_earn/invite_earn.dart';
import 'package:yacht_master/src/base/settings/view/invite_earn/withdraw_money.dart';
import 'package:yacht_master/src/base/settings/view/payment_payouts.dart';
import 'package:yacht_master/src/base/settings/view/privacy_policy.dart';
import 'package:yacht_master/src/base/settings/view/privacy_sharing.dart';
import 'package:yacht_master/src/base/settings/view/safety_center.dart';
import 'package:yacht_master/src/base/settings/view/settings_view.dart';
import 'package:yacht_master/src/base/settings/view/terms_of_services.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/yacht/view/add_charter_fleet.dart';
import 'package:yacht_master/src/base/yacht/view/add_services.dart';
import 'package:yacht_master/src/base/yacht/view/add_yacht_for_sale.dart';
import 'package:yacht_master/src/base/yacht/view/define_availibility.dart';
import 'package:yacht_master/src/base/yacht/view/charter_detail.dart';
import 'package:yacht_master/src/base/yacht/view/rules_regulations.dart';
import 'package:yacht_master/src/base/yacht/view/service_detail.dart';
import 'package:yacht_master/src/base/yacht/view/yacht_detail.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/src/base/yacht/widgets/choose_services.dart';
import 'package:yacht_master/src/base/yacht/widgets/view_all_services.dart';
import 'package:yacht_master/src/landing_page/view/splash_view.dart';
import 'package:yacht_master/src/landing_page/view_model/landing_vm.dart';
import 'package:yacht_master/utils/no_internet_screen.dart';

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

bool isLogin = false;
void main() async {
  // BindingBase.debugZoneErrorsAreFatal = true;
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

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
  await FirebaseMessaging.instance.getAPNSToken().then((value) => print(value));
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  final storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());
  HydratedBlocOverrides.runZoned(
      () => runApp(MultiProvider(providers: [
            ChangeNotifierProvider(create: (_) => LandingVm()),
            ChangeNotifierProvider(create: (_) => AuthVm()),
            ChangeNotifierProvider(create: (_) => SearchVm()),
            ChangeNotifierProvider(create: (_) => SettingsVm()),
            ChangeNotifierProvider(create: (_) => BaseVm()),
            ChangeNotifierProvider(create: (_) => HomeVm()),
            ChangeNotifierProvider(create: (_) => YachtVm()),
            ChangeNotifierProvider(create: (_) => InboxVm()),
            ChangeNotifierProvider(create: (_) => FavouritesVm()),
            ChangeNotifierProvider(create: (_) => BookingsVm()),
            ChangeNotifierProvider(create: (_) => AdminChatVM()),
          ], child: MyApp())),
      storage: storage);
}

String? publishableKey;
String? secretKey;
Future<FirebaseRemoteConfig> setupRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  print("fetch kar rha bro .....hahahaha");
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 10),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  print("kyaa error yahan hai");
  await remoteConfig.fetchAndActivate();
  print("yaan phir yahan hai");

  publishableKey = remoteConfig.getString("publishable_key");
  secretKey = remoteConfig.getString("secret_key");
  print("THIS IS SECRET $publishableKey");
  Stripe.merchantIdentifier = 'any string works';
  Stripe.publishableKey = publishableKey ?? "";
  await Stripe.instance.applySettings();
  RemoteConfigValue(null, ValueSource.valueStatic);
  return remoteConfig;
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findRootAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  String connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return null;
    }

    return _updateConnectionStatus(result);
  }

  _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        {}
        break;
      case ConnectivityResult.mobile:
        {}
        break;
      case ConnectivityResult.none:
        {
          Get.toNamed(NoInternetScreen.route);
        }
        setState(() => connectionStatus = result.toString());
        break;
      default:
        break;
    }
  }

  void startConnectionStream() {
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    var p = Provider.of<AuthVm>(context, listen: false);
    log("__________________________STATYE:$state");

    switch (state) {
      case AppLifecycleState.resumed:
        log("resumed");
        if (p.userModel?.uid != null) {
          p.userModel?.isActiveUser = true;
          await p.updateUser(p.userModel!);
        }
        break;
      case AppLifecycleState.detached:
        log("detached");
        break;
      case AppLifecycleState.inactive:
        log("inactive");
        if (p.userModel?.uid != null) {
          p.userModel?.isActiveUser = false;
          await p.updateUser(p.userModel!);
        }
        break;
      case AppLifecycleState.paused:
        log("paused");
        break;
      case AppLifecycleState.hidden:
        log("hidden");
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    connectivitySubscription.cancel();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await setupRemoteConfig();
      startConnectionStream();
    });
    setLocale(const Locale("en"));
    super.initState();
  }

  readPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLogin = prefs.getBool("loginEmail") ?? false;
    print(isLogin);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light),
    );
    return Sizer(builder: (context, orientation, deviceType) {
      return BlocProvider(
        create: (context) => CitiesBloc(),
        child: GetMaterialApp(
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          locale: _locale,
          fallbackLocale: const Locale('en', 'US'),
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'SA'),
          ],
          localeResolutionCallback:
              (Locale? deviceLocale, Iterable<Locale> supportedLocales) {
            for (var locale in supportedLocales) {
              if (locale.languageCode == deviceLocale?.languageCode &&
                  locale.countryCode == deviceLocale?.countryCode) {
                return deviceLocale;
              }
            }
            return supportedLocales.first;
          },
          debugShowCheckedModeBanner: false,
          home: Application(
            page: SplashScreen(),
          ),
          getPages: [
            GetPage(name: InviteAndEarn.route, page: () => InviteAndEarn()),
            GetPage(name: BecomeHost.route, page: () => BecomeHost()),
            GetPage(name: BecomeVerified.route, page: () => BecomeVerified()),
            GetPage(name: AdminChatView.route, page: () => AdminChatView()),
            GetPage(name: PayWithCrypto.route, page: () => PayWithCrypto()),
            GetPage(name: PayWithWallet.route, page: () => PayWithWallet()),
            GetPage(name: WithdrawMoney.route, page: () => WithdrawMoney()),
            GetPage(name: CreateUsername.route, page: () => CreateUsername()),
            GetPage(
                name: NoInternetScreen.route, page: () => NoInternetScreen()),
            GetPage(
                name: HostBookingDetail.route, page: () => HostBookingDetail()),
            GetPage(name: PaymentPayouts.route, page: () => PaymentPayouts()),
            GetPage(name: BookingsDetail.route, page: () => BookingsDetail()),
            GetPage(name: AllBookings.route, page: () => AllBookings()),
            GetPage(name: SplitPayment.route, page: () => SplitPayment()),
            GetPage(name: WhosComing.route, page: () => WhosComing()),
            GetPage(name: WhenWillBeThere.route, page: () => WhenWillBeThere()),
            GetPage(name: WhatLookingFor.route, page: () => WhatLookingFor()),
            GetPage(name: WhereGoing.route, page: () => WhereGoing()),
            GetPage(name: SplashScreen.route, page: () => SplashScreen()),
            GetPage(name: LoginScreen.route, page: () => LoginScreen()),
            GetPage(name: SignUpScreen.route, page: () => SignUpScreen()),
            GetPage(name: SearchScreen.route, page: () => SearchScreen()),
            GetPage(name: BaseView.route, page: () => BaseView()),
            GetPage(name: HomeView.route, page: () => HomeView()),
            GetPage(name: AllBookings.route, page: () => AllBookings()),
            GetPage(name: HelpCenter.route, page: () => HelpCenter()),
            GetPage(name: CharterDetail.route, page: () => CharterDetail()),
            GetPage(
                name: YachtReservePayment.route,
                page: () => YachtReservePayment()),
            GetPage(name: SettingsView.route, page: () => SettingsView()),
            GetPage(name: UserProfile.route, page: () => UserProfile()),
            GetPage(name: ChatView.route, page: () => ChatView()),
            GetPage(name: PaymentMethods.route, page: () => PaymentMethods()),
            GetPage(name: AddCreditCard.route, page: () => AddCreditCard()),
            GetPage(name: PrivacySharing.route, page: () => PrivacySharing()),
            GetPage(name: HostProfile.route, page: () => HostProfile()),
            GetPage(name: AddServices.route, page: () => AddServices()),
            GetPage(
                name: AddfeaturedCharters.route,
                page: () => AddfeaturedCharters()),
            GetPage(name: ChooseServices.route, page: () => ChooseServices()),
            GetPage(name: AddYachtForSale.route, page: () => AddYachtForSale()),
            GetPage(name: AskSuperHost.route, page: () => AskSuperHost()),
            GetPage(name: PrivacyPolicy.route, page: () => PrivacyPolicy()),
            GetPage(name: TermsOfServices.route, page: () => TermsOfServices()),
            GetPage(name: SafetyCenter.route, page: () => SafetyCenter()),
            GetPage(name: AboutApp.route, page: () => AboutApp()),
            GetPage(name: ServiceDetail.route, page: () => ServiceDetail()),
            GetPage(
                name: RulesRegulations.route, page: () => RulesRegulations()),
            GetPage(
                name: HostProfileOthers.route, page: () => HostProfileOthers()),
            GetPage(name: YachtDetail.route, page: () => YachtDetail()),
            GetPage(name: ReviewScreen.route, page: () => ReviewScreen()),
            GetPage(
                name: DefineAvailibility.route,
                page: () => DefineAvailibility()),
            GetPage(name: SearchSeeAll.route, page: () => SearchSeeAll()),
            GetPage(name: ViewAllServices.route, page: () => ViewAllServices()),
            GetPage(name: SeeAllHost.route, page: () => SeeAllHost()),
            GetPage(name: SocialSignup.route, page: () => SocialSignup()),
            GetPage(
                name: TipPaymentMethods.route, page: () => TipPaymentMethods())
          ],
          title: "YachtMaster App",
        ),
      );
    });
  }
}
