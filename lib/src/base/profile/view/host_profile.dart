import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../appwrite.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/decorations.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../../../auth/view_model/auth_vm.dart';
import '../../base_vm.dart';
import '../../home/home_vm/home_vm.dart';
import '../../home/view/previous_bookings.dart';
import '../model/review_model.dart';
import 'review_screen.dart';
import '../widgets/edit_profile_bottomsheet.dart';
import '../../search/model/services_model.dart';
import '../../search/view_model/search_vm.dart';
import '../../search/widgets/charter_widget.dart';
import '../../search/widgets/host_widget.dart';
import '../../search/widgets/yacht_widget.dart';
import '../../settings/view_model/settings_vm.dart';
import '../../yacht/view/add_charter_fleet.dart';
import '../../yacht/view/add_services.dart';
import '../../yacht/view/add_yacht_for_sale.dart';
import '../../yacht/view/charter_detail.dart';
import '../../yacht/view/service_detail.dart';
import '../../yacht/view/yacht_detail.dart';
import '../../yacht/view_model/yacht_vm.dart';
import '../../yacht/widgets/rating_reviews_card.dart';
import '../../../../utils/empty_screem.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';

class HostProfile extends StatefulWidget {
  static String route = "/hostProfile";
  const HostProfile({Key? key}) : super(key: key);

  @override
  _HostProfileState createState() => _HostProfileState();
}

class _HostProfileState extends State<HostProfile> {
  ScrollController servicescrollController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController charterscrollController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController yachtscrollController =
      ScrollController(initialScrollOffset: 0.0);
  double averageRating = 0;

