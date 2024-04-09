import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/favourites/view/charters.dart';
import 'package:yacht_master/src/base/favourites/view/experiences.dart';
import 'package:yacht_master/src/base/favourites/view/hosts.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class FavouritesView extends StatefulWidget {
  static String route = "/favouritesView";
  const FavouritesView({Key? key}) : super(key: key);

  @override
  _FavouritesViewState createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView> {
  List<String> tabsList = ["charters", "experience", "hosts"];
  int selectedTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          h6,
          Container(
            padding: EdgeInsets.only(left: Get.width * .04),
            child: Row(
              children: List.generate(tabsList.length, (index) {
                return tabs(tabsList[index], index);
              }),
            ),
          ),
          if (selectedTabIndex == 0)
            Expanded(child: ChartersView())
          else if (selectedTabIndex == 1)
            Expanded(child: ExperiencesView())
          else
            Expanded(child: HostView()),
        ],
      ),
    );
  }

  Widget tabs(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: [
              Text(
                getTranslated(context, title) ?? "",
                style: R.textStyle.helveticaBold().copyWith(
                      color: selectedTabIndex == index
                          ? R.colors.yellowDark
                          : R.colors.whiteColor,
                    ),
              ),
              Divider(
                color: selectedTabIndex == index
                    ? R.colors.yellowDark
                    : R.colors.grey.withOpacity(.40),
                thickness: 2,
                height: Get.height * .03,
              )
            ],
          ),
        ),
      ),
    );
  }
}
