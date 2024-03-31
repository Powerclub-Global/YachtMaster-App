import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/blocs/bloc_exports.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/search/view/what_looking_for.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class WhereGoing extends StatefulWidget {
  static String route = "/whereGoing";
  @override
  _WhereGoingState createState() => _WhereGoingState();
}

class _WhereGoingState extends State<WhereGoing> {
  TextEditingController searchCon = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var searchVm = Provider.of<SearchVm>(context, listen: false);
      searchVm.searchText = "";
      searchVm.update();
    });
  }

  bool isShowRecent = false;
  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchVm, YachtVm>(
        builder: (context, provider, yachtVm, _) {
      return BlocBuilder<CitiesBloc, CitiesState>(
        builder: (context, state) {
          provider.recentSearchCities = state.recentCities;
          return SafeArea(
            child: Scaffold(
              backgroundColor: R.colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                titleSpacing: 0,
                leading: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: R.colors.whiteColor,
                      size: 20,
                    )),
                title: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: R.colors.grey.withOpacity(.15)),
                  margin: EdgeInsets.only(right: 5.w),
                  child: TextFormField(
                    controller: searchCon,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.search,
                    style: R.textStyle.helvetica().copyWith(
                          color: R.colors.whiteColor,
                          fontSize: 16.sp,
                        ),
                    decoration: InputDecoration(
                        hintText: getTranslated(context, "search"),
                        hintStyle: R.textStyle.helvetica().copyWith(
                            color: R.colors.lightGrey, fontSize: 13.sp),
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        prefixIconConstraints: BoxConstraints(
                            maxHeight: 55,
                            minHeight: 55,
                            minWidth: 60,
                            maxWidth: 60),
                        prefixIcon: Image.asset(
                          R.images.search,
                          scale: 7,
                        ),
                        border: InputBorder.none),
                    onChanged: (value) {
                      isShowRecent = false;
                      provider.searchText =
                          value.removeAllWhitespace.toString().toLowerCase();
                      provider.update();
                      log("____________________SERAC:${provider.searchText}");
                    },
                    onTap: () {
                      setState(() {
                        isShowRecent = true;
                      });
                    },
                    onFieldSubmitted: (value) {
                      isShowRecent = false;
                      if (yachtVm.charterCities
                          .where((element) => element.removeAllWhitespace
                              .toLowerCase()
                              .toString()
                              .contains(provider.searchText))
                          .toList()
                          .isNotEmpty) {
                        log("______________________RESUK:${yachtVm.charterCities.where((element) => element.removeAllWhitespace.toLowerCase().toString().contains(provider.searchText)).first}________${provider.recentSearchCities.indexWhere((element) => element == yachtVm.charterCities.where((element) => element.removeAllWhitespace.toLowerCase().toString().contains(provider.searchText)).first)}");
                        if (provider.recentSearchCities.indexWhere((element) =>
                                element ==
                                yachtVm.charterCities
                                    .where((element) => element
                                        .removeAllWhitespace
                                        .toLowerCase()
                                        .toString()
                                        .contains(provider.searchText))
                                    .first) !=
                            -1) {
                          log("+++++++++++++++++++++++++++++++contains");
                          int swapToIndex = provider.recentSearchCities
                              .indexWhere((element) =>
                                  element ==
                                  yachtVm.charterCities
                                      .where((element) => element
                                          .removeAllWhitespace
                                          .toLowerCase()
                                          .toString()
                                          .contains(provider.searchText))
                                      .first);
                          context.read<CitiesBloc>().add(SwapCity(
                              provider.recentSearchCities[swapToIndex],
                              swapToIndex));
                        } else {
                          // provider.recentSearchCities.add(yachtVm.charterCities
                          //     .where((element) => element.removeAllWhitespace
                          //         .toLowerCase()
                          //         .toString()
                          //         .contains(provider.searchText))
                          //     .first);
                          context.read<CitiesBloc>().add(AddCity(yachtVm
                              .charterCities
                              .where((element) => element.removeAllWhitespace
                                  .toLowerCase()
                                  .toString()
                                  .contains(provider.searchText))
                              .first));
                        }
                      }
                      provider.update();
                      log("______________________RECEN LEN:${provider.recentSearchCities.length}");
                    },
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: InkWell(
                  onTap: () {
                    Helper.focusOut(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      h5,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(getTranslated(context, "where_you_going") ?? "",
                              style: R.textStyle.helveticaBold().copyWith(
                                  color: Colors.white, fontSize: 16.sp)),
                        ],
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: Get.width * .07),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            h5,
                            if ((provider.searchText.isEmpty &&
                                provider.recentSearchCities.isNotEmpty))
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        getTranslated(
                                                context, "recent_search") ??
                                            "",
                                        style: R.textStyle.helvetica().copyWith(
                                              color: R.colors.whiteDull,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.sp,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  h2P5,
                                  Column(
                                      children: List.generate(
                                          provider.recentSearchCities.length,
                                          (index) {
                                    return cityCard(
                                        provider.recentSearchCities[index],
                                        index,
                                        provider,
                                        provider.recentSearchCities);
                                  })),
                                ],
                              )
                            else if (provider.searchText.isNotEmpty &&
                                yachtVm.charterCities
                                    .where((element) => element
                                        .removeAllWhitespace
                                        .toLowerCase()
                                        .toString()
                                        .contains(provider.searchText))
                                    .toList()
                                    .isNotEmpty)
                              Column(
                                  children: List.generate(
                                      yachtVm.charterCities
                                          .where((element) => element
                                              .removeAllWhitespace
                                              .toLowerCase()
                                              .toString()
                                              .contains(provider.searchText))
                                          .toList()
                                          .length, (index) {
                                return cityCard(
                                    yachtVm.charterCities
                                        .where((element) => element
                                            .removeAllWhitespace
                                            .toLowerCase()
                                            .toString()
                                            .contains(provider.searchText))
                                        .toList()[index],
                                    index,
                                    provider,
                                    yachtVm.charterCities
                                        .where((element) => element
                                            .removeAllWhitespace
                                            .toLowerCase()
                                            .toString()
                                            .contains(provider.searchText))
                                        .toList());
                              }))
                            else
                              SizedBox(
                                height: Get.height * .5,
                                child: EmptyScreen(
                                  title: "no_search",
                                  subtitle: "no_result_has_been_found_yet",
                                  img: R.images.emptyResult,
                                ),
                              ),
                            h1,
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget cityCard(
      String city, int index, SearchVm provider, List<String> list) {
    return InkWell(
      onTap: () {
        if (!provider.recentSearchCities.contains(city)) {
          context.read<CitiesBloc>().add(InsertCity(city, 0));
          provider.update();
        } else if (provider.recentSearchCities.contains(city)) {
          String temp;
          int i = provider.recentSearchCities.indexOf(city);
          temp = provider.recentSearchCities[i];
          provider.recentSearchCities[i] = provider.recentSearchCities.first;
          context.read<CitiesBloc>().add(UpdateCity(temp, 0));
          provider.update();
        }
        provider.selectedCity = city;
        provider.update();
        log("_____________SELECTED CITY:${city}");
        Get.toNamed(WhatLookingFor.route,
            arguments: {"cityModel": city, "yacht": null, "isReserve": true});
      },
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    R.images.v1,
                    height: Get.height * .09,
                  )),
              w4,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
                    style: R.textStyle
                        .helveticaBold()
                        .copyWith(color: R.colors.whiteDull, fontSize: 15.sp),
                  ),
                ],
              )
            ],
          ),
          if (index == list.length - 1)
            SizedBox()
          else
            SizedBox(
                width: Get.width * .9,
                child: Divider(
                  color: R.colors.grey.withOpacity(.40),
                  thickness: 2,
                  height: Get.height * .03,
                ))
        ],
      ),
    );
  }
}
