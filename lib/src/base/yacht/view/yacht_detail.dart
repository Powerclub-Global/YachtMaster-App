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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/dummy.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/inbox/model/chat_heads_model.dart';
import 'package:yacht_master/src/base/inbox/view/chat.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/src/base/search/model/city_model.dart';
import 'package:yacht_master/src/base/search/model/services_model.dart';
import 'package:yacht_master/src/base/search/view/what_looking_for.dart';
import 'package:yacht_master/src/base/search/view/where_going.dart';
import 'package:yacht_master/src/base/widgets/exit_sheet.dart';
import 'package:yacht_master/src/base/yacht/model/yachts_model.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/yacht/view/add_charter_fleet.dart';
import 'package:yacht_master/src/base/yacht/view/add_yacht_for_sale.dart';
import 'package:yacht_master/src/base/yacht/view/rules_regulations.dart';
import 'package:yacht_master/src/base/yacht/widgets/rating_reviews_card.dart';
import 'package:yacht_master/src/base/yacht/widgets/view_all_service_images.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/mapstyle.dart';
class YachtDetail extends StatefulWidget {
  static String route="/yachtDetail";
  const YachtDetail({Key? key}) : super(key: key);

  @override
  _YachtDetailState createState() => _YachtDetailState();
}

class _YachtDetailState extends State<YachtDetail> {
  final PageController _pageController = PageController();
  int currentIndex=0;

