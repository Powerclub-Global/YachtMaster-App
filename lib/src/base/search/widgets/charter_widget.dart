
// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class CharterWidget extends StatefulWidget {
  CharterModel? charter;
  double? width;
  double? height;
  bool isSmall;
  bool isShowStar;
  bool isPopUp;
  bool isFav;
  Function()? isFavCallBack;
  CharterWidget({this.charter, this.width, this.height, this.isSmall=false,this.isShowStar=true,
  this.isPopUp=false,this.isFavCallBack,this.isFav=false});

  @override
  State<CharterWidget> createState() => _CharterWidgetState();
}

class _CharterWidgetState extends State<CharterWidget> {
  var settingsVm=Provider.of<SettingsVm>(Get.context!,listen: false);
  double averageRating=0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      averageRating=settingsVm.averageRating(settingsVm.allReviews.where((element) => element.hostId==widget.charter?.createdBy).toList());
       setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchVm,HomeVm>(
        builder: (context, provider, hvm,_) {

          return Padding(
            padding:  EdgeInsets.only(bottom: Get.height*.03),
            child: Container(
              width: widget.width,
              child: Stack(alignment: Alignment.bottomCenter,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                          colors:
                          [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.transparent,
                            R.colors.black.withOpacity(.30),
                            R.colors.black.withOpacity(.70),
                            R.colors.black.withOpacity(.90),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(
                      decoration: BoxDecoration(
                        color: R.colors.whiteColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(borderRadius: BorderRadius.circular(20),
                          child:
                          CachedNetworkImage(imageUrl:  widget.charter?.images?.first??R.images.serviceUrl,
                            height: widget.height,
                            width: widget.width,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                Padding(
                                  padding:  EdgeInsets.all(20.sp),
                                  child: SpinKitPulse(color: R.colors.themeMud,),
                                ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),

                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.1.h,
                    left:widget.isSmall==true?1.w:widget.isPopUp==true?7.w:0,right:widget.isSmall==true?1.w:widget.isPopUp==true? 7.w:0,
                    child: Padding(
                      padding:  EdgeInsets.symmetric(horizontal: Get.width*.025,vertical: Get.height*.01),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(flex:4,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.charter?.name??"",style: R.textStyle.helveticaBold().copyWith(
                                    color: R.colors.whiteDull,fontSize:widget.isSmall?11.sp: 15.sp
                                ),overflow: TextOverflow.ellipsis,),
                                h0P7,
                                Text(
                                    hvm.allBookings.where((element) => element.charterFleetDetail?.id==widget.charter?.id && element.createdBy==FirebaseAuth.instance.currentUser?.uid).isNotEmpty?
                                  "${widget.charter?.location?.adress?.trim()}":
                                  "${widget.charter?.location?.city?.trim()}"
                                  ,style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteDull,fontSize:widget.isSmall?7.sp: 12.sp
                                ),overflow: TextOverflow.ellipsis,)

                              ],),
                          ),
                          Expanded(flex:4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (averageRating.toString()=="NaN") SizedBox() else
                                  Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "$averageRating",style: R.textStyle.helveticaBold().copyWith(
                                        color: R.colors.yellowDark,fontSize:widget.isSmall?8.sp: 10.sp
                                    ),),
                                    w1,
                                    Image.asset(R.images.star,color: R.colors.yellowDark,scale:widget.isSmall?26: 22,)
                                  ],
                                ),
                                h0P7,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text("Starting: ",style: R.textStyle.helvetica().copyWith(
                                        color: R.colors.whiteColor,fontSize:widget.isSmall?7.sp: 12.sp
                                    ),),
                                    Expanded(
                                      child: Text(
                                        getStartingFromText()
                                        ,style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.yellowDark,fontSize:widget.isSmall?8.sp: 12.sp
                                      ),maxLines: 2,textAlign: TextAlign.end,),
                                    ),
                                  ],
                                ),

                              ],),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.isShowStar==false  || widget.charter?.createdBy==FirebaseAuth.instance.currentUser?.uid) SizedBox() else Positioned(top: 10,right:widget.isPopUp==true?10.w: 2.w,
                      child: GestureDetector(
                        onTap:widget.isFavCallBack,
                        child:Container(
                          decoration:AppDecorations.favDecoration(),
                          child: Icon(
                              widget.isFav == false
                                  ? Icons.star_border_rounded
                                  : Icons.star,
                              size: 30,
                              color: widget.isFav == false
                                  ? R.colors.whiteColor
                                  : R.colors.yellowDark),
                        ),
                      ))
                ],
              ),
            ),
          );
        }
    );
  }

  String getStartingFromText(){
    String text = '';
    if((widget.charter?.priceFourHours ?? 0) != 0){
      text = "\$${Helper.numberFormatter(double.parse(widget.charter?.priceFourHours?.toStringAsFixed(0)??""))}";
    }else if((widget.charter?.priceHalfDay ?? 0) != 0){
      text = "\$${Helper.numberFormatter(double.parse(widget.charter?.priceHalfDay?.toStringAsFixed(0)??""))}";
    }else if((widget.charter?.priceFullDay ?? 0) != 0){
      text = "\$${Helper.numberFormatter(double.parse(widget.charter?.priceFullDay?.toStringAsFixed(0)??""))}";
    }
    return text;
  }
}
