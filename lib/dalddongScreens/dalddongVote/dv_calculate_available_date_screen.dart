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

  @override
  Widget build(BuildContext context)  {


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
