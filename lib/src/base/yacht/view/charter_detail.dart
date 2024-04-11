import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/constant.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/dummy.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/model/favourite_model.dart';
import 'package:yacht_master/src/base/base_view.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/inbox/model/chat_heads_model.dart';
import 'package:yacht_master/src/base/inbox/view/chat.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/src/base/profile/model/review_model.dart';
import 'package:yacht_master/src/base/profile/view/review_screen.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/model/charters_day_model.dart';
import 'package:yacht_master/src/base/search/model/city_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/yacht_reserve_payment.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view/search_screen.dart';
import 'package:yacht_master/src/base/search/view/what_looking_for.dart';
import 'package:yacht_master/src/base/search/view/when_will_be_there.dart';
import 'package:yacht_master/src/base/search/view/where_going.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/widgets/exit_sheet.dart';
import 'package:yacht_master/src/base/yacht/model/choose_offers.dart';
import 'package:yacht_master/src/base/yacht/model/yachts_model.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/yacht/view/add_charter_fleet.dart';
import 'package:yacht_master/src/base/yacht/view/define_availibility.dart';
import 'package:yacht_master/src/base/yacht/view/rules_regulations.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/src/base/yacht/widgets/rating_reviews_card.dart';
import 'package:yacht_master/src/base/yacht/widgets/view_all_services.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/mapstyle.dart';

import '../../inbox/view_model/inbox_vm.dart';

class LatLngModel {
  double lat;
  double lng;
  int id;

  LatLngModel(this.lat, this.lng, this.id);
}

class CharterDetail extends StatefulWidget {
  static String route = "/charterDetail";
  const CharterDetail({Key? key}) : super(key: key);

  @override
  _CharterDetailState createState() => _CharterDetailState();
}

