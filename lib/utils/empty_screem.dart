import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../localization/app_localization.dart';
import '../resources/resources.dart';
import 'heights_widths.dart';

class EmptyScreen extends StatefulWidget {
  String? title;
  String? subtitle;
  String? img;

  EmptyScreen({this.title, this.subtitle, this.img});

  @override
  State<EmptyScreen> createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              widget.img??R.images.emptyBook,
              scale: 4,
            ),
            h2,
            Text(
              getTranslated(context, widget.title??"no_bookings") ?? "",
              style: R.textStyle.helveticaBold().copyWith(
                  color: Colors.white, fontSize: 13.sp),
            ),
            h2,
            Text(
              getTranslated(context,
                  widget.subtitle??"no_bookings_has_been_completed_yet") ??
                  "",
              style: R.textStyle.helvetica().copyWith(
                  color: Colors.white, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }
}
