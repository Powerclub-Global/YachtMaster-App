import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/resources/dummy.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/base/profile/model/review_model.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class RatingReviewsCard extends StatefulWidget {
  ReviewModel? reviewModel;

  RatingReviewsCard({this.reviewModel});

  @override
  _RatingReviewsCardState createState() => _RatingReviewsCardState();
}

class _RatingReviewsCardState extends State<RatingReviewsCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width*.85,
      height: Get.height*.2,
      margin: EdgeInsets.only(right: 10),
      child: Stack(alignment: Alignment.bottomCenter,
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                  colors:
                  [
                    Colors.transparent,
                    R.colors.black.withOpacity(.30),
                    R.colors.black.withOpacity(.90),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child:FutureBuilder(
                future: FbCollections.charterFleet.doc(widget.reviewModel?.charterFleetDetail?.id).get(),
                builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if(!snapshot.hasData)
                  {
                    return SizedBox();
                  }
                else{
                  CharterModel charter=CharterModel.fromJson(snapshot.data?.data());
                    return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(color: R.colors.whiteColor,borderRadius: BorderRadius.circular(12)),
                        height: Get.height*.25,width: Get.width,
                       child:  CachedNetworkImage(imageUrl: charter.images?.first??
                           R.images.serviceUrl
                         ,height:Get.height*.25,
                         fit: BoxFit.cover,
                         progressIndicatorBuilder: (context, url, downloadProgress) =>
                             SpinKitPulse(color: R.colors.themeMud,),
                         errorWidget: (context, url, error) => Icon(Icons.error),
                       ),

                      ),
                    );
                  }
              }
            ),
          ),
          FutureBuilder(
              future: FbCollections.user.doc(widget.reviewModel?.userId).get(),
              builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {
                if(!snapshot.hasData)
                {
                  return SizedBox();
                }
                else{
                  UserModel userModel=UserModel.fromJson(snapshot.data?.data());
                  return Padding(
                    padding:  EdgeInsets.symmetric(horizontal: Get.width*.03,
                        vertical: Get.height*.01),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Stack(alignment: Alignment.bottomRight,
                              children: [
                                CircularProfileAvatar(
                                  "",
                                  radius: 22.sp,
                                  child:
                                  CachedNetworkImage(
                                    imageUrl:  userModel.imageUrl?? "",
                                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                                        SpinKitPulse(color: R.colors.themeMud,),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                                Image.asset(R.images.check,height: Get.height*.02,)
                              ],
                            ),
                            w2,
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                 userModel.firstName?? "",style:R.textStyle.helvetica().copyWith(
                                  color: R.colors.whiteColor,fontSize: 14.sp,
                                ) ,),
                                h0P3,
                                Text(
                                "${(widget.reviewModel?.createdAt?.toDate()??now).formateDateMDY()}",style:R.textStyle.helvetica().copyWith(
                                  color: R.colors.whiteColor,fontSize: 10.sp,
                                ) ,),
                                h0P2,
                                Row(
                                  children: [
                                    Text(
                                      "${widget.reviewModel?.rating}",style: R.textStyle.helveticaBold().copyWith(
                                        color: R.colors.yellowDark,fontSize: 10.sp
                                    ),textAlign: TextAlign.justify,),
                                    w2,
                                    Image.asset(R.images.star,color: R.colors.yellowDark,scale: 18,)
                                  ],
                                ),
                              ],)
                          ],
                        ),
                        h2,
                        Text(widget.reviewModel?.description??"",style:R.textStyle.helvetica().copyWith(
                          color: R.colors.whiteColor,fontSize: 10.sp,
                        ) ,),
                      ],),
                  );

                }
            }
          ),
        ],
      ),
    );
  }
}
