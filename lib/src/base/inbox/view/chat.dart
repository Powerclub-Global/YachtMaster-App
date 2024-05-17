import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:developer'as msg;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../appwrite.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../../../../services/time_schedule_service.dart';
import '../../../auth/view_model/auth_vm.dart';
import '../../base_vm.dart';
import '../model/chat_heads_model.dart';
import '../model/chat_model.dart';
import '../view_model/inbox_vm.dart';

import '../../../../utils/heights_widths.dart';
import 'dart:ui' as ui;

import '../../../../services/notification_service.dart';
import '../../profile/view/host_profile_others.dart';

class ChatView extends StatefulWidget {
  static String route = "/chatView";
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  ScrollController? scrollController;
  TextEditingController msgCon = TextEditingController();
  FocusNode msgFn = FocusNode();
  ChatHeadModel? chatHeadModel;
  QuerySnapshot? chatDocsLen;
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      chatHeadModel = args["chatHeadModel"];
      try {
        QuerySnapshot chatDocsLen= await FbCollections.chat.where("chat_head_id",isEqualTo: chatHeadModel?.id).get();
        msg.log("))))${chatDocsLen.docs.length}");
        if(chatDocsLen.docs.isNotEmpty)
          {
            Future.delayed(const Duration(seconds: 2), () {
              scrollController?.animateTo(scrollController?.position.minScrollExtent??0,
                  duration: const Duration(microseconds: 1), curve: Curves.easeIn);
            });
          }
        else{
         scrollController= ScrollController(initialScrollOffset: 0.0);
        }
        setState(() {

        });
      } on Exception catch (e) {
        // TODO
        debugPrintStack();
        msg.log(e.toString());
      }
    });

    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    var args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    chatHeadModel = args["chatHeadModel"];
    return Consumer2<BaseVm,InboxVm>(builder: (context, baseVm,model, _) {
      msg.log("____id:${baseVm.allUsers.length}");
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          backgroundColor: R.colors.black,
          resizeToAvoidBottomInset: true,
          appBar: PreferredSize(
            preferredSize: ui.Size.fromHeight(50),
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(baseVm.allUsers.firstWhereOrNull((element) => chatHeadModel?.users?.where((element) => element!=appwrite.user.$id).first==element.uid)?.firstName??"",
                      style: R.textStyle
                      .helveticaBold()
                          .copyWith(color: R.colors.whiteDull)),
                leading: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: R.colors.whiteColor,
                    )),
              ),
            ),
          ),
          body: Column(
            children: [
              h2,
              Text(
                (chatHeadModel?.createdAt?.toDate()??now).formateDateChatNow(),
                style: R.textStyle
                    .helveticaBold()
                    .copyWith(fontSize: 8.sp, color: R.colors.whiteDull),
              ),
              h2,
              conversation(model,baseVm),
              customTextFieldMessage(model)
            ],
          ),
        ),
      );
    });
  }

  Widget conversation(InboxVm model,BaseVm baseVm) {
    return
      Expanded(
        child:baseVm.allUsers.isEmpty?SizedBox():
        StreamBuilder(
            stream: FbCollections.chat.
            where("chat_head_id",isEqualTo: chatHeadModel?.id).
            orderBy("created_at",descending:false).
            snapshots(),
            builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
              if(!snapshot.hasData)
              {
                return SizedBox();
              }
            else{
                return
                  ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: ListView.separated(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      ChatModel chatModel=ChatModel.fromJson(snapshot.data?.docs[index].data());

                      return
                        chatModel.senderId==appwrite.user.$id?
                        senderBubble(chatModel,baseVm):
                      receiverBubble(chatModel,baseVm);
                    },
                    itemCount: snapshot.data?.docs.length??0,
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),

                    separatorBuilder: (BuildContext context, int index) {
                      return Container();
                    },
                  ),
                );
              }
          }
        ),
      );
  }
