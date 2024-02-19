// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/search/model/city_model.dart';
import 'package:yacht_master/src/base/yacht/model/yachts_model.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/search/widgets/yacht_widget.dart';
import 'package:yacht_master/src/base/yacht/view/charter_detail.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class SearchYachts extends StatefulWidget {
  CityModel? cityModel;

  SearchYachts({this.cityModel});

  @override
  _SearchYachtsState createState() => _SearchYachtsState();
}

class _SearchYachtsState extends State<SearchYachts> {
  TextEditingController searchCon = new TextEditingController();
  int selectedTab=0;
  List<String> tabsList=["price_v","type_of_place_v","amenities_v"];
  String searchText="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      searchText="";
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<YachtVm,SearchVm>(
        builder: (context, yachtVm,provider, _) {
          return SingleChildScrollView(
            child: GestureDetector(
              onTap:(){
                Helper.focusOut(context);
              },
              child: Container(
                decoration:  BoxDecoration(
                  color: R.colors.black,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    h1,
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title:
                      Text(getTranslated(context, "200_plus_yachts_to_charter")??"",style: R.textStyle.helveticaBold().copyWith(
                          color: Colors.white,fontSize: 16.sp
                      )),
                      leading: GestureDetector(
                          onTap: (){
                            Get.back();
                            // showModalBottomSheet(
                            //   context: context,
                            //   isScrollControlled:true,
                            //   backgroundColor: Colors.transparent,
                            //   shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(
                            //     topRight: Radius.circular(30),
                            //     topLeft: Radius.circular(30),
                            //   ), ),
                            //   barrierColor: R.colors.grey.withOpacity(.30),
                            //   builder: (context) {
                            //     return Container(
                            //         height: Get.height*.8,
                            //         decoration:  BoxDecoration(
                            //           color: R.colors.black,
                            //           borderRadius: BorderRadius.only(
                            //             topRight: Radius.circular(30),
                            //             topLeft: Radius.circular(30),
                            //           ),
                            //         ),
                            //         child: WhosComing(cityModel: widget.cityModel,));
                            //   },
                            // );
                          },
                          child: Icon(Icons.arrow_back_ios_rounded,color: R.colors.whiteColor,)),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Get.width * .07),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          h1,
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: R.colors.grey.withOpacity(.15)
                            ),
                            child: TextFormField(
                              controller: searchCon,
                              cursorColor: Colors.white,
                              textInputAction: TextInputAction.search,
                              style: R.textStyle.helvetica().copyWith(color:
                              R.colors.whiteColor,fontSize: 16.sp,),
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "search"),
                                  hintStyle:R.textStyle.helvetica().copyWith(color:
                                  R.colors.lightGrey,fontSize: 13.sp),
                                  contentPadding: EdgeInsets.symmetric(vertical: Get.height*.02),
                                  prefixIconConstraints: BoxConstraints(maxHeight: 55,minHeight: 55,minWidth: 60,maxWidth: 60),
                                  prefixIcon: Image.asset(R.images.search,scale: 7,),
                                  border: InputBorder.none
                              ),
                              onChanged: (value){
                                searchText=value.removeAllWhitespace.toString().toLowerCase();
                                provider.update();
                                log("____________________SERAC:${searchText}");
                              },
                              onFieldSubmitted: (value){
                              },
                            ),
                          ),
                          h3,
                          Row(children: List.generate(tabsList.length, (index) {
                            return tabs(index,tabsList[index]);
                          }),),
                          h2,
                          Column(children:
                          List.generate(yachtVm.allYachts.where((element) => element.name.toString().toLowerCase().contains(searchText)).toList().length, (index) {
                            return yachtsCard(yachtVm.allYachts.where((element) => element.name.toString().toLowerCase().contains(searchText)).toList()[index], index, provider);
                          }),)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
  Widget tabs(int index,String title)
  {
    return Expanded(
      child: GestureDetector(
        onTap: (){
          selectedTab=index;
          setState(() {});
        },
        child: Container(color: Colors.transparent,
          child: Column(
            children: [
              Text(getTranslated(context, title)??"",style: R.textStyle.helvetica().copyWith(
                  color: R.colors.whiteDull,fontSize: 12.sp,fontWeight: FontWeight.bold
              ),),
              SizedBox(height: Get.height*.03,child: Divider(color:selectedTab==index?R.colors.themeMud:
              R.colors.grey.withOpacity(.40),thickness: 2,))
            ],
          ),
        ),
      ),
    );
  }
  Widget yachtsCard(YachtsModel yacht,int index,SearchVm provider)
  {
    return
      GestureDetector(
        onTap: (){
          Get.toNamed(CharterDetail.route,arguments: {"yacht":yacht,"isReserve":true,
            "index":index,
            "isEdit":false});
        },
        child: YachtWidget(yacht:yacht,
            width:Get.width*.85,height:Get.height*.2,isSmall:false,isShowStar: false,),
      );
  }

}