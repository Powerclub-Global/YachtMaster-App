// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/yacht/view/rules_regulations.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class WhosComing extends StatefulWidget {
  static String route="/whosComing";
  @override
  _WhosComingState createState() => _WhosComingState();
}

class _WhosComingState extends State<WhosComing> {

  int selectedTab=0; ///0 means calendar selected
  String? cityName;
  bool? isReserve;
  CharterModel? charter;
  BookingsModel? bookingsModel;
  bool isLoading=false;
  bool isEdit=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     var searchVm=Provider.of<SearchVm>(context,listen: false);

      var args=ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      setState(() {
        cityName=args["cityModel"];
        isEdit=args["isEdit"];
        isReserve=args["isReserve"];
        charter=args["charter"];
        bookingsModel=args["bookingsModel"];
        log("________________BOOKING MODEL:${bookingsModel}");
        if(isEdit==false)
          {
            searchVm.adultsCount=0;
            searchVm.childrenCount=0;
            searchVm.infantsCount=0;
            searchVm.petsCount=0;
            searchVm.notifyListeners();
          }

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchVm,BookingsVm>(
        builder: (context, provider,bookingsVm, _) {
          return ModalProgressHUD(
            inAsyncCall: isLoading,
            progressIndicator:SpinKitPulse(color: R.colors.themeMud,),
            child: Scaffold(
              backgroundColor: R.colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                titleSpacing: 0,
                leading:GestureDetector(
                    onTap: (){
                      Get.back();

                    },
                    child: Icon(Icons.arrow_back_ios_rounded,color: R.colors.whiteColor,
                      size: 20,)),
                title: Text(
                  bookingsModel!=null?
                      "Update":
                    getTranslated(context, "search") ?? "",
                    style: R.textStyle
                        .helvetica()
                        .copyWith(color: Colors.grey, fontSize: 14.sp)),
              ),
              body: SingleChildScrollView(
                child: GestureDetector(
                  onTap:(){
                    Helper.focusOut(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      h3,
                      Text(getTranslated(context, "whos_coming")??"",style: R.textStyle.helveticaBold().copyWith(
                          color: Colors.white,fontSize: 16.sp
                      )),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Get.width * .05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                           if (bookingsModel!=null) SizedBox() else
                             Column(
                              children: [
                                h2P5,
                                Text(
                                  cityName??"",
                                  style: R.textStyle.helveticaBold().copyWith(
                                    color: R.colors.whiteDull,
                                    fontSize: 14.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                h2,
                                Text(
                                  bookingsVm.bookingsModel.schedule?.dates!=null && bookingsVm.bookingsModel.schedule?.dates?.length==1?
                                  "${(bookingsVm.bookingsModel.schedule?.dates?.first.toDate()??DateTime.now()).formateDateMDY()}" :
                                  "${(bookingsVm.bookingsModel.schedule?.dates?.first.toDate()??DateTime.now()).formateDateMDY()} - ${(bookingsVm.bookingsModel.schedule?.dates?.last.toDate()??DateTime.now()).formateDateMDY()}",
                                  style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteDull,
                                    fontSize: 13.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            h5,
                            Container(
                                decoration: BoxDecoration(
                                    color: R.colors.blackDull,
                                    borderRadius: BorderRadius.circular(16)
                                ),
                                padding: EdgeInsets.symmetric(horizontal: Get.width*.03,),
                                child: Column(
                                  children: [
                                    h3,
                                    tiles("adults", "ages_13_or_above",0 ),
                                    tiles("children", "ages_2_to_12",1 ),
                                    tiles("infants", "under_2",2,isDivider: charter?.isPetAllow==false?false:true ),
                                   if (charter?.isPetAllow==false) SizedBox() else  tiles("pets", "bringing_a_service_animal",3,isDivider: false ),

                                  ],
                                )),


                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: GestureDetector(
                onTap: () async {
                      startLoader();
                      bookingsVm.onClickWhosComing(charter?.guestCapacity??0,bookingsModel, isReserve, context);
                      stopLoader();
                },
                child: Container(
                  height: Get.height*.055,
                  width: Get.width*.75,
                  margin: EdgeInsets.symmetric(horizontal: 10.w,
                  vertical: 2.h),
                  decoration: AppDecorations.gradientButton(radius: 30),
                  child: Center(
                    child: Text(
                      bookingsModel!=null?
                          "Update":
                      "${getTranslated(context, "next")?.toUpperCase()}",
                      style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                          fontSize: 12.sp,fontWeight: FontWeight.bold
                      ) ,),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
Widget tiles(String title,String subTitle,int index, {bool isDivider = true})
{
  return Consumer2<SettingsVm,SearchVm>(
      builder: (context,settingsVm, provider, _) {
        return Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${getTranslated(context, title)?.toUpperCase()}",style: R.textStyle.helveticaBold().copyWith(
                      color:R.colors.whiteColor,fontSize: 13.sp
                  ),),
                  h1,
                  GestureDetector(
                    onTap: (){
                    index==3?
                    Get.toNamed(RulesRegulations.route, arguments: {
                      "appBarTitle": settingsVm.allContent.where((element) => element.type==AppContentType.bringingAnimals.index).first.title??"",
                      "title": "",
                      "desc":settingsVm.allContent.where((element) => element.type==AppContentType.bringingAnimals.index).first.content??"",
                      "textStyle": R.textStyle.helvetica().copyWith(
                          color: R.colors.whiteDull, fontSize: 14.sp)
                    }):null;
                    },
                    child: Text(getTranslated(context, subTitle)??"",
                      style: R.textStyle.helvetica().copyWith(
                          color:isDivider==false && index==3?R.colors.themeMud:
                          R.colors.whiteColor,fontSize: 12.sp,decoration:isDivider==false && index==3?
                      TextDecoration.underline:TextDecoration.none
                      ),),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: (){
                    switch(index)
                    {
                      case 0:
                        {
                          if(provider.adultsCount>0)
                            {
                              provider.adultsCount--;
                            }
                        }
                        break;
                      case 1:
                        {
                            if (provider.childrenCount > 0) {
                              provider.childrenCount--;
                            }
                            break;
                          }

                        case 2:
                          {
                            if (provider.infantsCount > 0) {
                              provider.infantsCount--;
                            }
                            break;
                          }

                        case 3:
                          {
                            if (provider.petsCount > 0) {
                              provider.petsCount--;
                            }
                            break;

                          }
                      }
                    provider.update();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                      ),
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.remove),
                    ),
                  ),
                  SizedBox(width: Get.width*.15,
                    child: Center(
                      child: Text(
                        index==0?"${provider.adultsCount}":
                        index==1?"${provider.childrenCount}":
                        index==2?"${provider.infantsCount}":
                        "${provider.petsCount}"
                        ,style: R.textStyle.helveticaBold().copyWith(
                          color:R.colors.whiteColor,fontSize: 13.sp
                      ),),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      switch(index)
                      {
                        case 0:
                          {
                            if(provider.adultsCount<50)
                            {
                              provider.adultsCount++;
                            }
                            break;

                          }
                        case 1:
                          {
                             log("____________________________________2");
                            if (provider.childrenCount < 50) {
                              provider.childrenCount++;
                            }
                            break;
                          }

                        case 2:
                          {
                            if (provider.infantsCount <50) {
                              provider.infantsCount++;
                            }
                            break;
                          }

                        case 3:
                          {
                            if (provider.petsCount <50) {
                              provider.petsCount++;
                            }
                            break;

                          }
                      }
                      provider.update();

                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                      ),
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ],
          ),
        if (isDivider==false)
          SizedBox(height: Get.height*.03,) else
            SizedBox(width: Get.width*.9,height: Get.height*.06,child: Divider(color: Colors.grey,)),
        ],
      );
    }
  );
}
///LOADER
  startLoader() {
    isLoading = true;
    setState(() {});
  }

  stopLoader() {
    isLoading = false;
    setState(() {});
  }
}