  YachtsModel? yacht;
  GoogleMapController? mapController;
  double? lat=51.5072;
  double? lng=0.1276;
  String mapStyle="";
  Set<Marker> marker = new Set();
  bool isEdit=false;
  int index=-1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //loading map style JSON from asset file
    DefaultAssetBundle.of(context).loadString('assets/map_style.json').then((string) {
      mapStyle = string;
    }).catchError((error) {
      log(error.toString());
    });
    moveToLocation(LatLng(lat??51.5072,lng??0.1276 ));
  }
  @override
  Widget build(BuildContext context) {
    var args=ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    yacht=args["yacht"];
    isEdit=args["isEdit"];
    index=args["index"];
    log("______________YACHT ID:${yacht?.id}");
    return Consumer2<BaseVm,SearchVm>(
        builder: (context, baseVm,provider, _) {
          return Scaffold(
            backgroundColor: R.colors.black,
            body:NestedScrollView(
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
                      expandedHeight: Get.height *.53,
                      // collapsedHeight: Get.height*.6,
                      actions: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap:(){
                                  Share.share("Here you can download Yacht Master! \n https://apps.apple.com/us/app/yachtmaster-app/id6449384419");
                                },child: Image.asset(R.images.share,scale: 11,color: Colors.white,)),
                            w3,
                            if (yacht?.createdBy==FirebaseAuth.instance.currentUser?.uid) GestureDetector(
                                onTap: (){
                                  Get.bottomSheet(SureBottomSheet(title: "Delete Yacht",
                                    subTitle: "Are you sure you want to delete this yacht?",
                                    yesCallBack: () async {
                                      Get.back();
                                      await FbCollections.yachtForSale.doc(yacht?.id).update({
                                        "status":CharterStatus.inactive.index
                                      });
                                      setState(() {});
                                      baseVm.selectedPage = -1;
                                      baseVm.isHome = true;
                                      baseVm.update();
                                      Get.back();
                                      Get.back();


                                    },));
                                },
                                child: Icon(Icons.delete,color: R.colors.deleteColor,size: 30,)) else SizedBox(),
                            w4,
                          ],
                        ),
                      ],
                      floating: true,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background:
                        SizedBox(
                          height: Get.height * .38,
                          child: Stack(alignment: Alignment.bottomRight,
                            children: [
                              PageView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _pageController,
                                onPageChanged: (val) {
                                  currentIndex = val;
                                  setState(() {});
                                },
                                children: List.generate(yacht?.images?.length??0,
                                        (index) {
                                      return ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return LinearGradient(colors:
                                          [ R.colors.black.withOpacity(.30),R.colors.black.withOpacity(.10), R.colors.black.withOpacity(.10)],begin: Alignment.topCenter,end: Alignment.bottomCenter)
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
                                                ]
                                            ),
                                            child: CachedNetworkImage(imageUrl: yacht?.images?[index]??R.images.serviceUrl,
                                              fit: BoxFit.cover,
                                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                                  Padding(
                                                    padding:  EdgeInsets.all(80.sp),
                                                    child:SpinKitPulse(color: R.colors.themeMud,),
                                                  ),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color:R.colors.black.withOpacity(.40)
                                  ),
                                  margin: EdgeInsets.only(right: Get.width*.03,bottom: Get.height*.02),
                                  padding: EdgeInsets.symmetric(vertical: Get.height*.01,horizontal: Get.width*.03),
                                  child: Text("${currentIndex+1}/${yacht?.images?.length??0}",style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteColor,
                                  ),))
                            ],
                          ),
                        ),

                      ),
                    ),
                  ];
                },
                body: SingleChildScrollView(
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: Get.width*.03),
                    child: FutureBuilder(
                        future: FbCollections.user.doc(yacht?.createdBy).get(),
                        builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if(!snapshot.hasData)
                          {
                            return SizedBox();
                          }
                        else{
                            return Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                h3,
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(yacht?.name??"",style: R.textStyle.helveticaBold().copyWith(
                                              color: R.colors.whiteColor,fontSize: 18.sp
                                          ),overflow: TextOverflow.ellipsis,),
                                          h0P9,
                                          Text(
                                            snapshot.data?.get("first_name")??"",style: R.textStyle.helveticaBold().copyWith(
                                              color: R.colors.whiteDull,fontSize: 14.sp
                                          ),),

                                        ],),
                                    ),
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "\$${Helper.numberFormatter(double.parse(yacht?.price?.toStringAsFixed(0)??"23,124"))}",style: R.textStyle.helveticaBold().copyWith(
                                              color: R.colors.yellowDark,fontSize: 15.sp
                                          ),textAlign: TextAlign.justify,),
                                          h0P9,
                                          SizedBox(width: Get.width*.3,
                                            child: Text(yacht?.location?.address??"",style: R.textStyle.helvetica().copyWith(
                                                color: R.colors.whiteDull,fontSize: 13.5.sp,fontWeight: FontWeight.bold
                                            ),    overflow: TextOverflow.ellipsis),
                                          ),

                                        ],),
                                    ),
                                  ],
                                ),
                                h3,

                                Container(
                                  height: Get.height*.1,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child:CachedNetworkImage(
                                          imageUrl:  snapshot.data?.get("image_url")?? R.images.userImageUrl,
                                          fit: BoxFit.cover,
                                          height: Get.height * .08,
                                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                                              SpinKitPulse(color: R.colors.themeMud,),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                      w4,
                                      Padding(
                                        padding:  EdgeInsets.symmetric(vertical: Get.height*.02),
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                "${getTranslated(context, "day_charter_hosted_by_host")}\n${snapshot.data?.get("first_name")??""}",
                                              // " ${yacht?.host?.firstName}",
                                              style:
                                              R.textStyle.helvetica().copyWith(
                                                color: R.colors.whiteColor,fontSize: 13.sp,
                                              )),


                                          ],),
                                      ),
                                    ],),
                                ),
                                h2,
                                Text(getTranslated(context, "desc")??"",style:
                                R.textStyle.helvetica().copyWith(fontWeight: FontWeight.bold,
                                  color: R.colors.whiteColor,fontSize: 13.5.sp,

                                ),),
                                h1,
                                Text(yacht?.description??"",style:
                                R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteColor,fontSize: 12.sp,height: 1.2
                                ),),

                                h3,
                                Text(getTranslated(context, "where_you_will_meet")??"",style:
                                R.textStyle.helvetica().copyWith(fontWeight: FontWeight.bold,
                                    color: R.colors.whiteColor,fontSize: 13.5.sp
                                ),),
                                h1,
                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: Get.height*.25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: R.colors.blackLight,

                                      ),
                                      child:ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: GoogleMap(
                                          myLocationButtonEnabled: true,
                                          myLocationEnabled: true,
                                          zoomGesturesEnabled: true,
                                          markers: marker,
                                          onMapCreated: _onMapCreated,
                                          initialCameraPosition:  CameraPosition(
                                              target: LatLng(lat??0.0,lng??0.0), zoom: 14.0),
                                        ),
                                      ),
                                    ),
                                    h1,
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(yacht?.location?.address??"MIAMI BEACH MARINA",style:R.textStyle.helvetica().copyWith(
                                                color: Colors.white
                                            ) ,),
                                            h0P7,
                                            Text(yacht?.location?.address??"D-2, Water Lake, Johar Town, Lahore",
                                              style:R.textStyle.helvetica().copyWith(
                                                  color: Colors.white,fontSize: 10.sp
                                              ) ,),
                                          ],
                                        ),

                                      ],
                                    ),
                                  ],
                                ),
                                h3,
                                if (isEdit==true) GestureDetector(
                                  onTap: (){
                                    Get.toNamed(AddYachtForSale.route
                                        ,arguments: {
                                          "yachtsModel":yacht,
                                          "isEdit":true,
                                          "index":index
                                        });
                                  },
                                  child: Container(
                                    height: Get.height*.065,width: Get.width,
                                    margin: EdgeInsets.symmetric(horizontal: 6.w,vertical: 2.h),
                                    decoration: AppDecorations.gradientButton(radius: 30),
                                    child: Center(
                                      child: Text(
                                        "Edit",
                                        style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                                            fontSize: 12.sp,fontWeight: FontWeight.bold
                                        ) ,),
                                    ),
                                  ),
                                )
                                else Container(
                                  decoration: BoxDecoration(
                                      color: R.colors.blackDull,
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: Get.width*.04,vertical: Get.height*.02),
                                  child: Column(children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(height: Get.height*.1,width: Get.width*.2,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: R.colors.lightGrey)
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child:CachedNetworkImage(
                                              imageUrl:  snapshot.data?.get("image_url")?? R.images.userImageUrl,
                                              fit: BoxFit.cover,
                                              height: Get.height * .08,
                                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                                  SpinKitPulse(color: R.colors.themeMud,),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        w3,
                                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            h2,
                                            Text(
                                              "${getTranslated(context, "day_charter_hosted_by_host")}\n${snapshot.data?.get("first_name")??""}",
                                              style:R.textStyle.helveticaBold().copyWith(
                                                  color: Colors.white
                                              ) ,),
                                            h0P7,
                                            Text("${getTranslated(context, "verified_booking_reviews")}",
                                              style:R.textStyle.helvetica().copyWith(
                                                  color: Colors.white,fontSize: 12.sp
                                              ) ,),
                                          ],
                                        ),

                                      ],
                                    ),
                                    h2,
                                    GestureDetector(
                                      onTap: () async {
                                        var InboxPro=Provider.of<InboxVm>(context,listen: false);
                                        ChatHeadModel? chatHead=await createChatHead(InboxPro);
                                        setState(() {});
                                        Get.toNamed(ChatView.route,arguments: {"chatHeadModel":chatHead});},
                                      child: Container(
                                        height: Get.height*.05,width: Get.width*.6,
                                        decoration: AppDecorations.gradientButton(radius: 30),
                                        child: Center(
                                          child: Text("${getTranslated(context, "contact_host")?.toUpperCase()}",
                                            style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                                                fontSize: 12.sp,fontWeight: FontWeight.bold
                                            ) ,),
                                        ),
                                      ),
                                    ),
                                  ],),
                                ),

                                h5,
                              ],
                            );
                          }
                      }
                    ),
                  ),
                )),
          );
        }
    );
  }

  Widget tiles(int index,String title,String subTitle,{bool isDivider=true})
  {
    return
      GestureDetector(
        onTap: (){
          Get.toNamed(RulesRegulations.route,arguments: {"title":subTitle,"desc":
          index==0?"":AppDummyData.mediumLongText,"appBarTitle":title,
            "textStyle":R.textStyle.helvetica().copyWith(
                color: R.colors.whiteDull,fontSize: 13.sp
            )});
        },
        child: Container(
          color: Colors.transparent,
          child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      h2,
                      Text("${getTranslated(context, title)}",
                        style:R.textStyle.helveticaBold().copyWith(
                            color: R.colors.whiteDull,fontSize: 12.sp
                        ) ,),
                      h0P7,
                      Text(subTitle,
                        style:R.textStyle.helvetica().copyWith(fontWeight: FontWeight.bold,
                            color: Colors.white,fontSize: 10.sp
                        ) ,),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,color: R.colors.whiteColor,
                      size:15.sp
                  )
                ],
              ),
              isDivider==false?SizedBox():Container(
                margin: EdgeInsets.only(top:Get.height*.01),
                width: Get.width,
                child: Divider(
                  color: R.colors.grey.withOpacity(.30),thickness: 2,
                ),
              )
            ],
          ),
        ),
      );
  }
  Widget services(String title,String img)
  {
    return Container(width: Get.width*.4,
      child: Row(
        children: [
          SizedBox(height:Get.height*.018,width: Get.width*.06,child: Image.asset(img,)),
          w3,
          Text(title,style: R.textStyle.helvetica().copyWith(
              color: R.colors.whiteColor,fontSize: 12.sp
          ),),
        ],
      ),
    );
  }
  ///MAP FUNCTIONS
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.
        setMapStyle(Utils.mapStyles);
  }
   moveToLocation(LatLng latLng,) async {



    setState(() {
      lat=latLng.latitude;
      lng=latLng.longitude;

    });

    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: latLng,
            zoom: 12
        ),
      ),
    );
    setMarker(latLng, true);
  }
  void setMarker(LatLng latLng, bool isGetCityCall) {
    // markers.clear();
    setState(() {
      marker.clear();
      marker.add(Marker(
          markerId:  MarkerId("selected-location"), position: latLng));

    });
  }
  Future<ChatHeadModel?> createChatHead(InboxVm chatVm) async {
    ChatHeadModel? chatHeadModel;
    List<String> tempSort = [FirebaseAuth.instance.currentUser?.uid ?? "", yacht?.createdBy??""];
    tempSort.sort();
    ChatHeadModel chatData =
    ChatHeadModel(
      createdAt: Timestamp.now(),
      lastMessageTime: Timestamp.now(),
      lastMessage: "",
      createdBy: FirebaseAuth.instance.currentUser?.uid,
      id: tempSort.join('_'),
      status: 0,
      peerId:yacht?.createdBy??"",
      users:tempSort,
    );
    chatHeadModel=  await chatVm.createChatHead(chatData);
    setState(() {

    });
    return chatHeadModel;
  }

}
