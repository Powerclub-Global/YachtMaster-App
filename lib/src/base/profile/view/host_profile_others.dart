import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/model/favourite_model.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/inbox/model/chat_heads_model.dart';
import 'package:yacht_master/src/base/inbox/view/chat.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/src/base/profile/model/review_model.dart';
import 'package:yacht_master/src/base/profile/view/review_screen.dart';
import 'package:yacht_master/src/base/search/model/services_model.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/search/widgets/charter_widget.dart';
import 'package:yacht_master/src/base/search/widgets/host_widget.dart';
import 'package:yacht_master/src/base/search/widgets/yacht_widget.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/yacht/view/charter_detail.dart';
import 'package:yacht_master/src/base/yacht/view/service_detail.dart';
import 'package:yacht_master/src/base/yacht/view/yacht_detail.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/src/base/yacht/widgets/rating_reviews_card.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class HostProfileOthers extends StatefulWidget {
  static String route = "/hostProfileOthers";
  const HostProfileOthers({Key? key}) : super(key: key);

  @override
  _HostProfileOthersState createState() => _HostProfileOthersState();
}

class _HostProfileOthersState extends State<HostProfileOthers> {
  UserModel? host;
  ScrollController servicescrollController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController charterscrollController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController yachtscrollController =
      ScrollController(initialScrollOffset: 0.0);
  double averageRating=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var yachtVm=Provider.of<YachtVm>(context,listen: false);
      var settingsVm=Provider.of<SettingsVm>(context,listen: false);
      if (yachtVm.allServicesList.where((element) => element.createdBy==host?.uid).toList().isNotEmpty)
        {
          servicescrollController.animateTo(
              servicescrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 10),
              curve: Curves.easeOut);
        }
      if (yachtVm.allCharters.where((element) => element.createdBy==host?.uid).toList().isNotEmpty)
        {
          charterscrollController.animateTo(
              charterscrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 10),
              curve: Curves.easeOut);
        }
      if (yachtVm.allYachts.where((element) => element.createdBy==host?.uid).toList().isNotEmpty)
        {
          yachtscrollController.animateTo(
              yachtscrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 10),
              curve: Curves.easeOut);
        }

      averageRating=settingsVm.averageRating(settingsVm.allReviews.where((element) => element.hostId==host?.uid).toList());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    host = args["host"];


    return Consumer5<HomeVm,SettingsVm, YachtVm, BaseVm, SearchVm>(
        builder: (context, homeVm,settingsVm, yachtVm, provider, searchVm, _) {
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
                          child: host?.imageUrl==""?
                          Image.network(
                            R.images.dummyDp,
                            fit: BoxFit.cover,
                          ):
                          CachedNetworkImage(
                            imageUrl: host?.imageUrl??R.images.dummyDp,
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
                      top: 0,
                      left: Get.width * .02,
                      right: Get.width * .02,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                        actions: [
                          Row(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Share.share("Here you can download Yacht Master! \n https://apps.apple.com/us/app/yachtmaster-app/id6449384419");
                                  },
                                  child: Image.asset(
                                    R.images.share,
                                    scale: 11,
                                    color: Colors.white,
                                  )),
                              w3,
                              GestureDetector(
                                onTap: () async {
                                  FavouriteModel favModel = FavouriteModel(
                                      creaatedAt: Timestamp.now(),
                                      favouriteItemId: host?.uid,
                                      id: host?.uid,
                                      type: FavouriteType.host.index);
                                  if (yachtVm.userFavouritesList.any(
                                    (element) => element.id == host?.uid,
                                  )) {
                                    yachtVm.userFavouritesList.removeWhere((element)=> element.id == host?.uid);
                                    yachtVm.update();
                                    await FbCollections.user
                                        .doc(FirebaseAuth
                                            .instance.currentUser?.uid)
                                        .collection("favourite")
                                        .doc(host?.uid)
                                        .delete();
                                  } else {
                                    await FbCollections.user
                                        .doc(FirebaseAuth
                                            .instance.currentUser?.uid)
                                        .collection("favourite")
                                        .doc(host?.uid)
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
                                                          host?.uid &&
                                                      element.type ==
                                                          FavouriteType
                                                              .host.index) ==
                                              false
                                          ? Icons.star_border_rounded
                                          : Icons.star,
                                      size: 30,
                                      color: yachtVm.userFavouritesList.any(
                                                  (element) =>
                                                      element.favouriteItemId ==
                                                          host?.uid &&
                                                      element.type ==
                                                          FavouriteType
                                                              .host.index) ==
                                              false
                                          ? R.colors.whiteColor
                                          : R.colors.yellowDark),
                                ),
                              ),
                              w4,
                            ],
                          ),
                        ],
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      h2,
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: Get.width * .03),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 3, child: SizedBox()),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width:Get.width*.25,
                                    child: Text(
                                      host?.firstName ?? "",
                                      style: R.textStyle.helveticaBold().copyWith(
                                          color: R.colors.whiteColor,
                                          fontSize: 17.sp,
                                          height: 1.6),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  w2,
                                  Image.asset(
                                    R.images.check,
                                    height: Get.height * .035,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () async {
                                  var InboxPro=Provider.of<InboxVm>(context,listen: false);
                                  ChatHeadModel? chatHead=await createChatHead(InboxPro);
                                  setState(() {});
                                  log("__________________CHat head id:${chatHead?.id}");
                                  Get.toNamed(ChatView.route,arguments: {"chatHeadModel":chatHead});

                                },
                                child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(colors: [
                                        R.colors.gradMud,
                                        R.colors.gradMudLight
                                      ]).createShader(bounds);
                                    },
                                    blendMode: BlendMode.srcATop,
                                    child: Image.asset(
                                      R.images.inbox,
                                      height: Get.height * .03,
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                      h3,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                "${yachtVm.allCharters.where((element) => element.createdBy==host?.uid).toList().length}",
                                style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize: 17.sp,
                                    ),
                              ),
                              h1,
                              Text(
                                getTranslated(context, "fleet") ?? "",
                                style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteDull, fontSize: 12.sp),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "${homeVm.allBookings.where((element) => element.hostUserUid==host?.uid).toList().length}",
                                style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize: 17.sp,
                                    ),
                              ),
                              h1,
                              Text(
                                getTranslated(context, "bookings") ?? "",
                                style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteDull, fontSize: 12.sp),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: (){
                              Get.toNamed(ReviewScreen.route, arguments: {
                                "reviews": settingsVm.allReviews
                                    .where((element) => element.hostId == host?.uid)
                                    .toList()
                              });
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(averageRating.toString()=="NaN"?"0":
                                      "${averageRating}",
                                      style: R.textStyle.helveticaBold().copyWith(
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
                                      color: R.colors.whiteDull, fontSize: 12.sp),
                                ),
                              ],
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
              if (yachtVm.allCharters.where((element) => element.createdBy==host?.uid).toList().isEmpty) SizedBox() else
                GeneralWidgets.seeAllWidget(context, "charter_fleet",
                  isSeeAll: false),
              if (yachtVm.allCharters.where((element) => element.createdBy==host?.uid).toList().isEmpty) SizedBox() else h2,
              if (yachtVm.allCharters.where((element) => element.createdBy==host?.uid).toList().isEmpty) SizedBox() else Padding(
                padding: EdgeInsets.only(
                  left: Get.width * .05,
                ),
                child: SizedBox(
                  height: Get.height * .2,
                  child: ListView(
                    controller: charterscrollController,
                    reverse: false,
                    scrollDirection: Axis.horizontal,
                    children:
                        List.generate(yachtVm.allCharters.where((element) => element.createdBy==host?.uid).toList().length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(CharterDetail.route, arguments: {
                            "yacht": yachtVm.allCharters.where((element) => element.createdBy==host?.uid).toList()[index],
                            "isReserve": false,
                            "index": index,
                            "isEdit": false
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: CharterWidget(
                            charter: yachtVm.allCharters.where((element) => element.createdBy==host?.uid).toList()[index],
                            width: Get.width * .6,
                            height: Get.height * .17,
                            isSmall: true,
                            isShowStar: false,
                            isFavCallBack: () {
                              // searchVm.featuredCharters[index].isFav==true?searchVm.featuredCharters[index].isFav=false:searchVm.featuredCharters[index].isFav=true;
                              provider.update();
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              h2,
              if (yachtVm.allServicesList.where((element) => element.createdBy==host?.uid).toList().isEmpty) SizedBox() else
                GeneralWidgets.seeAllWidget(context, "concierge_experiences",
                    isSeeAll: false),
              if (yachtVm.allServicesList.where((element) => element.createdBy==host?.uid).toList().isEmpty) SizedBox() else h2,
              if (yachtVm.allServicesList.where((element) => element.createdBy==host?.uid).toList().isEmpty) SizedBox() else
                Padding(
                    padding: EdgeInsets.only(
                      left: Get.width * .05,
                    ),
                    child: SizedBox(
                      height: Get.height * .29,
                      child: ListView(
                        controller: servicescrollController,
                        // reverse: true,
                        scrollDirection: Axis.horizontal,
                        children: List.generate(yachtVm.allServicesList.where((element) => element.createdBy==host?.uid).toList().length,
                                (index) {
                              ServiceModel service = yachtVm.allServicesList.where((element) => element.createdBy==host?.uid).toList()[index];
                              return GestureDetector(
                                onTap: () {
                                  Get.toNamed(ServiceDetail.route, arguments: {
                                    "service": service,
                                    "isHostView": false,
                                    "index": -1
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: HostWidget(
                                    service: service,
                                    width: Get.width * .3,
                                    height: Get.height * .2,
                                    isShowRating: false,
                                    isFavCallBack: () {
                                      // service.isFav==true?service.isFav=false:service.isFav=true;
                                      provider.update();
                                    },
                                  ),
                                ),
                              );
                            }),
                      ),
                    )),
              h4,
              if (yachtVm.allYachts.where((element) => element.createdBy==host?.uid).toList().isEmpty) SizedBox() else
                GeneralWidgets.seeAllWidget(context, "yacht_for_sale",
                  isSeeAll: false),
              if (yachtVm.allYachts.where((element) => element.createdBy==host?.uid).toList().isEmpty) SizedBox() else h2,
              if (yachtVm.allYachts.where((element) => element.createdBy==host?.uid).toList().isEmpty) SizedBox() else
                Padding(
                padding: EdgeInsets.only(
                  left: Get.width * .05,
                ),
                child: SizedBox(
                  height: Get.height * .2,
                  child: ListView(
                      controller: yachtscrollController,
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      children:
                          List.generate(yachtVm.allYachts.where((element) => element.createdBy==host?.uid).toList().length, (index) {
                        return GestureDetector(
                          onTap: () {
                            Get.toNamed(YachtDetail.route, arguments: {
                              "yacht": yachtVm.allYachts.where((element) => element.createdBy==host?.uid).toList()[index],
                              "isEdit": false,
                              "index": -1
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: YachtWidget(
                                yacht: yachtVm.allYachts.where((element) => element.createdBy==host?.uid).toList()[index],
                                width: Get.width * .6,
                                height: Get.height * .17,
                                isSmall: true,
                                isShowStar: false),
                          ),
                        );
                      })),
                ),
              ),
              h3,
            GeneralWidgets.seeAllWidget(context, "rating_and_reviews",
                  onTap: () {
                Get.toNamed(ReviewScreen.route, arguments: {
                  "reviews": settingsVm.allReviews
                      .where((element) => element.hostId == host?.uid)
                      .toList()
                });
              },
                  isSeeAll: settingsVm.allReviews
                          .where((element) => element.hostId == host?.uid)
                          .toList()
                          .isEmpty
                      ? false
                      : true),
              if (settingsVm.allReviews
                  .where((element) => element.hostId == host?.uid)
                  .toList()
                  .isEmpty) SizedBox() else h2,
              Padding(
                padding: EdgeInsets.only(left: Get.width * .05),
                child: settingsVm.allReviews
                            .where((element) => element.hostId == host?.uid)
                            .toList()
                            .isEmpty ==
                        true
                    ? SizedBox(
                        height: Get.height * .3,
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
                                        element.hostId == host?.uid)
                                    .toList()
                                    .length, (index) {
                          ReviewModel review = settingsVm.allReviews
                              .where((element) => element.hostId == host?.uid)
                              .toList()[index];
                          return RatingReviewsCard(
                            reviewModel: review,
                          );
                        })),
                      ),
              ),
              h2,
            ],
          ),
        ),
      );
    });
  }

  Future<ChatHeadModel?> createChatHead(InboxVm chatVm) async {
    ChatHeadModel? chatHeadModel;
    List<String> tempSort = [FirebaseAuth.instance.currentUser?.uid ?? "", host?.uid??""];
    tempSort.sort();
    ChatHeadModel chatData =
    ChatHeadModel(
      createdAt: Timestamp.now(),
      lastMessageTime: Timestamp.now(),
      lastMessage: "",
      createdBy: FirebaseAuth.instance.currentUser?.uid,
      id: tempSort.join('_'),
      status: 0,
      peerId:host?.uid,
      users:tempSort,
    );
    chatHeadModel=  await chatVm.createChatHead(chatData);
    setState(() {

    });
    return chatHeadModel;
  }
}
