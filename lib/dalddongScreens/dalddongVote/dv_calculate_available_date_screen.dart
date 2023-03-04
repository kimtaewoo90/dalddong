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
        required this.chatroomId,
        required this.hostName})
      : super(key: key);
  final List<QueryDocumentSnapshot>? dalddongMembers;
  final String? chatroomId;
  final String? hostName;

  @override
  State<WaitCalculateDates> createState() => _WaitCalculateDatesState();
}

class _WaitCalculateDatesState extends State<WaitCalculateDates> {
  List<DateTime> blockedDates = [];
  List<DateTime> voteDates = [];
  int addedDate = 1;

  @override
  void initState() {
    super.initState();
  }

  void makeTheFirebaseCollection(List<DateTime> voteDates) {
    print('makeTheFirebaseCollection');
    voteDates.forEach((element) {
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatroomId)
          .collection('dalddong')
          .doc(widget.chatroomId)
          .collection('voteDates')
          .doc(DateFormat('yyyy-MM-dd').format(element))
          .set({
        'voted': 0,
        'votedMembers': FieldValue.arrayUnion([]),
      });
    });

    // 투표생성시간 입력
    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatroomId)
        .collection('dalddong')
        .doc(widget.chatroomId)
        .collection('ExpiredTime')
        .doc('ExpiredTime')
        .set({
      'ExpiredTime': DateTime.now().add(const Duration(hours: 24)),
    });
  }

  void finalStep(PushManager pushManager){

    print("------------finalStep");
    widget.dalddongMembers?.forEach((element) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(element.get('userEmail'))
          .get()
          .then((value) {
        print(element.get('userEmail'));
        var userToken = value.get('pushToken');
        var title = "달똥 날짜 투표";
        var body = "${widget.hostName} 님께서 달똥 날짜투표를 보내셨습니다.";
        var details = {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': "",
          'eventId': widget.chatroomId,
          'eventType': "DDV",
          'membersNum': widget.dalddongMembers?.length,
          'hostName': widget.hostName,
          'voteDates': voteDates
        };
        pushManager.sendPushMsg(
            userToken: userToken, title: title, body: body, details: details);
      });
    });

    // 임의로 3초 후 투표 화면으로 이동
    // 계산된 투표날짜 리스트 insert
    makeTheFirebaseCollection(voteDates);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VoteScreen(
              voteDates: voteDates,
              chatroomId: widget.chatroomId!,
              dalddongMembers: widget.dalddongMembers,
            )));
  }

  @override
  Widget build(BuildContext context) {
    final pushManager = PushManager();

    // Save the DalddongList (isAllConfirmed == false)
    // Main Dalddong List DB
    FirebaseFirestore.instance
        .collection('DalddongList')
        .doc(widget.chatroomId)
        .set({
      'DalddongDate': null,
      'hostName': widget.hostName,
      'LunchOrDinner':
      context.read<DalddongProvider>().DalddongLunch == true ? 0 : 1,
      'Color': "0xff025645",
      'DalddongId': widget.chatroomId,
      'Importance': context.read<DalddongProvider>().starRating,
      'CreateTime': DateTime.now(),
      'ExpiredTime': DateTime.now().add(const Duration(hours: 24)),
      'MemberNumbers': widget.dalddongMembers?.length,
      'isAllConfirmed': false
    });

    // add Members
    widget.dalddongMembers?.forEach((element) {
      FirebaseFirestore.instance
          .collection('DalddongList')
          .doc(widget.chatroomId)
          .collection('Members')
          .doc(element.get('userEmail'))
          .set({
        'userName': element.get('userName'),
        'userEmail': element.get('userEmail'),
        'userImage': element.get('userImage'),
        'currentStatus':
        element.get('userEmail') == FirebaseAuth.instance.currentUser?.email
            ? 2
            : 0,
      });

      // Save the dalddong Members
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatroomId)
          .collection('dalddong')
          .doc(widget.chatroomId)
          .collection('dalddongMembers')
          .doc(element.get('userEmail'))
          .set({
        "currentStatus": 0,
        "userName": element.get('userName'),
        "userImage": element.get('userImage'),
        "userEmail": element.get('userEmail')
      });

      // get BlockDatesList among members
      FirebaseFirestore.instance
          .collection('user')
          .doc(element.get('userEmail'))
          .collection('BlockDatesList') //.where('isDalddong', isEqualTo: true)
          .snapshots()
          .forEach((blockedCollection) {
        blockedCollection.docs.forEach((blocked) {
          blockedDates.add(DateTime.parse(blocked.id));
          // print("BlockDate : ${DateTime.parse(blocked.id)}");
        });
      });
    });

    blockedDates = blockedDates.toSet().toList();

    Timer(const Duration(seconds: 3), () {
      while (true) {
        DateTime today = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        DateTime candidateDate = today.add(Duration(days: addedDate));
        if (blockedDates.contains(candidateDate) == false) {
          voteDates.add(candidateDate);
        }

        if (voteDates.length >= 5) {
          finalStep(pushManager);
          break;
        } else {
          addedDate += 1;
        }
      }

    });

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
