import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:dalddong/commonScreens/page_route_with_animation.dart';
import 'package:dalddong/commonScreens/shared_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../dalddongScreens/dalddongRequest/dr_match_screen.dart';
import '../dalddongScreens/dalddongRequest/dr_not_match_screen.dart';
import '../dalddongScreens/dalddongRequest/dr_response_screen.dart';
import '../dalddongScreens/dalddongRequest/dr_response_status_screen.dart';
import '../dalddongScreens/dalddongVote/dv_vote_screen.dart';


class AlarmScreen extends StatefulWidget {
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool isDalddongAlarm = false;
  int alarmType = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeneralUiConfig.backgroundColor,
      appBar: BaseAppBar(
        appBar: AppBar(),
        title: "알람",
        backBtn: true,
        center: true,
        hasIcon: false,
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    onPressed: () {
                      setState(() {
                        alarmType = 0;
                      });

                    },
                    child: const Text('전체읽기'),
                  ),
                  const Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: alarmType == 1 ? Colors.black : Colors.grey),
                    onPressed: () {
                      setState(() {
                        alarmType = 1;
                      });
                    },
                    child: const Text('달똥투표'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text("|"),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: alarmType == 2 ? Colors.black : Colors.grey),
                    onPressed: () {
                      setState(() {
                        alarmType = 2;
                      });
                    },
                    child: const Text('달똥알림'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text("|"),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: alarmType == 0 ? Colors.black : Colors.grey),
                    onPressed: () {
                      setState(() {
                        alarmType = 0;
                      });
                    },
                    child: const Text('전체알림'),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              if (alarmType == 0)
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('AlarmList')
                        .orderBy('alarmTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      }
                      List<MyDalddongAlarm> alarmList = [];

                      // TODO: DalddongAlarmList 알람 시간순으로 정렬
                      snapshot.data?.docs.forEach((document) {
                        if (document.get('details')['eventType'] == "DD" || // 정해진날짜 달똥
                            document.get('details')['eventType'] == "CDD" // 달똥매칭 성공
                        ) {
                          MyDalddongAlarm myAlarmList =
                          MyDalddongAlarm(document);
                          alarmList.add(myAlarmList);
                        }
                      });

                      List<DalddongVoteAlarm> voteList = [];

                      snapshot.data?.docs.forEach((document) {
                        // 투표 알람
                        if (document.get('details')['eventType'] == "DDV") {
                          DalddongVoteAlarm myVoteList = DalddongVoteAlarm(eachVotes: document);
                          voteList.add(myVoteList);
                        }
                      });

                      return Flexible(
                        fit: FlexFit.tight,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: ListView(
                            // shrinkWrap: true,
                            children: alarmList,
                          ),
                        ),
                      );
                    }),
              // 투표알람
              if (alarmType == 1)
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('AlarmList')
                        .orderBy('alarmTime', descending: true)
                        .snapshots(),
                    builder: (context, voteSnapshot) {
                      if (voteSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      }

                      List<DalddongVoteAlarm> voteList = [];

                      voteSnapshot.data?.docs.forEach((document) {
                        // 투표 알람
                        if (document.get('details')['eventType'] == "DDV" ||
                            document.get('details')['eventType'] == "CDDV") {
                          DalddongVoteAlarm myVoteList = DalddongVoteAlarm(eachVotes: document);
                          voteList.add(myVoteList);
                        }
                      });
                      return Flexible(
                        fit: FlexFit.tight,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: ListView(
                            shrinkWrap: true,
                            children: voteList,
                          ),
                        ),
                      );
                    }),

              // 달똥알람
              if (alarmType == 2)
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('AlarmList')
                        .orderBy('alarmTime', descending: true)
                        .snapshots(),
                    builder: (context, dalddongSnapshot) {
                      if (dalddongSnapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      }
                      List<MyDalddongAlarm> alarmList = [];

                      // TODO: DalddongAlarmList 알람 시간순으로 정렬
                      dalddongSnapshot.data?.docs.forEach((document) {
                        if (document.get('details')['eventType'] == "DD" || // 정해진날짜 달똥
                            document.get('details')['eventType'] == "CDD" // 달똥매칭 성공
                        ) {
                          MyDalddongAlarm myAlarmList =
                          MyDalddongAlarm(document);
                          alarmList.add(myAlarmList);
                        }
                      });

                      return Flexible(
                        fit: FlexFit.tight,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: ListView(
                            // shrinkWrap: true,
                            children: alarmList,
                          ),
                        ),
                      );
                    }),
            ],
          ),
        ),
      ]),
    );
  }
}

