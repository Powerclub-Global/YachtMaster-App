import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/resources/text_style.dart';
import 'package:yacht_master/utils/helper.dart';


class NoInternetScreen extends StatefulWidget {
  static String route="/noInternetScreen";
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  _NoInternetScreenState createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool isChecking = false;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

   initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      setState(() {
        isChecking = true;
      });
      result = await _connectivity.checkConnectivity();
      setState(() {
        isChecking = false;
      });
    } on PlatformException catch (e) {
      //  print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

   _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        {
          Get.back();
          Helper.inSnackBar(
              "Connectivity" ,
              "Connection Restored",
              R.colors.themeMud);
        }
        break;
      case ConnectivityResult.mobile:
        {
          Get.back();
          Helper.inSnackBar(
              "Connectivity" ,
              "Connection Restored",
              R.colors.themeMud);
        }
        break;
      case ConnectivityResult.none:
        Helper.inSnackBar(
            "Connectivity" ,
            "No Internet Connection",
            R.colors.themeMud);

        break;
      // setState(() => _connectionStatus = result.toString());
      // break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
    log(result.toString());
    log(_connectionStatus);
  }

  void startConnectionStream() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<bool> checkBeforeGoingBack() async {
    ConnectivityResult result;
    result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  void initState() {
    initConnectivity();
    startConnectionStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: checkBeforeGoingBack,
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.5),
        body: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(
              vertical: Get.height * 0.27, horizontal: Get.width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  noInternetWidget(scale: 1.5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.07),
                    //  alignment: Alignment.topCenter,
                    width: Get.width,
                    child: Text(
                      "No Internet Connection",
                      style: TextStyle(
                          fontSize: Get.width * 0.045,
                          fontFamily: 'monts',
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              if (isChecking) SizedBox(
                      height: 50,
                      width: 50,
                      child: SpinKitPulse(color: R.colors.themeMud,),
                    ) else _retryButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _retryButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
              backgroundColor: MaterialStateProperty.all(R.colors.themeMud),
            ),
            onPressed: () {
              initConnectivity();
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
                child: Text("Retry",
                    style: AppTextStyle.poppinsMedium()
                        .copyWith(color: R.colors.whiteColor))),
          ),
        ],
      ),
    );
  }

  Widget noInternetWidget({double? scale}) {
    return Icon(
      Icons.warning_rounded,
      color: R.colors.themeMud,
      size: 100,
    );
    /* Center(
        child: Image.asset(
      AppImages.messageImage,
      scale: scale,
    ));*/
  }
}
