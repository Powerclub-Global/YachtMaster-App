import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import '../../../../appwrite.dart';
import '../../../../constant/constant.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/decorations.dart';
import '../../../../resources/dummy.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../../../auth/model/favourite_model.dart';
import '../../../auth/view_model/auth_vm.dart';
import '../../base_vm.dart';
import '../../inbox/model/chat_heads_model.dart';
import '../../inbox/view/chat.dart';
import '../../inbox/view_model/inbox_vm.dart';
import '../../profile/view/review_screen.dart';
import '../../search/model/city_model.dart';
import '../../search/model/services_model.dart';
import '../../search/view/what_looking_for.dart';
import '../../search/view/where_going.dart';
import '../../widgets/exit_sheet.dart';
import '../model/yachts_model.dart';
import '../../search/view_model/search_vm.dart';
import 'add_services.dart';
import 'rules_regulations.dart';
import '../view_model/yacht_vm.dart';
import '../widgets/rating_reviews_card.dart';
import '../widgets/view_all_service_images.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../utils/mapstyle.dart';

class ServiceDetail extends StatefulWidget {
  static String route = "/serviceDetail";
  const ServiceDetail({Key? key}) : super(key: key);

  @override
  _ServiceDetailState createState() => _ServiceDetailState();
}

class _ServiceDetailState extends State<ServiceDetail> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  ServiceModel? service;
  GoogleMapController? mapController;
  double? lat = 51.5072;
  double? lng = 0.1276;
  String mapStyle = "";
  Set<Marker> marker = new Set();
  bool isHostView = false;
  int index = -1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      service = args["service"];
      isHostView = args["isHostView"];
      index = args["index"];
      await moveToLocation(LatLng(service?.location?.lat ?? 25.7716239,
          service?.location?.log ?? -80.1397398));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<BaseVm, YachtVm, AuthVm, SearchVm>(
        builder: (context, baseVm, yachtVm, authVm, provider, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  leading: GestureDetector(
                      onTap: () {
                        Get.back();
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
                              Share.share("Here you can download Yacht Master! \n https://apps.apple.com/us/app/yachtmaster-app/id6449384419");
                            },
                            child: Image.asset(
                              R.images.share,
                              scale: 11,
                              color: Colors.white,
                            )),
                        w3,
                        if (service?.createdBy ==
                            appwrite.user.$id)
                          GestureDetector(
                              onTap: () {
                                Get.bottomSheet(SureBottomSheet(
                                  title: "Delete Experience",
                                  subTitle:
                                      "Are you sure you want to delete this experience?",
                                  yesCallBack: () async {
                                    Get.back();
                                    await FbCollections.services
                                        .doc(service?.id)
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
                                  favouriteItemId: service?.id,
                                  id: service?.id,
                                  type: FavouriteType.service.index);
                              if (yachtVm.userFavouritesList.any(
                                  (element) => element.id == service?.id)) {
                                yachtVm.userFavouritesList.removeAt(index);
                                yachtVm.update();
                                await FbCollections.user
                                    .doc(appwrite.user.$id)
                                    .collection("favourite")
                                    .doc(service?.id)
                                    .delete();
                              } else {
                                await FbCollections.user
                                    .doc(appwrite.user.$id)
                                    .collection("favourite")
                                    .doc(service?.id)
                                    .set(favModel.toJson());
                              }
                              provider.update();
                            },
                            child: Container(
                              decoration: AppDecorations.favDecoration(),
                              child: Icon(
                                  yachtVm.userFavouritesList.any((element) =>
                                              element.favouriteItemId ==
                                                  service?.id &&
                                              element.type ==
                                                  FavouriteType
                                                      .service.index) ==
                                          false
                                      ? Icons.star_border_rounded
                                      : Icons.star,
                                  size: 30,
                                  color: yachtVm.userFavouritesList.any(
                                              (element) =>
                                                  element.favouriteItemId ==
                                                      service?.id &&
                                                  element.type ==
                                                      FavouriteType
                                                          .service.index) ==
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
                                service?.images?.length ?? 0, (index) {
                              return ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                          colors: [
                                        R.colors.black.withOpacity(.30),
                                        R.colors.black.withOpacity(.10),
                                        R.colors.black.withOpacity(.10),
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
                                              color: R.colors.whiteColor
                                                  .withOpacity(.60),
                                              spreadRadius: 3,
                                              blurRadius: 10)
                                        ]),
                                    child: CachedNetworkImage(
                                      imageUrl: service?.images?[index] ??
                                          R.images.serviceUrl,
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
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
                                "${currentIndex + 1}/${service?.images?.length ?? 0}",
                                style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.whiteColor,
                                    ),
                              ))
                        ],
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
                    future: FbCollections.user.doc(service?.createdBy).get(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox();
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            h3,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service?.name ?? "",
                                        style: R.textStyle
                                            .helveticaBold()
                                            .copyWith(
                                                color: R.colors.whiteColor,
                                                fontSize: 18.sp),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      h0P9,
                                      Text(
                                        // service?.createdBy?.firstName??
                                        snapshot.data?.get("first_name") ?? "",
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Row(mainAxisAlignment: MainAxisAlignment.end,
                                      //   children: [
                                      //     Text(
                                      //       "4.2",style: R.textStyle.helveticaBold().copyWith(
                                      //         color: R.colors.yellowDark,fontSize: 15.sp
                                      //     ),textAlign: TextAlign.justify,),
                                      //     w2,
                                      //     Image.asset(R.images.star,color: R.colors.yellowDark,scale: 13,)
                                      //   ],
                                      // ),
                                      // h0P9,
                                      SizedBox(
                                        width: Get.width * .3,
                                        child: Text(
                                          service?.location?.address ?? "",
                                          style: R.textStyle
                                              .helvetica()
                                              .copyWith(
                                                  color: R.colors.whiteDull,
                                                  fontSize: 13.5.sp,
                                                  fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            h2,

                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: R.colors.whiteColor),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        // service?.host?.imageUrl??
                                        snapshot.data?.get("image_url") ??
                                            R.images.userImageUrl,
                                        height: Get.height * .08,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                w4,
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: Get.height * .02),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${getTranslated(context, "day_charter_hosted_by_host")}\n${snapshot.data?.get("first_name") ?? ""}",
                                          // "${service?.host?.firstName}",
                                          style: R.textStyle
                                              .helveticaBold()
                                              .copyWith(
                                                  color: R.colors.whiteColor,
                                                  fontSize: 14.sp),
                                          maxLines: 2,
                                        ),
                                        // h1,
                                        // Text("Capacity, Rooms, Bathrooms",style: R.textStyle.helvetica().copyWith(
                                        //     color: R.colors.whiteDull,fontSize: 12.sp
                                        // ),),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            h2,
                            Text(
                              getTranslated(context, "what_you_will_do") ?? "",
                              style: R.textStyle.helvetica().copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: R.colors.whiteColor,
                                    fontSize: 13.5.sp,
                                  ),
                            ),
                            h1,
                            Text(
                              service?.description ?? "",
                              style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.whiteColor,
                                  fontSize: 12.sp,
                                  height: 1.2),
                            ),
                            h3,
                            if (isHostView == true)
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
                                              color: R.colors.whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: R.colors.lightGrey)),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                // service?.host?.imageUrl??
                                                snapshot.data
                                                        ?.get("image_url") ??
                                                    R.images.userImageUrl,
                                                height: Get.height * .08,
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                        w3,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            h2,
                                            SizedBox(
                                              width: Get.width * .6,
                                              child: Text(
                                                "${getTranslated(context, "hosted_by")} ${snapshot.data?.get("first_name") ?? ""} ",
                                                // "${service?.host?.firstName}",
                                                style: R.textStyle
                                                    .helveticaBold()
                                                    .copyWith(
                                                        color: Colors.white),
                                                overflow: TextOverflow.ellipsis,
                                              ),
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
                                        var InboxPro = Provider.of<InboxVm>(
                                            context,
                                            listen: false);
                                        ChatHeadModel? chatHead =
                                            await createChatHead(InboxPro);
                                        setState(() {});
                                        log("__________________CHat head id:${chatHead?.id}");
                                        Get.toNamed(ChatView.route, arguments: {
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
                            Text(
                              getTranslated(context, "where_you_will_meet") ??
                                  "",
                              style: R.textStyle.helvetica().copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: R.colors.whiteColor,
                                  fontSize: 13.5.sp),
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
                                              service?.location?.lat ??
                                                  25.7716239,
                                              service?.location?.log ??
                                                  -80.1397398),
                                          zoom: 14.0),
                                    ),
                                  ),
                                ),
                                h1,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            service?.location?.address ??
                                                "",
                                            style: R.textStyle
                                                .helvetica()
                                                .copyWith(color: Colors.white),
                                          ),
                                          h0P7,
                                          Text(
                                            service?.location?.address ??
                                                "",
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

                            // if (isHostView==false) SizedBox() else Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     h3,
                            //     GeneralWidgets.seeAllWidget(context, "choose_from_available_dates"),
                            //     h1,
                            //     Padding(
                            //       padding:  EdgeInsets.only(left: 10),
                            //       child: Text("09 ${getTranslated(context, "available")}",
                            //         style:R.textStyle.helvetica().copyWith(fontWeight: FontWeight.bold,
                            //             color: R.colors.whiteDull,fontSize: 11.sp
                            //         ) ,),
                            //     ),
                            //     h3,
                            //     Padding(
                            //         padding:  EdgeInsets.only(
                            //           left: Get.width * .05,
                            //         ),
                            //         child:SizedBox(
                            //           height: Get.height*.23,
                            //           child: ListView(
                            //             scrollDirection: Axis.horizontal,
                            //             children: List.generate(service?.images?.length??0, (index) {
                            //               return   Padding(
                            //                 padding:  EdgeInsets.only(
                            //                   right: Get.width * .03,
                            //                 ),
                            //                 child: Stack(alignment: Alignment.centerLeft,
                            //                   children: [
                            //                     ShaderMask(
                            //                       shaderCallback: (bounds) {
                            //                         return LinearGradient(
                            //                             colors:
                            //                             [
                            //                               R.colors.black.withOpacity(.90),
                            //                               R.colors.black.withOpacity(.10),
                            //                             ],
                            //                             stops: [
                            //                               0.1,
                            //                               0.8,
                            //                             ],
                            //                             begin: Alignment.bottomLeft,
                            //                             end: Alignment.bottomRight
                            //                         ).createShader(bounds);
                            //                       },
                            //                       blendMode: BlendMode.srcATop,
                            //                       child: ClipRRect(borderRadius: BorderRadius.circular(12),
                            //                         child:
                            //                         SizedBox(
                            //                             height: Get.height*.23,
                            //                             width: Get.width*.5,
                            //                             child:
                            //                             CachedNetworkImage(
                            //                               imageUrl: service?.images?[index]??R.images.s1,
                            //                               fit: BoxFit.cover,
                            //                               progressIndicatorBuilder: (context, url, downloadProgress) =>
                            //                                   CircularProgressIndicator(color: R.colors.themeMud,value: downloadProgress.progress),
                            //                               errorWidget: (context, url, error) => Icon(Icons.error),
                            //                             ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                     Column(crossAxisAlignment: CrossAxisAlignment.start,
                            //                       mainAxisAlignment: MainAxisAlignment.center,
                            //                       children: [
                            //                         Text("DATE",style: R.textStyle.helvetica().copyWith(
                            //                             color: R.colors.whiteColor
                            //                         ),),
                            //                         h0P5,
                            //                         Text("Times",style: R.textStyle.helvetica().copyWith(
                            //                             color: R.colors.whiteColor,fontSize: 11.sp
                            //                         ),),                                            h0P5,
                            //
                            //                         Text("Guests",style: R.textStyle.helvetica().copyWith(
                            //                             color: R.colors.whiteColor,fontSize: 11.sp
                            //                         ),),
                            //                         h3,
                            //                         Row(
                            //                           children: [
                            //                             Text("\$500",style: R.textStyle.helveticaBold().copyWith(
                            //                                 color: R.colors.whiteColor,fontSize: 10.sp
                            //                             ),),
                            //                             Text("/Person",style: R.textStyle.helvetica().copyWith(
                            //                                 color: R.colors.whiteColor,fontSize: 10.sp
                            //                             ),),
                            //                           ],
                            //                         ),
                            //                         h2,
                            //                         GestureDetector(
                            //                           onTap: () async {
                            //                             var InboxPro=Provider.of<InboxVm>(context,listen: false);
                            //                             ChatHeadModel chatHead=await InboxPro.checkChatHeadExist(service?.createdBy??"");
                            //                             setState(() {});
                            //                             log("__________________CHat head id:${chatHead.id}");
                            //                             Get.toNamed(ChatView.route,arguments: {"chatHeadModel":chatHead});},
                            //                           child: Container(
                            //                             height: Get.height*.04,width: Get.width*.28,
                            //                             decoration: AppDecorations.gradientButton(radius: 30),
                            //                             child: Center(
                            //                               child: Text(
                            //                                 "${getTranslated(context, "inquire")?.toUpperCase()}",
                            //                                 style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                            //                                     fontSize: 10.sp,fontWeight: FontWeight.bold
                            //                                 ) ,),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ],
                            //                     )
                            //                   ],
                            //
                            //                 ),
                            //               );
                            //             }),
                            //           ),
                            //         )
                            //     ),
                            //   ],
                            // ),
                            h3,
                            Center(
                              child: GestureDetector(
                                onTap: () async {
                                  if (isHostView == true) {
                                    Get.toNamed(AddServices.route, arguments: {
                                      "service": service,
                                      "isEdit": true,
                                      "index": index
                                    });
                                  } else {
                                    var InboxPro = Provider.of<InboxVm>(context,
                                        listen: false);
                                    ChatHeadModel? chatHead =
                                        await createChatHead(InboxPro);
                                    setState(() {});
                                    log("__________________CHat head id:${chatHead?.id}");
                                    Get.toNamed(ChatView.route,
                                        arguments: {"chatHeadModel": chatHead});
                                  }
                                },
                                child: Container(
                                  height: Get.height * .055,
                                  width: Get.width * .75,
                                  decoration:
                                      AppDecorations.gradientButton(radius: 30),
                                  child: Center(
                                    child: Text(
                                      isHostView == true
                                          ? "Edit"
                                          : "${getTranslated(context, "inquire")?.toUpperCase()}",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.black,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
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
      );
    });
  }

  Widget tiles(int index, String title, String subTitle,
      {bool isDivider = true}) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RulesRegulations.route, arguments: {
          "title": subTitle,
          "desc": index == 0 ? "" : AppDummyData.mediumLongText,
          "appBarTitle": title,
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
                      "${getTranslated(context, title)}",
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
              child: Image.asset(
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

  ///MAP FUNCTIONS
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.setMapStyle(Utils.mapStyles);
  }

  moveToLocation(
    LatLng latLng,
  ) async {
    setState(() {
      lat = latLng.latitude;
      lng = latLng.longitude;
    });

    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 12),
      ),
    );
    setMarker(latLng, true);
  }

  void setMarker(LatLng latLng, bool isGetCityCall) {
    // markers.clear();
    setState(() {
      marker.clear();
      marker.add(
          Marker(markerId: MarkerId("selected-location"), position: latLng));
    });
  }

  Future<ChatHeadModel?> createChatHead(InboxVm chatVm) async {
    ChatHeadModel? chatHeadModel;
    List<String> tempSort = [
      appwrite.user.$id ?? "",
      service?.createdBy ?? ""
    ];
    tempSort.sort();
    ChatHeadModel chatData = ChatHeadModel(
      createdAt: Timestamp.now(),
      lastMessageTime: Timestamp.now(),
      lastMessage: "",
      createdBy: appwrite.user.$id,
      id: tempSort.join('_'),
      status: 0,
      peerId: service?.createdBy ?? "",
      users: tempSort,
    );
    chatHeadModel = await chatVm.createChatHead(chatData);
    setState(() {});
    return chatHeadModel;
  }
}
