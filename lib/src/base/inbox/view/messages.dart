import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/base/inbox/model/chat_heads_model.dart';
import 'package:yacht_master/src/base/inbox/view/chat.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<InboxVm>(
        builder: (context, provider, _) {
          return
            StreamBuilder(
              stream: FbCollections.chatHeads.
              where("users",arrayContains: FirebaseAuth.instance.currentUser?.uid).
              orderBy("last_message_time",descending:true).
              snapshots(),
              builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
                if(!snapshot.hasData || snapshot.data?.docs.isEmpty==true)
                  {
                    return  Center(
                      child: SizedBox(height: Get.height*.7,
                        child: EmptyScreen(
                          title: "no_message",
                          subtitle: "no_message_has_been_received_send_yet",
                          img: R.images.noChat,
                        ),
                      ),
                    );
                  }
                else{
                  log("___________here${snapshot.data?.docs.length}");
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * .04,vertical: Get.height*.02),
                    child: Column(
                        children: List.generate(snapshot.data?.docs.length??0, (index) {
                          log("___________LEN:${snapshot.data?.docs[index].id}");

                          ChatHeadModel chatHeadModel=ChatHeadModel.fromJson(snapshot.data?.docs[index].data());
                          if(snapshot.data?.docs[index].data()==null)
                            {
                              return SizedBox();
                            }
                          else{
                            return chatHeads(chatHeadModel,
                                isDivider:index==(snapshot.data?.docs.length??0)-1?false:true);
                          }
                        })),
                  );
                }
              }
            );
      }
    );
  }

  Widget chatHeads(ChatHeadModel chatHead,{bool? isDivider=true}) {
    log("______ID:${chatHead.id}");
    return GestureDetector(
      onTap: (){
        // FbCollections.chat.doc("RdswmjZs0k0Q0MiqDhkE").get().then((value) {
        //   log("${jsonEncode(value.data())}");
        // });
        Get.toNamed(ChatView.route,arguments: {"chatHeadModel":chatHead});
      },
      child: Container(
        color: Colors.transparent,
        child: FutureBuilder(
          future: FbCollections.user.doc(chatHead.users!.where((element) => element!=FirebaseAuth.instance.currentUser!.uid).first).get(),
          builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {
            if(!snapshot.hasData)
              {
                return SizedBox();
              }
            else{
              UserModel userModel=UserModel.fromJson(snapshot.data?.data());
              return
                Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        color: Colors.transparent,
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircularProfileAvatar(
                              "",
                              radius: 20.sp,
                              child:
                              CachedNetworkImage(
                                imageUrl:  userModel.imageUrl?? "",
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    SpinKitPulse(color: R.colors.themeMud,),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                            w2,
                            SizedBox(width: Get.width*.75,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        userModel.firstName??"",
                                        style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteColor,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      Text(
                                        "${timeago.format(chatHead.lastMessageTime?.toDate()??DateTime.now(), locale: 'en_short')}",
                                        style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteColor,
                                          fontSize: 7.sp,
                                        ),
                                      )
                                    ],
                                  ),
                                  h0P5,
                                  Text(
                                    chatHead.lastMessage??"",
                                    style: R.textStyle.helvetica().copyWith(
                                        color: R.colors.whiteDull,fontWeight: FontWeight.bold,
                                        fontSize: 10.sp,height: 1.1
                                    ),maxLines: 3,overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isDivider==false) SizedBox() else Divider(
                    color: R.colors.grey.withOpacity(.40),
                    thickness: 2,
                    height: Get.height * .035,
                  )
                ],
              );

            }
          }
        ),
      ),
    );
  }
}
