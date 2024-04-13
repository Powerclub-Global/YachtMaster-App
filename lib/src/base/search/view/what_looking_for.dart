import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/model/charters_day_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/search/view/when_will_be_there.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class WhatLookingFor extends StatefulWidget {
  static String route = "/whatLookingFor";

  @override
  _WhatLookingForState createState() => _WhatLookingForState();
}

class _WhatLookingForState extends State<WhatLookingFor> {
  String? cityModel;
  bool? isReserve;
  CharterModel? yacht;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log("______WhatLookingFor");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      setState(() {
        cityModel = args["cityModel"];
        isReserve = args["isReserve"];
        yacht = args["yacht"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchVm>(builder: (context, provider, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleSpacing: 0,
          leading: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: R.colors.whiteColor,
                size: 20,
              )),
          title: Text(getTranslated(context, "search") ?? "",
              style: R.textStyle
                  .helvetica()
                  .copyWith(color: Colors.grey, fontSize: 14.sp)),
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              Helper.focusOut(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: R.colors.black,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  h3,
                  Text(getTranslated(context, "what_are_you_looking_for") ?? "",
                      style: R.textStyle
                          .helveticaBold()
                          .copyWith(color: Colors.white, fontSize: 16.sp)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * .07),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        h2P5,
                        Text(
                          cityModel ?? "",
                          style: R.textStyle.helveticaBold().copyWith(
                                color: R.colors.whiteDull,
                                fontSize: 15.sp,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        h5,
                        Column(
                          children: [
                            Column(
                                children: List.generate(
                                    provider.charterDayList.length, (index) {
                              return chartersCard(
                                  provider.charterDayList[index], provider);
                            })),
                          ],
                        ),
                        h2,
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget chartersCard(CharterDayModel city, SearchVm provider) {
    return GestureDetector(
      onTap: () {
        provider.selectedCharterDayType = city;
        provider.update();
        var bookingsVm = Provider.of<BookingsVm>(context, listen: false);
        bookingsVm.bookingsModel = BookingsModel();
        bookingsVm.update();
        log("______CITY:${cityModel}");
        Get.toNamed(WhenWillBeThere.route, arguments: {
          "cityModel": cityModel,
          "yacht": yacht,
          "isSelectTime": false,
          "isReserve": isReserve,
          "bookingsModel": null,
        });
      },
      child: Container(
        decoration: BoxDecoration(
            color: R.colors.blackDull, borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.only(bottom: Get.height * .015),
        padding: EdgeInsets.symmetric(
            horizontal: Get.width * .03, vertical: Get.height * .01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.title,
                  style: R.textStyle
                      .helveticaBold()
                      .copyWith(color: R.colors.whiteColor, fontSize: 14.sp),
                ),
                h0P7,
                Text(
                  city.subTitle,
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.whiteDull,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            w4,
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  city.img,
                  height: Get.height * .09,
                )),
          ],
        ),
      ),
    );
  }
}
