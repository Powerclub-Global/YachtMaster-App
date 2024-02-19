
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/model/favourite_model.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/base/profile/view/host_profile_others.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class HostView extends StatefulWidget {
  const HostView({Key? key}) : super(key: key);

  @override
  _HostViewState createState() => _HostViewState();
}

class _HostViewState extends State<HostView> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<YachtVm,SettingsVm>(
        builder: (context, yachtVm,settingsVm, _) {
          return
            yachtVm.userFavouritesList
                .where((element) => element.type == FavouriteType.host.index)
                .toList()
                .isEmpty?
            EmptyScreen(
              title: "no_host",
              subtitle: "no_host_has_been_saved_yet",
              img: R.images.noFav,
            )
                :
            ModalProgressHUD(
              inAsyncCall: yachtVm.isLoading,
              progressIndicator: SpinKitPulse(color: R.colors.themeMud,),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 1.w,
                     vertical: Get.height * .02),
                child: SingleChildScrollView(
                  child: Center(
                    child: Wrap(
                      spacing: 3,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      children: List.generate(
                          yachtVm.userFavouritesList
                              .where((element) =>
                          element.type == FavouriteType.host.index)
                              .toList()
                              .length, (index) {
                        FavouriteModel favModel = yachtVm.userFavouritesList
                            .where((element) =>
                        element.type == FavouriteType.host.index)
                            .toList()[index];

                        return FutureBuilder(
                            future:
                            FbCollections.user.doc(favModel.id).get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox();
                              }
                            else{
                                UserModel user = UserModel.fromJson(
                                    snapshot.data?.data());
                                return host(user,index,
                                  yachtVm.userFavouritesList.any((element) => element.favouriteItemId==user.uid && element.type==FavouriteType.host.index) ,
                                      () async {
                                    FavouriteModel favModel=FavouriteModel(
                                        creaatedAt: Timestamp.now(),
                                        favouriteItemId:user.uid,
                                        id: user.uid,
                                        type: FavouriteType.host.index
                                    );
                                    if(yachtVm.userFavouritesList.any((element) => element.id==user.uid))
                                    {
                                      yachtVm.userFavouritesList.removeAt(index);
                                      yachtVm.update();
                                      await FbCollections.user.doc(FirebaseAuth.instance.currentUser?.uid).collection("favourite").doc(user.uid).delete();
                                    }
                                    else
                                    {
                                      await FbCollections.user.doc(FirebaseAuth.instance.currentUser?.uid).collection("favourite").doc(user.uid).set(favModel.toJson());

                                    }
                                    yachtVm.update();
                                  },);
                              }
                          }
                        );
                      })
                    ),
                  ),
                ),
              ),
            );
        }
    );
  }
  Widget host(UserModel user,int index,bool isFav, Function() isFavCallBack) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(HostProfileOthers.route, arguments: {"host": user});
      },
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Container(
                  height: Get.height * .2,
                  width: Get.width * .28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: R.colors.whiteColor,
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child:user.imageUrl==""?
                          Image.network(
                            R.images.dummyDp,
                            fit: BoxFit.cover,
                          ):
                          Image.network(
                            user.imageUrl ?? R.images.dummyDp,
                            fit: BoxFit.cover,
                          )),),
                ),
                h1P5,
                Text(
                  user.firstName ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold),
                ),
                h1,
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Padding(
                //       padding: EdgeInsets.only(top: 4, right: 2),
                //       child: Text(
                //         "4.2",
                //         style: R.textStyle.helvetica().copyWith(
                //             color: R.colors.yellowDark,
                //             fontSize: 9.sp,
                //             fontWeight: FontWeight.bold),
                //       ),
                //     ),
                //     Icon(
                //       Icons.star,
                //       color: R.colors.yellowDark,
                //       size: 17,
                //     )
                //   ],
                // ),
              ],
            ),
          ),
          Positioned(
              top: 1,
              right: 3.w,
              child: GestureDetector(
                onTap: isFavCallBack,
                child: Container(
                  margin: EdgeInsets.all(4),
                  decoration:AppDecorations.favDecoration(),
                  child: Icon(
                      isFav == false
                          ? Icons.star_border_rounded
                          : Icons.star,
                      size: 30,
                      color: isFav == false
                          ? R.colors.whiteColor
                          : R.colors.yellowDark),
                ),
              ))
        ],
      ),
    );
  }

}