class _CharterDetailState extends State<CharterDetail> {
  List<CharterDayModel> charterDayList = [];
  final PageController _pageController = PageController();
  int currentIndex = 0;
  CharterModel? charter;
  bool isReserve = false;
  GoogleMapController? mapController;
  double? lat = 51.5072;
  double? lng = 0.1276;
  String mapStyle = "";
  Set<Marker> marker = new Set();
  BitmapDescriptor? sourceIcon;
  int index = -1;
  bool isEdit = false;
  bool isLoading = false;
  double averageRating = 0;
  List<LatLngModel> latlngs = [
    LatLngModel(36.45, 78.28, 0),
    LatLngModel(32.45, 75.28, 1),
    LatLngModel(33.45, 76.28, 2),
    LatLngModel(34.45, 77.28, 3),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //loading map style JSON from asset file
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var settingsVm = Provider.of<SettingsVm>(context, listen: false);
      startLoader();
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      charter = args["yacht"];
      isReserve = args["isReserve"];
      index = args["index"];
      isEdit = args["isEdit"];

      await moveToLocation(LatLng(charter?.location?.lat ?? 51.5072,
          charter?.location?.long ?? 0.1276));
      averageRating = settingsVm.averageRating(settingsVm.allReviews
          .where((element) => element.hostId == charter?.createdBy)
          .toList());
      addCharterPriceTypeData();
      Future.delayed(Duration(seconds: 2), () {
        stopLoader();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQueryData.fromWindow(window).size;

    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    charter = args["yacht"];
    isReserve = args["isReserve"];
    index = args["index"];
    isEdit = args["isEdit"];
    bool? isLink = args["isLink"];

    return Consumer6<InboxVm, BaseVm, SettingsVm, SearchVm, YachtVm,
            BookingsVm>(
        builder: (context, inboxVm, baseVm, settingsVm, provider, yachtVm,
            bookingVm, _) {
      return ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: Scaffold(
          backgroundColor: R.colors.black,
          body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: SliverAppBar(
                      leading: GestureDetector(
                          onTap: () async {
                            charter = await yachtVm
                                .fetchCharterById(charter?.id ?? "");
                            yachtVm.update();
                            print(isLink);
                            if (isLink == null) {
                              Get.back();
                            } else {
                              print("About to Route");
                              Get.offNamed(BaseView.route);
                            }
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 25,
                            color: Colors.white,
                          )),
                      centerTitle: true,
                      // shape: ContinuousRectangleBorder(
                      //     borderRadius: BorderRadius.only(
                      //         bottomLeft: Radius.circular(47), bottomRight: Radius.circular(47))),
                      backgroundColor: R.colors.black,
                      expandedHeight: Get.height * .53,
                      // collapsedHeight: Get.height*.6,
                      actions: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Share.share(
                                      'Share this yachts to your Friends and Family! \n https://yachtmasterapp.com?yachtId=${charter!.id}');
                                },
                                child: Image.asset(
                                  R.images.share,
                                  scale: 11,
                                  color: Colors.white,
                                )),
                            w3,
                            if (charter?.createdBy ==
                                FirebaseAuth.instance.currentUser?.uid)
                              GestureDetector(
                                  onTap: () {
                                    Get.bottomSheet(SureBottomSheet(
                                      title: "Delete Charter",
                                      subTitle:
                                          "Are you sure you want to delete this charter?",
                                      yesCallBack: () async {
                                        Get.back();
                                        await FbCollections.charterFleet
                                            .doc(charter?.id)
                                            .update({
                                          "status": CharterStatus.inactive.index
                                        });
                                        setState(() {});
                                        baseVm.selectedPage = -1;
                                        baseVm.isHome = true;
                                        baseVm.update();
                                        Get.back();
                                        Get.back();
                                      },
                                    ));
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: R.colors.deleteColor,
                                    size: 30,
                                  ))
                            else
                              GestureDetector(
                                onTap: () async {
                                  FavouriteModel favModel = FavouriteModel(
                                      creaatedAt: Timestamp.now(),
                                      favouriteItemId: charter?.id,
                                      id: charter?.id,
                                      type: FavouriteType.charter.index);
                                  if (yachtVm.userFavouritesList.any(
                                      (element) => element.id == charter?.id)) {
                                    yachtVm.userFavouritesList.removeAt(index);
                                    yachtVm.update();
                                    await FbCollections.user
                                        .doc(FirebaseAuth
                                            .instance.currentUser?.uid)
                                        .collection("favourite")
                                        .doc(charter?.id)
                                        .delete();
                                  } else {
                                    await FbCollections.user
                                        .doc(FirebaseAuth
                                            .instance.currentUser?.uid)
                                        .collection("favourite")
                                        .doc(charter?.id)
                                        .set(favModel.toJson());
                                  }
                                  provider.update();
                                },
                                child: Container(
                                  decoration: AppDecorations.favDecoration(),
                                  child: Icon(
                                      yachtVm.userFavouritesList.any(
                                                  (element) =>
                                                      element.favouriteItemId ==
                                                          charter?.id &&
                                                      element.type ==
                                                          FavouriteType
                                                              .charter.index) ==
                                              false
                                          ? Icons.star_border_rounded
                                          : Icons.star,
                                      size: 30,
                                      color: yachtVm.userFavouritesList.any(
                                                  (element) =>
                                                      element.favouriteItemId ==
                                                          charter?.id &&
                                                      element.type ==
                                                          FavouriteType
                                                              .charter.index) ==
                                              false
                                          ? R.colors.whiteColor
                                          : R.colors.yellowDark),
                                ),
                              ),
                            w4,
                          ],
                        ),
                      ],
                      floating: true,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: SizedBox(
                          height: Get.height * .38,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              PageView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _pageController,
                                onPageChanged: (val) {
                                  currentIndex = val;
                                  setState(() {});
                                },
                                children: List.generate(
                                    charter?.images?.length ?? 0, (index) {
                                  return ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                              colors: [
                                            R.colors.black.withOpacity(.30),
                                            R.colors.black.withOpacity(.10),
                                            R.colors.black.withOpacity(.10)
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
                                                bottomRight:
                                                    Radius.circular(16),
                                                bottomLeft:
                                                    Radius.circular(16)),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: R.colors.whiteColor
                                                      .withOpacity(.60),
                                                  spreadRadius: 3,
                                                  blurRadius: 10)
                                            ]),
                                        child: CachedNetworkImage(
                                          imageUrl: charter?.images?[index] ??
                                              R.images.serviceUrl,
                                          fit: BoxFit.cover,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Padding(
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
                                  );
                                }),
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: R.colors.black.withOpacity(.40)),
                                  margin: EdgeInsets.only(
                                      right: Get.width * .03,
                                      bottom: Get.height * .02),
                                  padding: EdgeInsets.symmetric(
                                      vertical: Get.height * .01,
                                      horizontal: Get.width * .03),
                                  child: Text(
                                    "${currentIndex + 1}/${charter?.images?.length ?? 0}",
                                    style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteColor,
                                        ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width * .03),
                  child: FutureBuilder(
                      future: FbCollections.user.doc(charter?.createdBy).get(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox();
                        } else {
                          return Column(
                            children: [
                              h3,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(charter?.name ?? "",
                                            style: R.textStyle
                                                .helveticaBold()
                                                .copyWith(
                                                    color: R.colors.whiteColor,
                                                    fontSize: 15.sp),
                                            overflow: TextOverflow.ellipsis),
                                        h0P9,
                                        Text(
                                          snapshot.data?.get("first_name") ??
                                              "",
                                          style: R.textStyle
                                              .helveticaBold()
                                              .copyWith(
                                                  color: R.colors.whiteDull,
                                                  fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (averageRating.toString() == "NaN")
                                          SizedBox()
                                        else
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                "$averageRating",
                                                style: R.textStyle
                                                    .helveticaBold()
                                                    .copyWith(
                                                        color:
                                                            R.colors.yellowDark,
                                                        fontSize: 15.sp),
                                                textAlign: TextAlign.justify,
                                              ),
                                              w2,
                                              Image.asset(
                                                R.images.star,
                                                color: R.colors.yellowDark,
                                                scale: 13,
                                              )
                                            ],
                                          ),
                                        h0P9,
                                        Text(charter?.location?.adress ?? "",
                                            style: R.textStyle
                                                .helvetica()
                                                .copyWith(
                                                    color: R.colors.whiteDull,
                                                    fontSize: 13.5.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              h1,
                              Container(
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            snapshot.data?.get("image_url") ??
                                                R.images.userImageUrl,
                                        fit: BoxFit.cover,
                                        height: Get.height * .08,
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                SpinKitPulse(
                                          color: R.colors.themeMud,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                    w4,
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: Get.height * .02),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Day Charter Hosted By\n${snapshot.data?.get("first_name") ?? ""}",
                                            // "${charter?.host?.firstName}",
                                            style: R.textStyle
                                                .helveticaBold()
                                                .copyWith(
                                                    color: R.colors.whiteColor,
                                                    fontSize: 14.sp),
                                          ),
                                          h1,
                                          Text(
                                            charter?.subHeading ??
                                                "Capacity, Rooms, Bathrooms",
                                            style: R.textStyle
                                                .helvetica()
                                                .copyWith(
                                                    color: R.colors.whiteDull,
                                                    fontSize: 12.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              h1,
                              Container(
                                decoration: BoxDecoration(
                                    color: R.colors.blackDull,
                                    borderRadius: BorderRadius.circular(15)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: Get.width * .05,
                                    vertical: Get.height * .02),
                                child: Column(
                                  children: [
                                    h1,
                                    Row(
                                      children: [
                                        Text(
                                          getTranslated(context,
                                                  "what_this_charter_offers") ??
                                              "",
                                          style: R.textStyle
                                              .helveticaBold()
                                              .copyWith(
                                                  color: R.colors.whiteDull,
                                                  fontSize: 15.sp),
                                        ),
                                      ],
                                    ),
                                    h2,
                                    Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        alignment: WrapAlignment.center,
                                        runSpacing: 20,
                                        spacing: 10,
                                        children: List.generate(
                                            charter?.chartersOffers?.length ??
                                                0,
                                            (index) => FutureBuilder(
                                                future: FbCollections
                                                    .chartersOffers
                                                    .doc(charter
                                                            ?.chartersOffers?[
                                                        index])
                                                    .get(),
                                                builder: (context,
                                                    AsyncSnapshot<
                                                            DocumentSnapshot>
                                                        charterSnapshot) {
                                                  if (!charterSnapshot
                                                      .hasData) {
                                                    return SizedBox();
                                                  } else {
                                                    ChooseOffers offer =
                                                        ChooseOffers.fromJson(
                                                            charterSnapshot.data
                                                                ?.data());
                                                    return services(
                                                        offer.title ?? "",
                                                        // charter?.chartersOffers?[index].title ?? "",
                                                        // charter?.services?[index].image ??
                                                        offer.icon ?? "");
                                                  }
                                                }))),
                                    h4,
                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(ViewAllServices.route,
                                            arguments: {"charter": charter});
                                      },
                                      child: Container(
                                        height: Get.height * .05,
                                        width: Get.width * .6,
                                        decoration:
                                            AppDecorations.gradientButton(
                                                radius: 30),
                                        child: Center(
                                          child: Text(
                                            "${getTranslated(context, "view_all")?.toUpperCase()}",
                                            style: R.textStyle
                                                .helvetica()
                                                .copyWith(
                                                    color: R.colors.black,
                                                    fontSize: 12.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              h3,
                              Row(
                                children: [
                                  Text(
                                    getTranslated(context, "boarding") ?? "",
                                    style: R.textStyle.helvetica().copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: R.colors.whiteColor,
                                        fontSize: 15.sp),
                                  ),
                                ],
                              ),
                              h1,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: Get.height * .25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: R.colors.blackLight,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: GoogleMap(
                                        myLocationButtonEnabled: true,
                                        myLocationEnabled: true,
                                        zoomGesturesEnabled: true,
                                        markers: marker,
                                        onMapCreated: _onMapCreated,
                                        initialCameraPosition: CameraPosition(
                                            target: LatLng(
                                                charter?.location?.lat ??
                                                    51.5072,
                                                charter?.location?.long ??
                                                    0.1276),
                                            zoom: 14.0),
                                      ),
                                    ),
                                  ),
                                  h1,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              charter?.location?.adress ??
                                                  "MIAMI BEACH MARINA",
                                              style: R.textStyle
                                                  .helvetica()
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                            h0P7,
                                            Text(
                                              charter?.location?.adress ??
                                                  "D-2, Water Lake, Johar Town, Lahore",
                                              style: R.textStyle
                                                  .helvetica()
                                                  .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 10.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (settingsVm.allReviews
                                  .where((element) =>
                                      element.hostId ==
                                          FirebaseAuth
                                              .instance.currentUser?.uid &&
                                      element.charterFleetDetail?.id ==
                                          charter?.id)
                                  .toList()
                                  .isEmpty)
                                SizedBox()
                              else
                                h4,
                              if (settingsVm.allReviews
                                  .where((element) =>
                                      element.hostId ==
                                          FirebaseAuth
                                              .instance.currentUser?.uid &&
                                      element.charterFleetDetail?.id ==
                                          charter?.id)
                                  .toList()
                                  .isEmpty)
                                SizedBox()
                              else
                                GeneralWidgets.seeAllWidget(
                                    context, "rating_and_reviews",
                                    isPadding: false, onTap: () {
                                  Get.toNamed(ReviewScreen.route, arguments: {
                                    "reviews": settingsVm.allReviews
                                        .where((element) =>
                                            element.hostId ==
                                                FirebaseAuth.instance
                                                    .currentUser?.uid &&
                                            element.charterFleetDetail?.id ==
                                                charter?.id)
                                        .toList()
                                  });
                                }),
                              h2,
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    children: List.generate(
                                        settingsVm.allReviews
                                                    .where((element) =>
                                                        element.hostId ==
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid &&
                                                        element.charterFleetDetail
                                                                ?.id ==
                                                            charter?.id)
                                                    .toList()
                                                    .length >
                                                3
                                            ? 3
                                            : settingsVm.allReviews
                                                .where((element) =>
                                                    element.hostId ==
                                                        FirebaseAuth.instance
                                                            .currentUser?.uid &&
                                                    element.charterFleetDetail
                                                            ?.id ==
                                                        charter?.id)
                                                .toList()
                                                .length, (index) {
                                  ReviewModel review = settingsVm.allReviews
                                      .where((element) =>
                                          element.hostId ==
                                              FirebaseAuth
                                                  .instance.currentUser?.uid &&
                                          element.charterFleetDetail?.id ==
                                              charter?.id)
                                      .toList()[index];
                                  return RatingReviewsCard(
                                    reviewModel: review,
                                  );
                                })),
                              ),
                              if (isEdit == true) SizedBox() else h3,
                              if (isEdit == true)
                                SizedBox()
                              else
                                Container(
                                  decoration: BoxDecoration(
                                      color: R.colors.blackDull,
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Get.width * .04,
                                      vertical: Get.height * .02),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: Get.height * .1,
                                            width: Get.width * .2,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                    color: R.colors.lightGrey)),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              child: CachedNetworkImage(
                                                imageUrl: snapshot.data
                                                        ?.get("image_url") ??
                                                    R.images.userImageUrl,
                                                fit: BoxFit.cover,
                                                height: Get.height * .08,
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        SpinKitPulse(
                                                  color: R.colors.themeMud,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          w3,
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              h2,
                                              Text(
                                                "${getTranslated(context, "hosted_by")} \n${snapshot.data?.get("first_name") ?? ""}",
                                                style: R.textStyle
                                                    .helveticaBold()
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                              h0P7,
                                              Text(
                                                "${getTranslated(context, "verified_booking_reviews")}",
                                                style: R.textStyle
                                                    .helvetica()
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontSize: 12.sp),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      h2,
                                      GestureDetector(
                                        onTap: () async {
                                          ChatHeadModel? chatHead =
                                              await createChatHead(inboxVm);
                                          setState(() {});
                                          log("__________________CHat head id:${chatHead?.id}__${chatHead?.createdBy}");
                                          Get.toNamed(ChatView.route,
                                              arguments: {
                                                "chatHeadModel": chatHead
                                              });
                                        },
                                        child: Container(
                                          height: Get.height * .05,
                                          width: Get.width * .6,
                                          decoration:
                                              AppDecorations.gradientButton(
                                                  radius: 30),
                                          child: Center(
                                            child: Text(
                                              "${getTranslated(context, "contact_host")?.toUpperCase()}",
                                              style: R.textStyle
                                                  .helvetica()
                                                  .copyWith(
                                                      color: R.colors.black,
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              h3,
                              Container(
                                decoration: BoxDecoration(
                                    color: R.colors.blackDull,
                                    borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: Get.width * .04,
                                    vertical: Get.height * .02),
                                child: Column(
                                  children: [
                                    tiles(
                                        0,
                                        "availability",
                                        "${charter?.availability?.startTime} - ${charter?.availability?.endTime}",
                                        ""),
                                    tiles(
                                        4,
                                        "capacity",
                                        charter?.guestCapacity.toString() ?? "",
                                        "",
                                        isDivider:
                                            (charter?.healthSafety?.title !=
                                                    null) &&
                                                (charter?.yachtRules?.title !=
                                                    null)),
                                    if (charter?.yachtRules?.title != null)
                                      tiles(
                                          1,
                                          charter?.yachtRules?.title ?? "",
                                          charter?.yachtRules?.description ??
                                              "",
                                          "${getTranslated(context, "hosts_yacht_rules")}",
                                          isDivider:
                                              charter?.healthSafety?.title !=
                                                  null),
                                    if (charter?.healthSafety?.title != null)
                                      tiles(
                                          2,
                                          charter?.healthSafety?.title ?? "",
                                          charter?.healthSafety?.description ??
                                              "",
                                          getTranslated(context,
                                                  "yacht_masters_health_and_safety_requirements") ??
                                              "",
                                          isDivider: false),
                                    // tiles(3,charter?.cancelationPolicy?.title?? "" , charter?.cancelationPolicy?.description??"",getTranslated(context, "cancellation_policy") ?? "",
                                    //     isDivider: false),
                                  ],
                                ),
                              ),
                              h3,
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed(RulesRegulations.route,
                                        arguments: {
                                          "appBarTitle": settingsVm.allContent
                                                  .where((element) =>
                                                      element.type ==
                                                      AppContentType
                                                          .reportListing.index)
                                                  .first
                                                  .title ??
                                              "",
                                          "title": "",
                                          "desc": settingsVm.allContent
                                                  .where((element) =>
                                                      element.type ==
                                                      AppContentType
                                                          .reportListing.index)
                                                  .first
                                                  .content ??
                                              "",
                                          "textStyle": R.textStyle
                                              .helvetica()
                                              .copyWith(
                                                  color: R.colors.whiteDull,
                                                  fontSize: 14.sp)
                                        });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        "${getTranslated(context, "report_listing")}?",
                                        style: R.textStyle
                                            .helveticaBold()
                                            .copyWith(
                                                color: R.colors.themeMud,
                                                fontSize: 15.sp,
                                                decoration:
                                                    TextDecoration.underline),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              h4,
                            ],
                          );
                        }
                      }),
                ),
              )),
          bottomNavigationBar: isEdit == true ||
                  charter?.createdBy == FirebaseAuth.instance.currentUser?.uid
              ? GestureDetector(
                  onTap: () {
                    Get.toNamed(AddfeaturedCharters.route, arguments: {
                      "charterModel": charter,
                      "isEdit": true,
                      "index": index
                    });
                  },
                  child: Container(
                    height: Get.height * .055,
                    width: Get.width * .7,
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                    decoration: AppDecorations.gradientButton(radius: 30),
                    child: Center(
                      child: Text(
                        "Edit",
                        style: R.textStyle.helvetica().copyWith(
                            color: R.colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              : Container(
                  height: Get.height * .1,
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: R.colors.whiteColor, width: 0.5)),
                      color: R.colors.blackDull),
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width * .05,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                bookingVm.bookingsModel.durationType ==
                                        CharterDayType.halfDay.index
                                    ? "\$${Helper.numberFormatter(double.parse(charter?.priceFourHours.toString() ?? "0"))}"
                                    : bookingVm.bookingsModel.durationType ==
                                            CharterDayType.multiDay.index
                                        ? "\$${Helper.numberFormatter(double.parse(((charter?.priceFullDay ?? 0)).toString()))}"
                                        : "\$${Helper.numberFormatter(double.parse(charter?.priceHalfDay.toString() ?? "0"))}",
                                style: R.textStyle.helveticaBold().copyWith(
                                    color: R.colors.whiteColor,
                                    fontSize: 18.sp),
                              ),
                              w2,
                              PopupMenuButton(
                                offset: Offset(windowSize.width / 5, 20),
                                elevation: 2,
                                color: R.colors.black,
                                itemBuilder: (BuildContext context) {
                                  return charterDayList
                                      .toList()
                                      .map((e) => PopupMenuItem(
                                            value: charterDayList.indexOf(e),
                                            child: Text(
                                              e.title.split("C").first,
                                              style: R.textStyle
                                                  .helveticaBold()
                                                  .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 11.sp,
                                                      height: 1.2),
                                              textAlign: TextAlign.center,
                                            ),
                                          ))
                                      .toList();
                                },
                                onSelected: (int index) {
                                  log("______________INDEX:$index");
                                  provider.selectedCharterDayType =
                                      charterDayList[index];
                                  bookingVm.bookingsModel.durationType =
                                      provider.selectedCharterDayType!.type;
                                  bookingVm.update();
                                  provider.update();
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      provider.selectedCharterDayType!.title
                                          .split("C")
                                          .first,
                                      style: R.textStyle
                                          .helveticaBold()
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 11.sp,
                                              height: 1.2),
                                    ),
                                    w1,
                                    Image.asset(
                                      R.images.dropArrow,
                                      scale: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          startLoader();
                          await bookingVm.onClickBookCharter(
                              isReserve, charter, context);
                          stopLoader();
                        },
                        child: Container(
                          height: Get.height * .05,
                          width: Get.width * .28,
                          decoration: AppDecorations.gradientButton(radius: 30),
                          child: Center(
                            child: Text(
                              isReserve == false
                                  ? "${getTranslated(context, "book_now")?.toUpperCase()}"
                                  : "${getTranslated(context, "reserve")?.toUpperCase()}",
                              style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.black,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }

  Widget tiles(int index, String title, String subTitle, String appBarTitle,
      {bool isDivider = true}) {
    return GestureDetector(
      onTap: () {
        index == 0
            ? Get.toNamed(DefineAvailibility.route,
                arguments: {"charter": charter, "isReadOnly": true})
            : Get.toNamed(RulesRegulations.route, arguments: {
                "title": title,
                "desc": subTitle,
                "appBarTitle": appBarTitle,
                "textStyle": R.textStyle
                    .helvetica()
                    .copyWith(color: R.colors.whiteDull, fontSize: 13.sp)
              });
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    h2,
                    Text(
                      title.capitalizeFirst ?? "",
                      style: R.textStyle
                          .helveticaBold()
                          .copyWith(color: R.colors.whiteDull, fontSize: 12.sp),
                    ),
                    h0P7,
                    Text(
                      subTitle,
                      style: R.textStyle.helvetica().copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 10.sp),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: R.colors.whiteColor, size: 15.sp)
              ],
            ),
            isDivider == false
                ? SizedBox()
                : Container(
                    margin: EdgeInsets.only(top: Get.height * .01),
                    width: Get.width,
                    child: Divider(
                      color: R.colors.grey.withOpacity(.30),
                      thickness: 2,
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget services(String title, String img) {
    return Container(
      width: Get.width * .4,
      child: Row(
        children: [
          SizedBox(
              height: Get.height * .018,
              width: Get.width * .06,
              child: Image.network(
                img,
              )),
          w3,
          Text(
            title,
            style: R.textStyle
                .helvetica()
                .copyWith(color: R.colors.whiteColor, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  /// FUNCTIONS

  Future<ChatHeadModel?> createChatHead(InboxVm chatVm) async {
    ChatHeadModel? chatHeadModel;
    List<String> tempSort = [
      FirebaseAuth.instance.currentUser?.uid ?? "",
      charter?.createdBy ?? ""
    ];
    tempSort.sort();
    ChatHeadModel chatData = ChatHeadModel(
      createdAt: Timestamp.now(),
      lastMessageTime: Timestamp.now(),
      lastMessage: "",
      createdBy: FirebaseAuth.instance.currentUser?.uid,
      id: tempSort.join('_'),
      status: 0,
      peerId: charter?.createdBy,
      users: tempSort,
    );
    chatHeadModel = await chatVm.createChatHead(chatData);
    setState(() {});
    return chatHeadModel;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.setMapStyle(Utils.mapStyles);
    // mapController?.
    //     setMapStyle(mapStyle);
  }

  moveToLocation(
    LatLng latLng,
  ) async {
    await setSourceAndDestinationIcons();
    setState(() {
      lat = latLng.latitude;
      lng = latLng.longitude;
    });

    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 12),
      ),
    );
    latlngs.forEach((element) {
      setMarker(LatLng(element.lat, element.lng), false);
    });
    setMarker(latLng, true);
  }

  void setMarker(LatLng latLng, bool isGetCityCall, {String id = "0"}) {
    // markers.clear();
    setState(() {
      marker.clear();
      marker.add(Marker(
          icon: sourceIcon!,
          markerId: MarkerId("selected-location"),
          position: latLng));
    });
  }

  setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      R.images.pin,
    );
  }

  startLoader() {
    isLoading = true;
    setState(() {});
  }

  stopLoader() {
    isLoading = false;
    setState(() {});
  }

  void addCharterPriceTypeData() {
    if ((charter?.priceFourHours ?? 0) != 0) {
      charterDayList.add(context.read<SearchVm>().charterDayList[0]);
    }
    if ((charter?.priceHalfDay ?? 0) != 0) {
      charterDayList.add(context.read<SearchVm>().charterDayList[1]);
    }
    if ((charter?.priceFullDay ?? 0) != 0) {
      charterDayList.add(context.read<SearchVm>().charterDayList[2]);
    }

    context.read<SearchVm>().selectedCharterDayType = charterDayList[0];
    context.read<BookingsVm>().bookingsModel.durationType =
        context.read<SearchVm>().selectedCharterDayType!.type;
    context.read<BookingsVm>().update();
    context.read<SearchVm>().update();
  }
}
