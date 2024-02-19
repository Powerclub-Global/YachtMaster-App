// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/search/model/services_model.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HostWidget extends StatelessWidget {
  ServiceModel? service;
  bool? isFav;
   double? width,height;
  bool? isShowRating;
 Function()? isFavCallBack;
 bool? isShowStar;
  HostWidget(
      {this.service,
      this.width,
      this.height,
      this.isShowRating,
        this.isFav=false,
        this.isShowStar=false,
      this.isFavCallBack});

  @override
  Widget build(BuildContext context) {

    return Consumer<YachtVm>(
        builder: (context, yachtVm, _) {
          return SizedBox(
          width:width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(alignment: Alignment.bottomCenter,

                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                              colors:
                              [Colors.transparent,R.colors.black.withOpacity(.30)],
                              begin:Alignment.bottomCenter ,
                              end: Alignment.topCenter
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: R.colors.whiteColor
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child:CachedNetworkImage(
                                height: height,
                                width:width,
                                imageUrl: service?.images?.first??R.images.dummyDp,
                                fit: BoxFit.cover,
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    SpinKitPulse(color: R.colors.themeMud,),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                          ),
                        ),
                      ),
                      h1P5,
                      SizedBox(
                        width: Get.width*.3,
                        child: Text(
                          service?.name??"",
                          style: R.textStyle.helvetica().copyWith(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      h1,
                      Text(
                        service?.location?.city??"",
                        style: R.textStyle
                            .helvetica()
                            .copyWith(color: Colors.white, fontSize: 9.sp),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      h0P5,
                      if (isShowRating==false) SizedBox() else Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 4, right: 2),
                            child: Text(
                              "4.2",
                              style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.yellowDark,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(
                            Icons.star,
                            color: R.colors.yellowDark,
                            size: 17,
                          )
                        ],
                      ),
                    ],
                  ),
                  if (isShowStar==false || service?.createdBy==FirebaseAuth.instance.currentUser?.uid) SizedBox() else Positioned(top: 1,right: 1.w,
                      child: GestureDetector(
                        onTap:isFavCallBack,
                        child: Container(
                          margin: EdgeInsets.all(4),
                          decoration:AppDecorations.favDecoration(),
                          child: Icon(
                              isFav == false
                                  ? Icons.star_border_rounded
                                  : Icons.star,
                              size: 30,
                              color: isFav == false
                                  ? R.colors.whiteColor
                                  : R.colors.yellowDark),
                        ),
                      ))
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
