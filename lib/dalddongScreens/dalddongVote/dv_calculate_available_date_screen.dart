import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dalddong/functions/pushManager/push_manager.dart';

import '../../functions/providers/calendar_provider.dart';
import 'dv_vote_screen.dart';


class WaitCalculateDates extends StatefulWidget {
  const WaitCalculateDates(
      {Key? key,
        required this.dalddongMembers,
        required this.dalddongId,
        required this.hostName})
      : super(key: key);
  final List<QueryDocumentSnapshot>? dalddongMembers;
  final String dalddongId;
  final String hostName;

  @override
  State<WaitCalculateDates> createState() => _WaitCalculateDatesState();
}

class _WaitCalculateDatesState extends State<WaitCalculateDates> {
  List<DateTime> blockedDates = [];
  List<DateTime> voteDates = [];
  int addedDate = 1;
  final _pushManager = PushManager();


  @override
  void initState() {
    super.initState();
  }

  void makeTheFirebaseCollection(List<DateTime> voteDates) {

    voteDates.forEach((element) {
      FirebaseFirestore.instance
          .collection('DalddongList')
          .doc(widget.dalddongId)
          .collection('voteDates')
          .doc(DateFormat('yyyy-MM-dd').format(element))
          .set({
        'voted': 0,
        'votedMembers': FieldValue.arrayUnion([]),
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    // add Members
    widget.dalddongMembers?.forEach((element) async{

      // get BlockDatesList among members
      await FirebaseFirestore.instance
          .collection('user')
          .doc(element.get('userEmail'))
          .collection('BlockDatesList') //.where('isDalddong', isEqualTo: true)
          .snapshots()
          .forEach((blockedCollection) {
        blockedCollection.docs.forEach((blocked) {
          blockedDates.add(DateTime.parse(blocked.id));
        });
      });
    });

    if(context.mounted){
      blockedDates = blockedDates.toSet().toList();
      Timer(const Duration(seconds: 5), () {
        while (true) {
          DateTime today = DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day);
          DateTime candidateDate = today.add(Duration(days: addedDate));
          if (blockedDates.contains(candidateDate) == false) {
            voteDates.add(candidateDate);
          }

          if (voteDates.length == 5) {
            // 계산된 투표날짜 리스트 insert
            makeTheFirebaseCollection(voteDates);

            widget.dalddongMembers?.forEach((element) {
              FirebaseFirestore.instance
                  .collection('user')
                  .doc(element.get('userEmail'))
                  .get()
                  .then((value) {
                var userToken = value.get('pushToken');
                var title = "달똥 날짜 투표";
                var body = "${widget.hostName} 님께서 달똥 날짜투표를 보내셨습니다.";
                var details = {
                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                  'id': widget.dalddongId,
                  'eventId': widget.dalddongId,
                  'eventType': "DDV",
                  'membersNum': widget.dalddongMembers?.length,
                  'hostName': widget.hostName,
                  'voteDates': voteDates
                };
                _pushManager.sendPushMsg(
                    userToken: userToken, title: title, body: body, details: details);
                print("send To ${element.get('userName')} using $userToken");
              });
            });

            // 임의로 3초 후 투표 화면으로 이동

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VoteScreen(
                        voteDates: voteDates,
                        dalddongId: widget.dalddongId
                    )));
            break;
          } else {
            addedDate += 1;
          }
        }
      });
    }

    return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/waiting.png'),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("달똥이 열심히 여러분의 \n 식사 일정을 잡고 있습니당!"),
            ],
          ),
        ));
  }
}
