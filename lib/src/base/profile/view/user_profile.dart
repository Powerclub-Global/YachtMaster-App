import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/home/view/previous_bookings.dart';
import 'package:yacht_master/src/base/profile/view/review_screen.dart';
import 'package:yacht_master/src/base/profile/widgets/edit_profile_bottomsheet.dart';
import 'package:yacht_master/src/base/yacht/widgets/rating_reviews_card.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';

import '../../../auth/view_model/auth_vm.dart';

class UserProfile extends StatefulWidget {
  static String route = "/userProfile";
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeVm,BaseVm, AuthVm>(builder: (context, homeVm,provider, authVm, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: Get.width,
                    height: Get.height,
                    padding: EdgeInsets.only(bottom: 1),
                    decoration: BoxDecoration(
                      color: R.colors.grey,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                                colors: [
                              Colors.transparent,
                              R.colors.black.withOpacity(.02),
                              R.colors.black.withOpacity(.02),
                              R.colors.black.withOpacity(.85),
                              R.colors.black,
                            ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)
                            .createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                        child:
                        CachedNetworkImage(
                          imageUrl:  authVm.userModel?.imageUrl?.isEmpty==true || authVm.userModel?.imageUrl==null?
                          R.images.dummyDp:authVm.userModel?.imageUrl??"",
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              SpinKitPulse(color: R.colors.themeMud,),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),

                      ),
                    ),
                  ),
                  Positioned(
                    top: Get.height * .05,
                    left: Get.width * .05,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      h2,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            authVm.userModel?.firstName ?? "",
                            style: R.textStyle.helveticaBold().copyWith(
                                color: R.colors.whiteColor,
                                fontSize: 17.sp,
                                height: 1.6),
                          ),
                          w2,
                          Image.asset(
                            R.images.check,
                            height: Get.height * .035,
                          )
                        ],
                      ),
                      h1,
                      Text(
                        authVm.userModel?.email ?? "",
                        style: R.textStyle.helvetica().copyWith(
                            fontSize: 14.sp, color: R.colors.whiteDull),
                      ),
                      h0P9,
                      Text(
                        "${authVm.userModel?.dialCode} ${authVm.userModel?.number}",
                        style: R.textStyle.helvetica().copyWith(
                            fontSize: 12.sp, color: R.colors.whiteDull),
                      ),
                      h3,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                "12",
                                style: R.textStyle.helveticaBold().copyWith(
                                    color: R.colors.whiteColor,
                                    fontSize: 17.sp,
                                    fontStyle: FontStyle.italic),
                              ),
                              h1,
                              Text(
                                getTranslated(context, "fleet") ?? "",
                                style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteDull, fontSize: 12.sp),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(AllBookings.route);
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                children: [
                                  Text(
                                    "${homeVm.allBookings.where((element) => element.createdBy==FirebaseAuth.instance.currentUser?.uid).toList().length}",
                                    style: R.textStyle.helveticaBold().copyWith(
                                        color: R.colors.whiteColor,
                                        fontSize: 17.sp,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  h1,
                                  Text(
                                    getTranslated(context, "bookings") ?? "",
                                    style: R.textStyle.helvetica().copyWith(
                                        color: R.colors.whiteDull,
                                        fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(ReviewScreen.route);
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "4.6",
                                        style: R.textStyle
                                            .helveticaBold()
                                            .copyWith(
                                                color: R.colors.gradMud,
                                                fontSize: 15.sp,
                                                height: 1.3),
                                      ),
                                      w1,
                                      Image.asset(
                                        R.images.star,
                                        height: Get.height * .023,
                                        color: R.colors.yellowDark,
                                      )
                                    ],
                                  ),
                                  h1,
                                  Text(
                                    getTranslated(context, "reviews") ?? "",
                                    style: R.textStyle.helvetica().copyWith(
                                        color: R.colors.whiteDull,
                                        fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      h3,
                    ],
                  ),
                ],
              ),
            ),
            h3,
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  GeneralWidgets.seeAllWidget(context, "rating_and_reviews",
                      onTap: () {
                    Get.toNamed(ReviewScreen.route);
                  }, isSeeAll: provider.reviews.isEmpty ? false : true),
                  h2,
                  if (provider.reviews.isEmpty == true)
                    Expanded(
                      child: EmptyScreen(
                        title: "no_reviews",
                        subtitle: "no_reviews_has_been_received_yet",
                        img: R.images.noFav,
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.only(left: Get.width * .05),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children:
                                List.generate(provider.reviews.length, (index) {
                          return RatingReviewsCard(
                            reviewModel: provider.reviews[index],
                          );
                        })),
                      ),
                    ),
                ],
              ),
            ),
            h2,
          ],
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            Get.bottomSheet(EditProfile());
          },
          child: Container(
            height: Get.height * .06,
            margin: EdgeInsets.symmetric(
                horizontal: Get.width * .1, vertical: Get.height * .01),
            decoration: AppDecorations.gradientButton(radius: 30),
            child: Center(
              child: Text(
                "${getTranslated(context, "edit_profile")?.toUpperCase()}",
                style: R.textStyle.helvetica().copyWith(
                    color: R.colors.black,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    });
  }
}