// 달똥투표알람 class
class DalddongVoteAlarm extends StatefulWidget {
  final QueryDocumentSnapshot eachVotes;

  const DalddongVoteAlarm({Key? key, required this.eachVotes})
      : super(key: key);

  @override
  State<DalddongVoteAlarm> createState() => _DalddongVoteAlarmState();
}

class _DalddongVoteAlarmState extends State<DalddongVoteAlarm> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('DalddongList')
          .doc(widget.eachVotes.get('details')['eventId'])
          .collection('Members')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .snapshots(),
      builder: (context, voteMySnapshot) {
        if (voteMySnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }

        Timestamp alarmTime = widget.eachVotes['alarmTime'];
        return Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
                color: Colors.white54,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              alarmTime.seconds * 1000))),
                      ListTile(
                          leading: const Icon(Icons.calendar_month),
                          title: Text(
                            "${widget.eachVotes.get('details')['hostName']}님 외 ${widget.eachVotes.get('details')['membersNum']}명의 ${widget.eachVotes['body']}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: GeneralUiConfig.alarmTitleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: voteMySnapshot.data?.get('currentStatus') == 0
                              ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                            ),
                            onPressed: () {
                              var acceptMembers = [];
                              FirebaseFirestore.instance
                                  .collection('DalddongList')
                                  .doc(widget.eachVotes.get('details')['eventId'])
                                  .collection('Members')
                                  .snapshots()
                                  .forEach((element) {
                                for (var docs in element.docs) {
                                  if (docs.get('currentStatus') == 1) {
                                    acceptMembers.add(docs.id);
                                  }
                                }

                                // 모든 참가자 투표 완료
                                if (acceptMembers.length == element.docs.length) {
                                  if (kDebugMode) {
                                    print("${acceptMembers.length} / ${element.docs.length}");
                                  }

                                  // TODO : matched vote date
                                  // PageRouteWithAnimation pageRoute =
                                  // PageRouteWithAnimation(CompleteVoteDate(eventId : widget.eachVotes.get('details')['eventId']));
                                  // Navigator.push(context, pageRoute.slideRitghtToLeft());
                                }

                                // 투표하러 가기
                                else {
                                  if (kDebugMode) {
                                    print("${acceptMembers.length} / ${element.docs.length}");
                                  }
                                  PageRouteWithAnimation pageRoute =
                                  PageRouteWithAnimation(
                                      VoteScreen(
                                        voteDates: widget.eachVotes.get('details')['voteDates'],
                                        dalddongId: widget.eachVotes.get('details')['eventId'],
                                      ));
                                  Navigator.push(context, pageRoute.slideRitghtToLeft());
                                }
                              });
                            },
                            child: const Text('투표하기'),
                          )
                              : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              var acceptMembers = [];
                              FirebaseFirestore.instance
                                  .collection('DalddongList')
                                      .doc(widget.eachVotes.get('details')['eventId'])
                                      .collection('Members')
                                      .snapshots()
                                  .forEach((element) {
                                for (var docs in element.docs) {
                                  if (docs.get('currentStatus') == 1) {
                                    acceptMembers.add(docs.id);
                                  }
                                }

                                if (acceptMembers.length == element.docs.length) {
                                  if (kDebugMode) {
                                    print("${acceptMembers.length} / ${element.docs.length}");
                                  }
                                  if (kDebugMode) {
                                    print(widget.eachVotes.get('details')['eventId']);
                                  }

                                  // PageRouteWithAnimation pageRoute =
                                  // PageRouteWithAnimation(CompleteAccept(dalddongId : eachEvents.get('details')['eventId']));
                                  // Navigator.push(context, pageRoute.slideRitghtToLeft());
                                } else {
                                  if (kDebugMode) {
                                    print("${acceptMembers.length} / ${element.docs.length}");
                                  }
                                  // PageRouteWithAnimation pageRoute =
                                  // PageRouteWithAnimation(AcceptOrReject(DalddongId: eachEvents.get('details')['eventId'],));
                                  // Navigator.push(context, pageRoute.slideRitghtToLeft());
                                }
                              });
                            },
                            child: const Text('투표현황보기'),
                          )),
                      const Divider(),
                    ])));
      },
    );
  }
}