  @override
  void initState() {
    // TODO: implement initState
    var yachtVm = Provider.of<YachtVm>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (yachtVm.hostServicesList.isNotEmpty) {
        servicescrollController.jumpTo(
          yachtVm.hostServicesList.length * 100,
        );
      }
      if (yachtVm.hostCharters.isNotEmpty) {
        charterscrollController.jumpTo(
          yachtVm.hostCharters.length * 1000,
        );
      }
      QuerySnapshot reviewsQuery = await FbCollections.bookingReviews.get();
      var settingsVm = Provider.of<SettingsVm>(context, listen: false);
      settingsVm.allReviews =
          reviewsQuery.docs.map((e) => ReviewModel.fromJson(e.data())).toList();
      averageRating = settingsVm.averageRating(settingsVm.allReviews
          .where((element) =>
              element.hostId == appwrite.user.$id)
          .toList());
      setState(() {});
      log("______________AEVRAGE RATING:${averageRating}");
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    servicescrollController.dispose();
    charterscrollController.dispose();
    yachtscrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer6<SettingsVm, HomeVm, YachtVm, BaseVm, SearchVm, AuthVm>(
        builder: (context, settingsVm, homeVm, yachtVm, provider, searchVm,
            authVm, _) {
      log("_________________ALL REVIEWS:${settingsVm.allReviews.length}");
      return Scaffold(
        backgroundColor: R.colors.black,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: Get.height * .6,
                    width: Get.width,
                    padding: EdgeInsets.only(bottom: 1),
                    decoration: BoxDecoration(
                      color: R.colors.black,
                      boxShadow: [
                        BoxShadow(
                            color: R.colors.whiteColor.withOpacity(.60),
                            spreadRadius: 3,
                            blurRadius: 10)
                      ],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                                colors: [
                              R.colors.black,
                              R.colors.black.withOpacity(.02),
                              R.colors.black.withOpacity(.02),
                              R.colors.black,
                              R.colors.black,
                            ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)
                            .createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16)),
                        child: Container(
                          width: Get.width,
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: R.colors.black,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16)),
                              boxShadow: [
                                BoxShadow(
                                    color: R.colors.whiteColor.withOpacity(.60),
                                    spreadRadius: 3,
                                    blurRadius: 10)
                              ]),
                          child: CachedNetworkImage(
                            imageUrl: authVm.userModel?.imageUrl == "" ||
                                    authVm.userModel?.imageUrl == null
                                ? R.images.dummyDp
                                : authVm.userModel?.imageUrl ?? "",
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Padding(
                              padding: EdgeInsets.all(80.sp),
                              child: SpinKitPulse(
                                color: R.colors.themeMud,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: Get.height * .05,
                    left: Get.width * .05,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
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
                                "${yachtVm.hostCharters.length}",
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
                              log("asa");
                              Get.toNamed(AllBookings.route,
                                  arguments: {"isHost": true});
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                children: [
                                  Text(
                                    "${homeVm.allBookings.where((element) => element.hostUserUid == appwrite.user.$id).toList().length}",
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
                              Get.toNamed(ReviewScreen.route, arguments: {
                                "reviews": settingsVm.allReviews
                                    .where((element) =>
                                        element.hostId ==
                                        appwrite.user.$id)
                                    .toList()
                              });
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        averageRating.toString() == "NaN"
                                            ? "0"
                                            : "${averageRating}",
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
              h4,
              GeneralWidgets.seeAllWidget(context, "charter_fleet",
                  isSeeAll: false),
              h2,
              SizedBox(
                  height: Get.height * .2,
                  width: Get.width * .9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(AddfeaturedCharters.route, arguments: {
                              "charterModel": null,
                              "isEdit": false,
                              "index": -1
                            });
                          },
                          child: Container(
                            width: Get.width * .6,
                            height: Get.height * .17,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                color: R.colors.blackLight,
                                borderRadius: BorderRadius.circular(18)),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [
                                          0.1,
                                          10
                                        ],
                                        colors: [
                                          R.colors.gradMudLight,
                                          R.colors.gradMud,
                                        ]),
                                    shape: BoxShape.circle),
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.add,
                                  color: R.colors.blackDull,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (yachtVm.hostCharters.isEmpty)
                        SizedBox()
                      else
                        Expanded(
                          flex: 3,
                          child: ListView(
                            controller: charterscrollController,
                            reverse: true,
                            scrollDirection: Axis.horizontal,
                            children: List.generate(yachtVm.hostCharters.length,
                                (index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: 10,
                                ),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.toNamed(CharterDetail.route,
                                          arguments: {
                                            "yacht":
                                                yachtVm.hostCharters[index],
                                            "isReserve": false,
                                            "index": index,
                                            "isEdit": true
                                          })?.then((value) async {
                                        yachtVm.hostCharters[index] =
                                            await yachtVm.fetchCharterById(
                                                yachtVm.hostCharters[index]
                                                        .id ??
                                                    "");
                                        yachtVm.update();
                                      });
                                    },
                                    child: CharterWidget(
                                      charter: yachtVm.hostCharters[index],
                                      width: Get.width * .6,
                                      height: Get.height * .17,
                                      isSmall: true,
                                      isShowStar: false,
                                      isFavCallBack: () {},
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  )),
              GeneralWidgets.seeAllWidget(context, "concierge_experiences",
                  isSeeAll: false),
              h2,
              SizedBox(
                width: Get.width * .9,
                height: Get.height * .28,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(AddServices.route, arguments: {
                            "service": null,
                            "isEdit": false,
                            "index": -1
                          });
                        },
                        child: Container(
                          height: Get.height * .2,
                          width: Get.width * .3,
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              color: R.colors.blackLight,
                              borderRadius: BorderRadius.circular(18)),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [
                                        0.1,
                                        10
                                      ],
                                      colors: [
                                        R.colors.gradMudLight,
                                        R.colors.gradMud,
                                      ]),
                                  shape: BoxShape.circle),
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.add,
                                color: R.colors.blackDull,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (yachtVm.hostServicesList.isEmpty)
                      SizedBox()
                    else
                      Expanded(
                        flex: 7,
                        child: ListView(
                          controller: servicescrollController,
                          reverse: false,
                          scrollDirection: Axis.horizontal,
                          children: List.generate(
                              yachtVm.hostServicesList.length, (index) {
                            ServiceModel service =
                                yachtVm.hostServicesList[index];
                            return Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed(ServiceDetail.route,
                                        arguments: {
                                          "service": service,
                                          "isHostView": true,
                                          "index": index
                                        });
                                  },
                                  child: HostWidget(
                                    service: service,
                                    width: Get.width * .3,
                                    height: Get.height * .2,
                                    isShowRating: false,
                                    isShowStar: false,
                                    isFavCallBack: () {
                                      // service.isFav == true
                                      //     ? service.isFav = false
                                      //     : service.isFav = true;
                                      provider.update();
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      )
                  ],
                ),
              ),
              GeneralWidgets.seeAllWidget(context, "rating_and_reviews",
                  onTap: () {
                Get.toNamed(ReviewScreen.route, arguments: {
                  "reviews": settingsVm.allReviews
                      .where((element) =>
                          element.hostId ==
                          appwrite.user.$id)
                      .toList()
                });
              },
                  isSeeAll: settingsVm.allReviews
                          .where((element) =>
                              element.hostId ==
                              appwrite.user.$id)
                          .toList()
                          .isEmpty
                      ? false
                      : true),
              h2,
              Padding(
                padding: EdgeInsets.only(left: Get.width * .05),
                child: settingsVm.allReviews
                            .where((element) =>
                                element.hostId ==
                                appwrite.user.$id)
                            .toList()
                            .isEmpty ==
                        true
                    ? SizedBox(
                        height: Get.height * .25,
                        child: EmptyScreen(
                          title: "no_reviews",
                          subtitle: "no_reviews_has_been_received_yet",
                          img: R.images.noFav,
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children: List.generate(
                                settingsVm.allReviews
                                    .where((element) =>
                                        element.hostId ==
                                        appwrite.user.$id)
                                    .toList()
                                    .length, (index) {
                          ReviewModel review = settingsVm.allReviews
                              .where((element) =>
                                  element.hostId ==
                                  appwrite.user.$id)
                              .toList()[index];
                          return RatingReviewsCard(
                            reviewModel: review,
                          );
                        })),
                      ),
              ),
              GeneralWidgets.seeAllWidget(context, "yacht_for_sale",
                  isSeeAll: false),
              h2,
              SizedBox(
                  height: Get.height * .2,
                  width: Get.width * .9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(AddYachtForSale.route, arguments: {
                              "yachtsModel": null,
                              "isEdit": false,
                              "index": -1
                            });
                          },
                          child: Container(
                            width: Get.width * .6,
                            height: Get.height * .17,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                color: R.colors.blackLight,
                                borderRadius: BorderRadius.circular(18)),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [
                                          0.1,
                                          10
                                        ],
                                        colors: [
                                          R.colors.gradMudLight,
                                          R.colors.gradMud,
                                        ]),
                                    shape: BoxShape.circle),
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.add,
                                  color: R.colors.blackDull,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (yachtVm.hostYachts.isEmpty)
                        SizedBox()
                      else
                        Expanded(
                          flex: 3,
                          child: ListView(
                              controller: yachtscrollController,
                              reverse: true,
                              scrollDirection: Axis.horizontal,
                              children: List.generate(yachtVm.hostYachts.length,
                                  (index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: 10,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.toNamed(YachtDetail.route,
                                            arguments: {
                                              "yacht":
                                                  yachtVm.hostYachts[index],
                                              "isEdit": true,
                                              "index": index
                                            });
                                      },
                                      child: YachtWidget(
                                          yacht: yachtVm.hostYachts[index],
                                          width: Get.width * .6,
                                          height: Get.height * .17,
                                          isSmall: true,
                                          isShowStar: false),
                                    ),
                                  ),
                                );
                              })),
                        )
                    ],
                  )),
              h3,
              GestureDetector(
                onTap: () {
                  Get.bottomSheet(EditProfile());
                },
                child: Container(
                  height: Get.height * .06,
                  width: Get.width * .8,
                  margin: EdgeInsets.symmetric(vertical: Get.height * .01),
                  decoration: AppDecorations.gradientButton(radius: 30),
                  child: Center(
                    child: Text(
                      "${getTranslated(context, "edit_host_profile")?.toUpperCase()}",
                      style: R.textStyle.helvetica().copyWith(
                          color: R.colors.black,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
