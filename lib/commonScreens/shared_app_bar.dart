import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/page_route_with_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../functions/providers/new_message_provider.dart';
import '../functions/utilities/Utility.dart';
import '../functions/utilities/utilities_chat.dart';
import '../main.dart';
import '../tabs/chatting/chatting_screen.dart';
import 'alarm_screen.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {

  BaseAppBar({
    required this.appBar,
    required this.title,
    required this.backBtn,
    this.center = false,
    this.hasLogout = false,
    this.hasIcon = true,
    this.isCreateChatRoom = false,
    Icon});


  final AppBar appBar;
  final String title;
  final bool center;
  final bool backBtn;
  final bool hasLogout;
  final bool hasIcon;
  final bool isCreateChatRoom;


  @override
  Widget build(BuildContext context) {
    return AppBar(
      // leading: IconButton(
      //   icon: Image.asset("assets/images/ic_chevron_30_back.png", width: 24, height: 24,),
      //   onPressed: () => Navigator.of(context).pop(),
      // ),
      automaticallyImplyLeading: backBtn,
      // backgroundColor: const Color(0xff025645),
      backgroundColor: Colors.white,
      centerTitle: center,
      title: Text(title, style: const TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w700),),

      actions: <Widget>[
        if(hasLogout && hasIcon)
          IconButton(
            onPressed: () async{

              var logout = await yesNoDialog(context, "로그아웃 하시겠습니까?");
              if(logout!){
                await signOut();

                PageRouteWithAnimation pageRoute = PageRouteWithAnimation(MyApp());
                if(context.mounted) {
                  Navigator.push(context, pageRoute.slideRitghtToLeft());
                }
              }

            },
            icon: const Icon(Icons.exit_to_app),
          ),

        if(hasLogout && hasIcon)
          IconButton(
          icon: const Icon(
            Icons.add_alert,
            color: Colors.black,
          ), // 알림 아이콘 생성
          onPressed: () {
            PageRouteWithAnimation pageRoute = PageRouteWithAnimation(const AlarmScreen());
            Navigator.push(context, pageRoute.slideBottonToTop());
          },
        ),

        if(hasLogout && hasIcon)
          IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.black,
          ), // 설정 아이콘 생성
          onPressed: () {
            // 아이콘 버튼 실행
          },
        ),

        if(isCreateChatRoom)
          if (context.read<NewMessageProvider>().newMsgFriends.isEmpty)
            IconButton(onPressed: (){}, icon: const Icon(Icons.add), color: Colors.black,),
        if(isCreateChatRoom)
          if (context.read<NewMessageProvider>().newMsgFriends.length == 1)
            IconButton(
              icon: const Icon(Icons.add), // 설정 아이콘 생성
              color: Colors.black,
              onPressed: () async {
                // 아이콘 버튼 실행
                var newMsgFriendProvider =
                    context.read<NewMessageProvider>().newMsgFriends;
                var chatroomId = await makeNewChatRoom(
                    newMsgFriendProvider[0].get('userName'),
                    newMsgFriendProvider[0].get('userEmail'),
                    newMsgFriendProvider[0].get('userImage'));

                String title = await FirebaseFirestore.instance
                    .collection('user')
                    .doc(FirebaseAuth.instance.currentUser!.email)
                    .collection('chatRoomList')
                    .doc(chatroomId)
                    .get()
                    .then((value) {
                  return value.get('chatRoomName');

                });

                if(context.mounted) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatroomId, title),
                      ));
                }
              },
            ),
        if(isCreateChatRoom)
          if (context.read<NewMessageProvider>().newMsgFriends.length > 1)
            IconButton(
            icon: const Icon(Icons.add), // 설정 아이콘 생성
            color: Colors.black,
            onPressed: () async {
              // 아이콘 버튼 실행
              var chatroomId = await makeNewGroupChatRoom(
                  context.read<NewMessageProvider>().newMsgFriends);

              String title = await FirebaseFirestore.instance
                  .collection('user')
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .collection('chatRoomList')
                  .doc(chatroomId)
                  .get()
                  .then((value) {
                return value.get('chatRoomName');
              });

              if(context.mounted) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatroomId, title),
                    ));
              }
            },
          )

      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}