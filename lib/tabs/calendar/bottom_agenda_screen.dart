import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:dalddong/tabs/calendar/schedule_modify_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../commonScreens/page_route_with_animation.dart';
import '../../functions/providers/calendar_provider.dart';
import '../chatting/chatting_screen.dart';

class BottomAgenda extends StatefulWidget {
  // final ScrollController controller;
  // final PanelController panelController;
  const BottomAgenda({Key? key}) : super(key: key);

  @override
  State<BottomAgenda> createState() => _BottomAgendaState();
}

class _BottomAgendaState extends State<BottomAgenda> {
  @override
  Widget build(BuildContext context) {
    if(context.read<ScheduleProvider>().appointmentDetails.isEmpty){
      return SizedBox(
          height : context.read<ScheduleProvider>().showAgenda ? 500 : 0,
          child: const Center(child: Text("일정이 없습니다!"),));
    }
    return Container(
      height: context.read<ScheduleProvider>().showAgenda ? 500 : 0,
      color: GeneralUiConfig.backgroundColor,
      child:
      ListView.separated(
        // controller: widget.controller,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(2),
        itemCount: context.read<ScheduleProvider>().appointmentDetails.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.all(2),
            height: 60,
            color: Color(int.parse(context
                .read<ScheduleProvider>()
                .appointmentDetails[index]
                .background)),
            child: ListTile(
              onTap: () async {
                if (context
                    .read<ScheduleProvider>()
                    .appointmentDetails[index]
                    .isAppointment == true) {
                  print("달똥완료 페이지로 이동");
                  // PageRouteWithAnimation pageRoute =
                  // PageRouteWithAnimation(CompleteAccept(dalddongId: _appointmentDetails[index].scheduleId,));
                  // Navigator.push(context, pageRoute.slideBottonToTop());
                  var chatRoomName = await FirebaseFirestore.instance
                      .collection('user')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .collection('chatRoomList')
                      .doc(context
                      .read<ScheduleProvider>()
                      .appointmentDetails[index]
                      .scheduleId)
                      .get()
                      .then((value) {
                    return value.get('chatRoomName');
                  });

                  PageRouteWithAnimation pageRoute =
                  PageRouteWithAnimation(ChatScreen(
                      context
                          .read<ScheduleProvider>()
                          .appointmentDetails[index]
                          .scheduleId,
                      chatRoomName));
                  await Navigator.push(
                      context, pageRoute.slideBottonToTop());
                } else {
                  PageRouteWithAnimation pageRoute =
                  PageRouteWithAnimation(ModifyDeleteSchedule(
                    meetingData: context
                        .read<ScheduleProvider>()
                        .appointmentDetails[index],
                  ));
                  Navigator.push(context, pageRoute.slideBottonToTop());
                }
              },
              leading:
              // if()
              Column(
                children: <Widget>[
                  Text(
                    context
                        .read<ScheduleProvider>()
                        .appointmentDetails[index]
                        .isAllDay
                        ? ''
                        : DateFormat('hh:mm a').format(context
                        .read<ScheduleProvider>()
                        .appointmentDetails[index]
                        .from),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.7),
                  ),
                  Text(
                    context
                        .read<ScheduleProvider>()
                        .appointmentDetails[index]
                        .isAllDay
                        ? 'All day'
                        : '',
                    style:
                    const TextStyle(height: 0.5, color: Colors.white),
                  ),
                  Text(
                    context
                        .read<ScheduleProvider>()
                        .appointmentDetails[index]
                        .isAllDay
                        ? ''
                        : DateFormat('hh:mm a').format(context
                        .read<ScheduleProvider>()
                        .appointmentDetails[index]
                        .to),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
              title: Text(
                  context
                      .read<ScheduleProvider>()
                      .appointmentDetails[index]
                      .eventName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
        const Divider(
          height: 5,
        ),
      ),
    );
  }
}
