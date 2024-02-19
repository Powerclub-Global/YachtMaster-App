import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/model/favourite_model.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/widgets/charter_widget.dart';
import 'package:yacht_master/src/base/yacht/view/charter_detail.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/empty_screem.dart';

class ChartersView extends StatefulWidget {
  const ChartersView({Key? key}) : super(key: key);

  @override
  _ChartersViewState createState() => _ChartersViewState();
}

class _ChartersViewState extends State<ChartersView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<YachtVm>(
        builder: (context, yachtVm, _) {
          return
            yachtVm.userFavouritesList
                .where((element) => element.type == FavouriteType.charter.index)
                .toList()
                .isEmpty
                ?
          EmptyScreen(
            title: "no_charter",
            subtitle: "no_charter_has_been_saved_yet",
            img: R.images.noFav,
          ):
            ModalProgressHUD(
              inAsyncCall: yachtVm.isLoading,
              progressIndicator:SpinKitPulse(color: R.colors.themeMud,),
              child: Padding(
                padding: EdgeInsets.symmetric(
                   vertical: Get.height * .02),
                child: SingleChildScrollView(
                  child: Center(
                    child: Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      children: List.generate(
                          yachtVm.userFavouritesList
                              .where((element) =>
                          element.type == FavouriteType.charter.index)
                              .toList()
                              .length, (index) {
                        FavouriteModel favModel = yachtVm.userFavouritesList
                            .where((element) =>
                        element.type == FavouriteType.charter.index)
                            .toList()[index];
                        log("____________LEN:${favModel.id}");
                        return
                          FutureBuilder(
                            future:
                            FbCollections.charterFleet.doc(favModel.id).get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox();
                              } else {
                                CharterModel charter = CharterModel.fromJson(
                                    snapshot.data?.data());
                                log("++++++++++++++++++CHARTEE:${charter.id}");
                                return GestureDetector(
                                  onTap: () {
                                    Get.toNamed(CharterDetail.route, arguments: {
                                      "yacht": charter,
                                      "isReserve": false,
                                      "index":-1,
                                      "isEdit":false
                                    });
                                  },
                                  child: CharterWidget(
                                    charter: charter,
                                    width: Get.width * .85,
                                    height: Get.height * .2,
                                    isSmall: false,
                                    isFav: yachtVm.userFavouritesList.any(
                                            (element) =>
                                        element.favouriteItemId ==
                                            charter.id &&
                                            element.type ==
                                                FavouriteType.charter.index),
                                    isShowStar: true,
                                    isFavCallBack: () async {
                                      yachtVm.startLoader();
                                      FavouriteModel favModel =
                                      FavouriteModel(
                                          creaatedAt: Timestamp.now(),
                                          favouriteItemId: charter.id,
                                          id: charter.id,
                                          type: FavouriteType
                                              .charter.index);
                                      if (yachtVm.userFavouritesList.any(
                                              (element) =>
                                          element.id == charter.id &&
                                              element.type ==
                                                  FavouriteType
                                                      .charter.index)) {
                                        yachtVm.userFavouritesList
                                            .removeAt(index);
                                        yachtVm.update();
                                        try {
                                          await FbCollections.user
                                              .doc(FirebaseAuth
                                              .instance.currentUser?.uid)
                                              .collection("favourite")
                                              .doc(charter.id)
                                              .delete();
                                        } on Exception catch (e) {
                                          log(e.toString());
                                          yachtVm.stopLoader();
                                        }
                                      } else {
                                        try {
                                          await FbCollections.user
                                              .doc(FirebaseAuth
                                              .instance.currentUser?.uid)
                                              .collection("favourite")
                                              .doc(charter.id)
                                              .set(favModel.toJson());
                                        } on Exception catch (e) {
                                          log(e.toString());
                                          yachtVm.stopLoader();
                                        }
                                      }
                                      yachtVm.stopLoader();

                                      yachtVm.update();
                                    },
                                  ),
                                );
                              }
                            });
                      }),
                    ),
                  ),
                ),
              ),
            );

        }
    );
  }

}
