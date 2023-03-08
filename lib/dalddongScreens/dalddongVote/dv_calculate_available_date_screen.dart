import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/functions/utilities/utilities_dalddong.dart';
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
        required this.hostName})
      : super(key: key);
  final List<QueryDocumentSnapshot>? dalddongMembers;
  final String hostName;


  @override
  State<WaitCalculateDates> createState() => _WaitCalculateDatesState();
}

class _WaitCalculateDatesState extends State<WaitCalculateDates> {
  List<DateTime> blockedDates = [];
  List<DateTime> voteDates = [];
  int addedDate = 1;
  String dalddongId = "";
  final _pushManager = PushManager();


  @override
  void initState() {
    super.initState();
  }

  Future<void> asyncableFunction(List<DateTime> blockedDates) async {

    while (true) {
          DateTime today = DateTime(
              DateTime
                  .now()
                  .year, DateTime
              .now()
              .month, DateTime
              .now()
              .day);
          DateTime candidateDate = today.add(Duration(days: addedDate));
          if (blockedDates.contains(candidateDate) == false) {
            voteDates.add(candidateDate);
          }
          if(voteDates.length == 5){

            print("투표날짜 계산 완료");
            dalddongId = addDalddongVoteList(context, widget.dalddongMembers!, voteDates);
             voteDates.forEach((element) async{
              await FirebaseFirestore.instance
                  .collection('DalddongList')
                  .doc(dalddongId)
                  .collection('voteDates')
                  .doc(DateFormat('yyyy-MM-dd').format(element))
                  .set({
                'voted': 0,
                'votedMembers': FieldValue.arrayUnion([]),
              });
            });
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
                  'id': dalddongId,
                  'eventId': dalddongId,
                  'eventType': "DDV",
                  'membersNum': widget.dalddongMembers?.length,
                  'hostName': widget.hostName,

                };
                _pushManager.sendPushMsg(
                    userToken: userToken,
                    title: title,
                    body: body,
                    details: details);
                print("send To ${element.get('userName')}");
              });

            });
            break;
        }
        else {
            addedDate += 1;
          }
        }

        try{
        if(context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print(dalddongId);
            Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VoteScreen(
                              voteDates: voteDates,
                              dalddongId: dalddongId
                          )));
          });

        }
      } catch(e){
        print("Error: ${e.toString()}");
      }       
  }

  @override
  Widget build(BuildContext context) {


    // add Members
    widget.dalddongMembers?.forEach((element) async {

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

      blockedDates = blockedDates.toSet().toList();
      // Timer(const Duration(seconds: 1), () {
      await asyncableFunction(blockedDates); 
        
      



    return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/waiting.png'),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Expanded( flex:1,child: Text("달똥이 열심히 여러분의 \n 식사 일정을 잡고 있습니당!")),
            ],
          ),
        ));
  }
}
