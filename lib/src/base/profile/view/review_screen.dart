
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/profile/model/review_model.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class ReviewScreen extends StatefulWidget {
 static String route="/reviewScreen";
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<ReviewModel> reviews=[];
  // String averageRating() {
  //   double reviewTotal = 0;
  //   reviewList.forEach((element) {
  //     reviewTotal += element.rating;
  //   });
  //   return (reviewTotal / reviewList.length).toStringAsPrecision(2).toString();
  // }

  int totalReviews = 3;
  double averageRating=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      reviews = args["reviews"];
      var settingsVm=Provider.of<SettingsVm>(context,listen: false);
      averageRating=settingsVm.averageRating(reviews);
      setState(() {});
      log("______________AEVRAGE RATING:${averageRating}");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsVm,BaseVm>(builder: (context,settingsVm, provider, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
          appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "reviews")??""),
          body:reviews.isEmpty==true?
          Center(
            child: EmptyScreen(
              title: "no_reviews",
              subtitle: "no_reviews_has_been_received_yet",
              img: R.images.noFav,
            ),
          ): SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: Get.width*.03),
              child: Column(
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${averageRating}",
                          style:  R.textStyle.helveticaBold().copyWith(
                              fontSize: 16.sp,
                              color: R.colors.yellowDark,height: 1.2,
                              fontWeight: FontWeight.bold),
                        ),
                        w1,
                        Image.asset(R.images.star,color: R.colors.yellowDark,height: Get.height*.025,),
                        w3,
                        Text(
                          "( ${reviews.length} ${getTranslated(context, "reviews")} )",
                          style: R.textStyle.helvetica().copyWith(
                              fontSize: 13.sp,
                              color: R.colors.whiteDull,height: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Get.height * .02,
                  ),
                  Column(
                    children: List.generate(
                        reviews.length, (index) {
                      ReviewModel review =reviews[index];
                      return reviewContainer(review, index,index==reviews.length-1?false:true);
                    }),
                  )
                ],
              ),
            ),
          ));
    });
  }
  Widget reviewContainer(ReviewModel review, index,bool isShowDivider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: Get.width*.03,
              vertical: Get.height*.01),
          child:  FutureBuilder(
              future: FbCollections.user.doc(review.userId).get(),
              builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {
                if(!snapshot.hasData)
                {
                  return SizedBox();
                }
                else{
                  UserModel userModel=UserModel.fromJson(snapshot.data?.data());
                  return Column(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Stack(alignment: Alignment.bottomRight,
                            children: [
                              CircularProfileAvatar(
                                "",
                                radius: 20.sp,
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
                                color: R.colors.whiteColor,fontSize: 13.sp,
                              ) ,),
                              h0P3,
                              Text(
                             "${(review.createdAt?.toDate()??now).formateDateMDY()}",style:R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteDull,fontSize: 9.sp,
                              ) ,),
                              h0P2,
                              Row(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${review.rating}",style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.yellowDark,fontSize: 8.sp,height: 1.2
                                  ),textAlign: TextAlign.justify,),
                                  w2,
                                  Image.asset(R.images.star,color: R.colors.yellowDark,scale: 22,)
                                ],
                              ),
                            ],)
                        ],
                      ),
                      h2,
                      Text(
                      review.description??  "",style:R.textStyle.helvetica().copyWith(
                        color: R.colors.whiteDull,fontSize: 10.sp,
                      ) ,),
                    ],);

                }
            }
          ),
        ),
       isShowDivider==false?SizedBox(): Divider(
          color: R.colors.grey.withOpacity(.50),
          thickness: 2,
        )
      ],
    );
  }

}
