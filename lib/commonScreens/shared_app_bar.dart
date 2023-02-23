import 'package:dalddong/commonScreens/page_route_with_animation.dart';
import 'package:flutter/material.dart';

import '../functions/utilities/Utility.dart';
import '../main.dart';
import 'alarm_screen.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {

  BaseAppBar({
    required this.appBar,
    required this.title,
    required this.backBtn,
    this.center = false,
    this.hasLogout = false,
    Icon});


  final AppBar appBar;
  final String title;
  final bool center;
  final bool backBtn;
  final bool hasLogout;


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
      title: Text("$title", style: const TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w700),),

      actions: <Widget>[
        if(hasLogout)
          IconButton(
            onPressed: () async{

              var logout = await yesNoDialog(context, "로그아웃 하시겠습니까?");
              if(logout!){
                await signOut();

                PageRouteWithAnimation pageRoute = PageRouteWithAnimation(MyApp());
                Navigator.push(context, pageRoute.slideRitghtToLeft());
              }

            },
            icon: const Icon(Icons.exit_to_app),
          ),

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

        IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.black,
          ), // 설정 아이콘 생성
          onPressed: () {
            // 아이콘 버튼 실행
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}