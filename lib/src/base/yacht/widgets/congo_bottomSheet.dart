import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/resources.dart';

class Congoratulations extends StatefulWidget {
  final String mesg;
   Function() callBack;
  Congoratulations(this.mesg,this.callBack);
  @override
  _CongoratulationsState createState() =>
      _CongoratulationsState();
}

class _CongoratulationsState extends State<Congoratulations> {
  @override
  void initState() {
    widget.callBack();
    // TODO: implement initState
    super.initState();
    // startTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height * .28,
      decoration: new BoxDecoration(
        color: R.colors.black,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          topLeft: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: Get.height * .02, horizontal: Get.width * .07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: Get.height * .09,
              child: Image.asset(
                R.images.checkmark,
              ),
            ),
            SizedBox(
              height: Get.height * .02,
            ),
            Text(getTranslated(context, "congratulations")??"",
                style: R.textStyle.helveticaBold().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: Get.width * .043)),
            SizedBox(
              height: Get.height * .01,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * .03),
              child: Text(
                widget.mesg,
                style: R.textStyle.helvetica().copyWith(
                  color: Colors.white,
                  fontSize: Get.width * .04,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}