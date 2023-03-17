import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:dalddong/commonScreens/page_route_with_animation.dart';
import 'package:dalddong/commonScreens/shared_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../dalddongScreens/dalddongRequest/dr_match_screen.dart';
import '../dalddongScreens/dalddongRequest/dr_not_match_screen.dart';
import '../dalddongScreens/dalddongRequest/dr_response_screen.dart';
import '../dalddongScreens/dalddongRequest/dr_response_status_screen.dart';
import '../dalddongScreens/dalddongVote/dv_vote_screen.dart';
import '../dalddongScreens/dalddongVote/dv_vote_status_screen.dart';


class AlarmScreen extends StatefulWidget {
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool isDalddongAlarm = false;
  int alarmType = 0;
  List<String> dalddongRqType = ["EDD", "WDD", "DD", "CDD"];
  List<String> dalddongVtType = ["EDDV", "WDDV", "DDV", "CDDV"];

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

              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .collection('AlarmList')
                      .orderBy('alarmTime', descending: true)
                      .snapshots(),
                  builder: (context, alarmSnapshot){
                    if (alarmSnapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    }
                    List<DalddongAlarm> alarmList = [];

                    if(alarmType == 0) {
                      alarmSnapshot.data?.docs.forEach((document) {
                        if (dalddongRqType.contains(document.get('details')['eventType']) ||
                            dalddongVtType.contains(document.get('details')['eventType'])
                        ) {
                          DalddongAlarm myAlarmList = DalddongAlarm(eachEvents: document,);
                          alarmList.add(myAlarmList);
                        }
                      });
                    }

                    else if(alarmType == 1){
                      alarmSnapshot.data?.docs.forEach((document) {
                        // 투표 알람
                        if (dalddongVtType.contains(document.get('details')['eventType'])) {
                          DalddongAlarm myVoteList =DalddongAlarm(eachEvents: document);
                          alarmList.add(myVoteList);
                        }
                      });
                    }

                    else{
                      alarmSnapshot.data?.docs.forEach((document) {
                        if (dalddongRqType.contains(document.get('details')['eventType'])) {
                          DalddongAlarm myAlarmList = DalddongAlarm(eachEvents: document,);
                          alarmList.add(myAlarmList);
                        }
                      });
                    }

                    if(alarmList.isEmpty){
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipPath(
                                clipper: SemiCircleClipper(),
                                child: Container(
                                  height: context.height() * 0.5,
                                  decoration: const BoxDecoration(color: Color(0xFFFFC655)),
                                ),
                              ),
                              10.height,
                              Text("${alarmType==1 ? '달똥투표가' : alarmType == 2 ? '달똥요청이' : '알람이'} 없습니다!", style: boldTextStyle(size: 20)),
                              16.height,
                              Text(
                                '현재 진행중인 ${alarmType==1 ? '달똥투표가' : alarmType == 2 ? '달똥요청이' : '알람이'} 없네요!\n 달똥을 시작해보세요!',
                                style: secondaryTextStyle(size: 15),
                                textAlign: TextAlign.center,
                              ).paddingSymmetric(vertical: 8, horizontal: 60),
                            ],
                          ),
                          Image.asset('images/bell.png', height: 180),
                        ],
                      );
                    }

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


class DalddongAlarm extends StatefulWidget {
  final QueryDocumentSnapshot eachEvents;
  const DalddongAlarm({Key? key, required this.eachEvents}) : super(key: key);

  @override
  State<DalddongAlarm> createState() => _DalddongAlarmState();
}

class _DalddongAlarmState extends State<DalddongAlarm> {

  bool isMatched = false;
  bool isRejected = false;
  List<String> dalddongRqType = ["EDD", "WDD", "DD", "CDD"];
  List<String> dalddongVtType = ["EDDV", "WDDV", "DDV", "CDDV"];

  @override
  Widget build(BuildContext context) {
    
    var eventType = widget.eachEvents.get('details')['eventType'];


    // 달똥요청 알람
    if(dalddongRqType.contains(eventType)){
      return dalddongRqAalarm(widget.eachEvents);
    }

    // 달똥투표 알람
    else if(dalddongVtType.contains(eventType)){
      return dalddongVtAlarm(widget.eachEvents);
    }
    else{
      return const Text("없음");
    }
  }
}