// 달똥알람 class
class MyDalddongAlarm extends StatefulWidget {
  final QueryDocumentSnapshot eachEvents;

  const MyDalddongAlarm(this.eachEvents, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<MyDalddongAlarm> createState() => _MyDalddongAlarm(eachEvents);
}

class _MyDalddongAlarm extends State<MyDalddongAlarm> {
  final QueryDocumentSnapshot eachEvents;

  _MyDalddongAlarm(this.eachEvents);

  @override
  Widget build(BuildContext context) {

    bool isMatched = false;
    bool isRejected = false;

    int myStatus = 0;
    List<String> acceptMembers = [];

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('DalddongList')
          .doc(eachEvents.get('details')['eventId'])
          .collection('Members')
          .snapshots(),
      builder: (context, memberSnapshot){
        if(memberSnapshot.connectionState == ConnectionState.waiting){
          return Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }

        for (var docs in memberSnapshot.data!.docs) {
          if (docs.get('currentStatus') ==2) {
            acceptMembers.add(docs.id);
          }
          if (docs.get('currentStatus') == 3){
            isMatched = false;
            isRejected = true;
          }
        }

        if(memberSnapshot.data?.docs.length == acceptMembers.length){
          isMatched = true;
        }

        return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('DalddongList')
                .doc(eachEvents.get('details')['eventId'])
                .collection('Members')
                .doc(FirebaseAuth.instance.currentUser!.email)
                .get(),
            builder: (context, snapshotAlarm) {
              if (snapshotAlarm.connectionState == ConnectionState.waiting) {
                return Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              }


              Timestamp alarmTime = eachEvents['alarmTime'];

              myStatus = snapshotAlarm.data?.get('currentStatus');
              return Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                      color: Colors.white54,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            ListTile(
                                leading: Image.asset('images/dalddongRequest.png'),

                                title: Text(
                                  "${eachEvents.get('details')['hostName']}님 외 ${eachEvents.get('details')['membersNum']}명의 ${eachEvents['body']}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: GeneralUiConfig.alarmTitleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: myStatus == 0
                                    ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.grey,
                                  ),
                                  onPressed: () {

                                    if(isRejected){
                                      PageRouteWithAnimation pageRoute =
                                      PageRouteWithAnimation(const RejectedDalddong());
                                      Navigator.push(context, pageRoute.slideRitghtToLeft());
                                    }
                                    else{
                                      PageRouteWithAnimation pageRoute =
                                      PageRouteWithAnimation(ResponseDR(DalddongId: eachEvents.get('details')['eventId'],));
                                      Navigator.push(context, pageRoute.slideRitghtToLeft());
                                    }

                                  },
                                  child: isRejected ? const Text("거절됨") : const Text('보기'),
                                )
                                    : myStatus == 2
                                    ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: isRejected ? Colors.red : isMatched ? Colors.green : Colors.yellowAccent,
                                  ),
                                  onPressed: () async {

                                      if (isMatched) {
                                        PageRouteWithAnimation pageRoute =
                                        PageRouteWithAnimation(
                                            CompleteAccept(
                                                dalddongId:eachEvents.get('details')['eventId']));
                                        Navigator.push(context,pageRoute.slideRitghtToLeft());
                                      } else {
                                        if(isRejected){
                                          PageRouteWithAnimation pageRoute =
                                          PageRouteWithAnimation(const RejectedDalddong());
                                          Navigator.push(context, pageRoute.slideRitghtToLeft());
                                        }
                                        else{
                                          PageRouteWithAnimation pageRoute =
                                          PageRouteWithAnimation(
                                              ResponseStatus(dalddongId: eachEvents.get('details')['eventId'],
                                              ));
                                          Navigator.push(
                                              context,pageRoute.slideRitghtToLeft());
                                        }
                                      }
                                  },
                                  child: isMatched ? const Text('매칭완료') : isRejected ? const Text("거절됨") : const Text("수락완료", style: TextStyle(color: Colors.black),),
                                )
                                    : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    PageRouteWithAnimation pageRoute =
                                    PageRouteWithAnimation(const RejectedDalddong());
                                    Navigator.push(context,
                                        pageRoute.slideRitghtToLeft());
                                  },
                                  child: const Text('거절함'),
                                )
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      alarmTime.seconds * 1000))),
                            ),
                            const Divider(),
                          ])));
            });
      },
    );
  }
}