Widget senderBubble(ChatModel chatModel,BaseVm baseVm)
{
  return Row(crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
        Padding(
        padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.30),
                blurRadius: 8,
                spreadRadius: .002,
                offset: Offset(0, 4),
              ),
            ],
          ),
          width: Get.width * .7,
          child: Container(
            decoration: BoxDecoration(
                color:R.colors.blackDull,
                borderRadius:
                BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12))),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Row(
                  children: [
                    Container(
                      width: Get.width * .6,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Get.width * .02,),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            h1P5,
                            Padding(
                              padding:  EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                  baseVm.allUsers.where((element) => element.uid==chatModel.senderId).first.firstName??"",
                                  style: R.textStyle
                                      .helvetica()
                                      .copyWith(
                                      color: Colors.white,
                                      fontSize:
                                      Get.width * .04)),
                            ),
                            Text(
                                "${chatModel.message}",
                                style: R.textStyle
                                    .helvetica()
                                    .copyWith(
                                    color: chatModel.senderId == appwrite.user.$id
                                        ? R.colors.whiteColor
                                        : R.colors.blackDull,
                                    fontSize:
                                    Get.width * .033)),
                            h2
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: Get.width * .02,
                      right: Get.height * .01),
                  child: Text(
                      "${DateFormat.jm().format(chatModel.createdAt?.toDate()??now).toString().toLowerCase()}",
                      style: R.textStyle.helvetica().copyWith(
                          color: chatModel.senderId == appwrite.user.$id
                              ? R.colors.whiteColor
                              : R.colors.black,
                          fontSize: 7.sp)),
                )
              ],
            ),
          ),
        ),
      ),
      CircularProfileAvatar(
        "",
        radius: 12.sp,
        child:
        CachedNetworkImage(
          imageUrl:
          baseVm.allUsers.where((element) => element.uid==chatModel.senderId).first.imageUrl??"",
          // peerSnap.data?.get("image_url"),
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              SpinKitPulse(color: R.colors.themeMud,),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      )

    ],
  );
}
  Widget receiverBubble(ChatModel chatModel,BaseVm baseVm)
  {
    return
      baseVm.allUsers.firstWhereOrNull((element) => element.uid==chatHeadModel?.users?.firstWhereOrNull((e) => e!=appwrite.user.$id))==null?
          SizedBox():
      Row(crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (){
            Get.toNamed(HostProfileOthers.route,arguments: {"host":baseVm.allUsers.firstWhereOrNull((element) => chatHeadModel?.users?.where((element) => element!=appwrite.user.$id).first==element.uid)});

          },
          child: CircularProfileAvatar(
            "",
            radius: 12.sp,
            child:
            CachedNetworkImage(
              imageUrl:
              baseVm.allUsers.where((element) => element.uid==chatHeadModel!.users!.where((element) => element!=appwrite.user.$id).first).first.imageUrl??"",
              // peerSnap.data?.get("image_url"),
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  SpinKitPulse(color: R.colors.themeMud,),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.30),
                  blurRadius: 8,
                  spreadRadius: .002,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            width: Get.width * .7,
            child: Container(
              decoration: BoxDecoration(
                  color:  R.colors.milkyWhite,
                  borderRadius:
                   BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12))),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Row(
                    children: [
                      Container(
                        width: Get.width * .6,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Get.width * .02,),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              h1P5,
                              Padding(
                                padding:  EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                    baseVm.allUsers.where((element) => element.uid==chatHeadModel!.users!.where((element) => element!=appwrite.user.$id).first).first.firstName??"",

                                    style: R.textStyle
                                        .helvetica()
                                        .copyWith(
                                        color: R.colors.blackDull,
                                        fontSize:
                                        Get.width * .04)),
                              ),
                              Text(
                                  "${chatModel.message}",
                                  style: R.textStyle
                                      .helvetica()
                                      .copyWith(
                                      color: chatModel.senderId == appwrite.user.$id
                                          ? R.colors.whiteColor
                                          : R.colors.blackDull,
                                      fontSize:
                                      Get.width * .033)),
                              h2
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: Get.width * .02,
                        right: Get.height * .01),
                    child: Text("${DateFormat.jm().format(chatModel.createdAt?.toDate()??now).toString().toLowerCase()}",
                        style: R.textStyle.helvetica().copyWith(
                            color:  R.colors.black,
                            fontSize: 7.sp)),
                  )
                ],
              ),
            ),
          ),
        ),

      ],
    );
  }
  Widget customTextFieldMessage(InboxVm provider) {
    return Container(
      decoration: BoxDecoration(
        color: R.colors.blackDull,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.50),
            blurRadius: 8,
            spreadRadius: .002,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              // flex: null,
              child: TextFormField(
                controller: msgCon,
                focusNode: msgFn,
                style: R.textStyle.helvetica().copyWith(fontSize: 10.sp),
                decoration: InputDecoration(
                  constraints: BoxConstraints(
                      minHeight: Get.height * .045,
                      maxHeight: Get.height * .045),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  hintText: 'Start Typing...',
                  hintStyle: R.textStyle.helvetica().copyWith(fontSize: 10.sp),
                  fillColor: R.colors.milkyWhite,
                  filled: true,
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: R.colors.whiteColor,
                      )),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: R.colors.whiteColor)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: R.colors.whiteColor)),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                setState(() {});
                if (scrollController?.positions.isNotEmpty==true) {
                  scrollController?.animateTo(
                      scrollController?.position.maxScrollExtent??0.0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                }

                if (msgCon.text.trim().isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Please type something",
                      backgroundColor: R.colors.themeMud);
                }
                else {
                  BaseVm baseVm=Provider.of<BaseVm>(context,listen: false);
                  String docID=Timestamp.now().millisecondsSinceEpoch.toString();
                  Timestamp lastMessageTime=Timestamp.now();
                    ChatModel chatModel=ChatModel(
                     message: msgCon.text,
                     createdAt: lastMessageTime,
                     // DateFormat("hh:mm a")
                     //     .format(DateTime.now())
                     //     .toLowerCase(),
                     senderId: appwrite.user.$id,
                     chatHeadId: chatHeadModel?.id,
                     type: 0,
                     isSeen: false,
                     receiverId:chatHeadModel?.users?.where((element) => element!=appwrite.user.$id).toList().first
                 );
                    chatHeadModel?.lastMessageTime=lastMessageTime;
                    chatHeadModel?.lastMessage=msgCon.text;
                    setState(() {});
                  try {
                    String notficationBody=msgCon.text;
                    msgCon.clear();
                    scrollController?.animateTo((scrollController?.position.maxScrollExtent??0)*1000, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                    setState(() {});
                    FocusScope.of(context).requestFocus(new FocusNode());
                    await FbCollections.chatHeads.doc(chatHeadModel?.id).set(chatHeadModel?.toJson());
                    await FbCollections.chat.doc(docID).set(chatModel.toJson());
                    await sendNotification(notficationBody,baseVm);

                  } on Exception catch (e) {
                    // TODO
                    debugPrintStack();
                    print(e.toString());
                  }

                }
              },
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  //  padding: EdgeInsets.symmetric(horizontal:5),
                  height: 36,
                  width: 38,
                  padding: EdgeInsets.only(bottom: 2, right: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: R.colors.themeMud,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  )),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> sendNotification(String notficationBody,BaseVm baseVm
      ) async {
    try {
      await  NotificationService.sendNotification(
            fcmToken: baseVm.allUsers.firstWhereOrNull((element) => chatHeadModel?.users?.where((element) => element!=appwrite.user.$id).first==element.uid)?.fcm??"",
            title: "New Message",
            body: notficationBody);

    } catch (e) {
      print(e.toString());
    }
  }

}