Widget dalddongRqAalarm(QueryDocumentSnapshot eachEvents){

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

      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('DalddongList')
              .doc(eachEvents.get('details')['eventId'])
              .collection('Members')
              .doc(FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
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
                          Row(
                            children: const [
                              Icon(Icons.calendar_month_outlined),
                              SizedBox(width: 10,),
                              Text("달똥요청", style: TextStyle(fontSize: GeneralUiConfig.hintSize, color: Colors.grey),),
                            ],
                          ),

                          ListTile(
                              // leading: Image.asset('images/dalddongRequest.png'),

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

Widget dalddongVtAlarm(QueryDocumentSnapshot eachVotes){

  bool isMatched = false;

  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('DalddongList')
        .doc(eachVotes.get('details')['eventId'])
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


      Timestamp alarmTime = eachVotes['alarmTime'];
      return Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
              color: Colors.white54,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.how_to_vote),
                        SizedBox(width: 10,),
                        Text("달똥투표", style: TextStyle(fontSize: GeneralUiConfig.hintSize, color: Colors.grey),),
                      ],
                    ),

                    ListTile(
                        // leading: Column(
                        //   children: const [
                        //     Icon(Icons.how_to_vote),
                        //   ],
                        // ),
                        title: Text(
                          "${eachVotes.get('details')['hostName']}님 외 ${eachVotes.get('details')['membersNum']}명의 ${eachVotes['body']}",
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
                          onPressed: () async {
                            var acceptMembers = [];
                            FirebaseFirestore.instance
                                .collection('DalddongList')
                                .doc(eachVotes.get('details')['eventId'])
                                .collection('Members')
                                .snapshots()
                                .forEach((element) async {
                              for (var docs in element.docs) {
                                if (docs.get('currentStatus') == 1) {
                                  acceptMembers.add(docs.id);
                                }
                              }

                              // 투표하러 가기
                              var voteDates = await FirebaseFirestore.instance.collection('DalddongList').doc(eachVotes.get('details')['eventId']).get().then((value) => value.get('voteDates'));
                              if(context.mounted) {
                                PageRouteWithAnimation pageRoute = PageRouteWithAnimation(
                                    VoteScreen(
                                      voteDates: List.from(voteDates),
                                      dalddongId: eachVotes.get('details')['eventId'],
                                    ));

                                Navigator.push(
                                    context, pageRoute.slideRitghtToLeft());
                              }

                            });
                          },
                          child: const Text('투표하기'),
                        )
                            : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: GeneralUiConfig.floatingBtnColor,
                          ),
                          onPressed: () async  {
                            List<String> acceptMembers = [];
                            int totalMembers = 0;
                            acceptMembers = await FirebaseFirestore.instance
                                .collection('DalddongList')
                                .doc(eachVotes.get('details')['eventId'])
                                .collection('Members')
                                .get().then((value) {
                              value.docs.forEach((element) {
                                if (element.get('currentStatus') == 1) {
                                  acceptMembers.add(element.id);
                                }
                              });
                              totalMembers = value.docs.length;
                              return acceptMembers;
                            });

                            if(context.mounted) {
                              if (acceptMembers.length == totalMembers) {
                                isMatched = true;
                                PageRouteWithAnimation pageRoute =
                                PageRouteWithAnimation(CompleteAccept(
                                    dalddongId: eachVotes.get('details')['eventId']));
                                Navigator.push(context, pageRoute.slideRitghtToLeft());
                              } else {
                                isMatched = false;
                                PageRouteWithAnimation pageRoute =
                                PageRouteWithAnimation(VoteStatus(
                                  dalddongId: eachVotes.get('details')['eventId'],));
                                Navigator.push(context, pageRoute.slideRitghtToLeft());
                              }
                            }

                          },
                          child: isMatched ? const Text("매칭완료"):  const Text('투표현황'),
                        )),
                    Padding(
                        padding:const EdgeInsets.all(8.0),
                        child: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            alarmTime.seconds * 1000))),),
                    const Divider(),
                  ])));
    },
  );
}


class SemiCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 60;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
