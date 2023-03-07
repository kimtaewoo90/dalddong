// flutter
import 'package:flutter/material.dart';

// screens
import 'package:dalddong/tabs/community/community_main_screen.dart';
import 'package:dalddong/tabs/chatting/chatting_main_screen.dart';
import 'package:dalddong/tabs/calendar/calendar_main_screen.dart';
import 'package:dalddong/tabs/friends/friends_main_screen.dart';
import 'package:dalddong/tabs/settings/settings_main_screen.dart';

import 'commonScreens/config.dart';



class MainScreen extends StatefulWidget {
  final int? initialIndex;
  const MainScreen( {Key? key, this.initialIndex = 2} ) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      bottom: true,
      top: false,
      child: DefaultTabController(
        length: 5,
        initialIndex: widget.initialIndex!,
        child: Scaffold(
          backgroundColor: GeneralUiConfig.backgroundColor,
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              FriendsScreen(),
              ChatRooms(),
              MySchedule(),
              CommunityScreen(),
              SettingsScreen(),
            ],
          ),

          bottomNavigationBar: SizedBox(
            height: 77,
            child: TabBar(

              tabs: [
                Tab(child: Column(
                    children: const [
                      Icon(Icons.perm_identity, color: Colors.black,),
                      FittedBox(fit: BoxFit.fitWidth, child: Text('친구'))])
                ),
                Tab(child: Column(
                    children: const [
                      Icon(Icons.question_answer_outlined, color: Colors.black,),
                      FittedBox(fit: BoxFit.fitWidth, child: Text('채팅'))])
                ),
                Tab(child: Column(
                    children: const [
                      Icon(Icons.calendar_month_outlined, color: Colors.black, size: 25,),
                      FittedBox(fit: BoxFit.fitWidth, child: Text('캘린더'))])
                ),
                Tab(child: Column(
                    children: const [
                      Icon(Icons.spoke_outlined, color: Colors.black,),
                      FittedBox(fit: BoxFit.fitWidth, child: Text('커뮤니티'))])
                ),
                Tab(child: Column(
                    children: const [
                      Icon(Icons.account_circle_outlined, color: Colors.black,),
                      FittedBox(fit: BoxFit.fitWidth, child: Text('MY'))])
                ),
            ],
              // indicatorColor: GeneralUiConfig.titleTextColor,
              indicatorSize: TabBarIndicatorSize.tab,

            ),
          ),
        ),
      ),
    );
  }
}
