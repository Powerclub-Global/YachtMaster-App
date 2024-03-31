
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as b;

import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/services/notification_service.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/model/user_data.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';

import '../../../../../constants/enums.dart';
import '../../../../../constants/fb_collections.dart';
import '../../../../../resources/resources.dart';
import '../../../../../utils/text_size.dart';
import '../../../../../utils/widgets/show_image.dart';
import '../../../../auth/vm/auth_vm.dart';
import '../model/chat_head_model.dart';
import '../model/chat_model.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _textController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final ScrollController chatHeadScrollController = ScrollController();
  final ScrollController chatScrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
  ChatHeadModel selectedChat = ChatHeadModel();
  UserModel selectedUser = UserModel();
  DateTime now = DateTime.now();
  String messageStr = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthVM>(builder: (context, authVm, _) {
      return StreamBuilder(
          stream: FBCollections.chatHeads
              .orderBy("last_message.created_at", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
            if (!chatSnapshot.hasData) {
              return const SizedBox();
            } else {
              List<ChatHeadModel> chatHeadsList = chatSnapshot.data?.docs
                      .map<ChatHeadModel>(
                          (e) => ChatHeadModel.fromJson(e.data()))
                      .toList() ??
                  [];
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: EdgeInsets.symmetric(horizontal: 3.sp, vertical: 3.sp),
                decoration: BoxDecoration(
                  color: R.colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 2,
                          height: 15,
                          color: R.colors.themeMud,
                        ),
                        Text(
                          LocalizationMap.getTranslatedValues( "active_chats"),
                          style: R.textStyles.poppins(
                              fw: FontWeight.w600,
                              fs: 3.sp,
                              color: R.colors.greyColor),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2.sp,
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          chatHeadWidget(chatHeadsList, authVm),
                          chatWidget(authVm)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          });
    });
  }

  Widget chatHeadContainer(ChatHeadModel chatHeadModel, AuthVM authVm) {
    UserModel? ud=Provider.of<UserVM>(context,listen: false).userList.firstWhereOrNull((element) => chatHeadModel.id==element.uid);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child:  ud?.firstName.toString().isCaseInsensitiveContains(searchController.text)==true?
      GestureDetector(
        onTap: () async {

          selectedChat = chatHeadModel;
          selectedUser = ud!;
          await FBCollections.chatHeads
              .doc(chatHeadModel.id)
              .update({"last_message.is_seen": true});
          setState(() {});
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration:
          // chatHeadModel.lastMessage?.senderId ==
          //     authVm.userData.uid?
          //     ? const BoxDecoration():
          //        chatHeadModel.lastMessage?.isSeen ?? false
          //     ? const BoxDecoration()
          //     :
          selectedChat.id==chatHeadModel.id?    BoxDecoration(
              color: R.colors.textFieldFillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: R.colors.themeMud)):BoxDecoration(),
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                    width: 30,
                    height: 30,
                    child:
                    DisplayImage.showImage(ud?.imageUrl ?? "")),
              ),
              SizedBox(
                width: 2.sp,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          ud?.firstName ?? "",
                          style: R.textStyles.poppins(
                              color: R.colors.greyColor
                                  ,
                              fs: 3.sp,
                              fw: FontWeight.w600),
                        ),
                        chatHeadModel.lastMessage?.senderId ==
                            authVm.userData.uid
                            ? Text(
                          timeago.format(
                              chatHeadModel
                                  .lastMessage?.createdAt
                                  ?.toDate() ??
                                  now,
                              locale: 'en_short'),
                          style: R.textStyles.poppins(
                              color: R.colors.greyColor, fs: 2.sp),
                        )
                            : chatHeadModel.lastMessage!.isSeen!
                            ?
                        Text(
                          timeago.format(
                              chatHeadModel.lastMessage
                                  ?.createdAt
                                  ?.toDate() ??
                                  now,
                              locale: 'en_short'),
                          style: R.textStyles.poppins(
                              color: R.colors.greyColor,
                              fs: 2.sp),
                        )
                            : b.Badge(
                          badgeContent: Text(
                            '',
                            style: R.textStyles.poppins(
                                color: R.colors.white,
                                fs: 2.5.sp),
                          ),
                        )
                      ],
                    ),
                    Text(
                      chatHeadModel.lastMessage?.message ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: R.textStyles.poppins(
                          color: chatHeadModel.lastMessage?.isSeen ??
                              false
                              ? R.colors.white
                              : R.colors.greyColor,
                          fs: 2.sp,
                          fw: FontWeight.w600),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ):SizedBox()

    );
  }

  Widget chatHeadWidget(List<ChatHeadModel> chatHeadsList, AuthVM authVm) {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            style: R.textStyles.poppins(
              color: R.colors.offWhite,
              fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 15),
              fw: FontWeight.w300,
            ),
            controller: searchController,
            onChanged: (s) {
              setState(() {});
            },
            decoration: R.decoration.fieldDecoration(hintText: "search_people"),
          ),
          SizedBox(
            height: 1.5.sp,
          ),
          Expanded(
            child: ListView.builder(
                controller: chatHeadScrollController,
                itemCount: chatHeadsList.length,
                itemBuilder: (context, index) {
                  return chatHeadContainer(chatHeadsList[index], authVm);
                }),
          )
        ],
      ),
    );
  }

  Widget chatWidget(AuthVM authVM) {
    return Expanded(
      flex: 7,
      child: selectedChat.lastMessage == null
          ?  Center(
              child: Text("No data",  style: R.textStyles.poppins(
              fw: FontWeight.w600,
                  fs: 3.sp,
                  color: R.colors.greyColor),),
            )
          : StreamBuilder(
              stream: FBCollections.chatHeads
                  .doc(selectedChat.id)
                  .collection("messages")
                  .orderBy("created_at", descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                if (!chatSnapshot.hasData) {
                  return const SizedBox();
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          decoration: BoxDecoration(
                            color: R.colors.textFieldFillColor,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                topLeft: Radius.circular(12)),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(selectedUser.firstName ?? "" ,style: R.textStyles.poppins(
                            fw: FontWeight.w600,
                                fs: 3.sp,
                                color: R.colors.greyColor),),
                          ),
                        ),
                        // Text(
                        //   DateFormat("EEEE hh:mm a").format((selectedChat.createdAt?.toDate()??now)),
                        //   style: R.textStyles
                        //       .poppins()
                        //       .copyWith(fontSize: 2.sp, color: R.colors.greyColor),
                        // ),

                        
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: R.colors.textFieldFillColor,
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12)),
                            ),

                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 60.0),
                                  child: ListView.builder(
                                    // separatorBuilder: (context, index) {
                                    //      if(selectedChat.createdAt?.toDate().)
                                    //       return Text(DateFormat("EEEE hh:mma").format(selectedChat.createdAt?.toDate()??DateTime.now()),textAlign: TextAlign.center,);
                                      
                                    // },
                                      controller: chatScrollController,
                                      itemCount:
                                          (chatSnapshot.data?.docs.length ?? 0),
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        
                                          ChatModel message = ChatModel.fromJson(
                                            chatSnapshot.data?.docs[index]);
                                             return chatMessageContainer(
                                            message, authVM);
                                        
                                       
                                      }),
                                ),
                                Shortcuts(
                                    shortcuts: {
                                      LogicalKeySet(LogicalKeyboardKey.shift,
                                              LogicalKeyboardKey.enter):
                                          Testfield1ShorcutIntent(),
                                      LogicalKeySet(LogicalKeyboardKey.enter):
                                          Testfield2ShorcutIntent(),
                                    },
                                    child: Actions(
                                      actions: {
                                        Testfield1ShorcutIntent: CallbackAction<
                                                Testfield1ShorcutIntent>(
                                            onInvoke: (intent) {
                                          print('clicked cnrl + D');
                                          if (_focusNode.hasFocus) {
                                            int cursorPos = _textController
                                                .selection.base.offset;
                                            _textController.text = _textController.text + '\n' + "";
                                            _textController.selection =
                                                TextSelection.fromPosition(
                                                    TextPosition(
                                                        offset: cursorPos + 1));
                                          }
                                        }),
                                        Testfield2ShorcutIntent: CallbackAction<
                                                Testfield2ShorcutIntent>(
                                            onInvoke: (intent) async {

                                          if (_focusNode.hasFocus) {
                                            if (_textController.text.isEmpty) {
                                              ZBotToast.showToastError(message:
                                                  "Enter message");
                                            } else {
                                              messageStr = _textController.text;
                                              _textController.clear();
                                              ChatModel newMessage = ChatModel(
                                                isSeen: false,
                                                message: messageStr,
                                                createdAt: Timestamp.now(),
                                                senderId:
                                                    authVM.userData.uid,
                                                receiverId: selectedUser.uid,
                                                type: UserType.admin.index,
                                                chatHeadId: selectedChat.id,
                                              );
                                              await sendMessage(newMessage , selectedUser);
                                              setState(() {});
                                            }
                                          }
                                        }),
                                      },
                                      child: TextFormField(
                                        focusNode: _focusNode,
                                        controller: _textController,
                                        maxLines: null,

                                        onChanged: (value) {},
                                        // onFieldSubmitted: (s) async {
                                        //   if (_textController.text.isEmpty) {
                                        //     ShowMessage.errorSnackBar(
                                        //         "Enter message");
                                        //   } else {
                                        //     messageStr = _textController.text;
                                        //     _textController.clear();
                                        //     ChatModel newMessage = ChatModel(
                                        //       isSeen: false,
                                        //       message: messageStr,
                                        //       createdAt: Timestamp.now(),
                                        //       senderId: authVM.userData.uid,
                                        //       receiverId: selectedUser.uid,
                                        //       updatedAt: Timestamp.now(),
                                        //       type: UserRoleEnum.doctor.index,
                                        //       chatHeadId: selectedChat.id,
                                        //     );
                                        //     await sendMessage(newMessage);
                                        //     setState(() {});
                                        //   }
                                        // },

                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.all(20),
                                          fillColor: R.colors.white,
                                          hintText: LocalizationMap.getTranslatedValues(
                                               "enter_message"),
                                          suffixIcon: Container(
                                              margin: EdgeInsets.only(
                                                  right: Get.width * 0.005),
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    if (_textController
                                                        .text.trim().isEmpty) {
                                                      ZBotToast.showToastError(message:
                                                          "Enter message");
                                                    } else {
                                                      messageStr =
                                                          _textController.text;
                                                      _textController.clear();
                                                      ChatModel newMessage =
                                                          ChatModel(
                                                        isSeen: false,
                                                        message: messageStr,
                                                        createdAt:
                                                            Timestamp.now(),
                                                        senderId: authVM
                                                            .userData.uid,
                                                        receiverId:
                                                            selectedUser.uid,
                                                        type: UserType
                                                            .admin.index,
                                                        chatHeadId:
                                                            selectedChat.id,
                                                      );
                                                      await sendMessage(
                                                          newMessage,selectedUser);
                                                      setState(() {});
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: R
                                                            .colors.themeMud),
                                                    child: Icon(
                                                      Icons.send,
                                                      color: R.colors.white,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                          hintStyle:
                                              R.textStyles.poppins().copyWith(
                                                    color: R.colors.greyColor,
                                                    fontSize: 3.sp,
                                                  ),
                                          isDense: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            borderSide: BorderSide(
                                                color: R.colors.themeMud),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            borderSide: BorderSide(
                                                color: R.colors.themeMud),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            borderSide: BorderSide(
                                                color: R.colors.themeMud),
                                          ),
                                          filled: true,
                                        ),
                                      ),
                                    )),
                             
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),
    );
  }

  Widget chatMessageContainer(ChatModel chatMessageModel, AuthVM authVm) {
    if (chatMessageModel.receiverId != authVm.userData.uid) {
      return Align(
          alignment: Alignment.centerRight,
          child: senderBubble(chatMessageModel));
    } else {
      return Align(
          alignment: Alignment.centerLeft,
          child: receiverBubble(chatMessageModel));
    }
  }

  Widget senderBubble(ChatModel chatMessageModel) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          color: R.colors.themeMud,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(constraints: BoxConstraints(
                  maxWidth: 30.w,
                  minWidth: 1,
                ),
            child: Text(
              chatMessageModel.message!,
              style: R.textStyles.poppins(color: R.colors.white),
            ),
          ),
          SizedBox(
            height: 1.sp,
          ),
          Text(
            timeago.format(chatMessageModel.createdAt?.toDate() ?? now,
                locale: 'en_short'),
            style: R.textStyles.poppins(color: R.colors.white, fs: 2.sp),
          ),
        ],
      ),
    );
  }

  Widget receiverBubble(ChatModel chatMessageModel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: SizedBox(
            width: 30,
            height: 30,
            child: DisplayImage.showImage(selectedUser.imageUrl ?? ""),
          ),
        ),
        SizedBox(
          width: 1.sp,
        ),
        Container(
          alignment: Alignment.topLeft,
          // constraints: BoxConstraints(maxWidth: 30.w,minWidth: 5.w),
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: R.colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 30.w,
                  minWidth: 1,
                ),
                child: Text(
                  chatMessageModel.message!,
                  style: R.textStyles.poppins().copyWith(color: R.colors.black),
                ),
              ),
              SizedBox(
                height: 1.sp,
              ),
              Text(
                timeago.format(chatMessageModel.createdAt?.toDate() ?? now,
                    locale: 'en_short'),
                style: R.textStyles.poppins(fs: 2.sp,color: R.colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  sendMessage(
    ChatModel newMessage,
      UserModel user,
  ) async {
    selectedChat.lastMessage = newMessage;
    await FBCollections.chatHeads
        .doc(selectedChat.id)
        .set(selectedChat.toJson());
    await FBCollections.chatHeads
        .doc(selectedChat.id)
        .collection("messages")
        .add(newMessage.toJson());
    DocumentSnapshot? doc = await FBCollections.users.doc(selectedUser.uid).get();
    UserModel user = UserModel.fromJson(doc.data());
    if(!(user.isActiveUser ?? false)){
      NotificationService.sendNotification(fcmToken: user.fcm ?? "", title: "New Message By Admin", body: newMessage.message ?? "");
    }

    setState(() {});
  }
}

class Testfield1ShorcutIntent extends Intent {}

class Testfield2ShorcutIntent extends Intent {}


                             
