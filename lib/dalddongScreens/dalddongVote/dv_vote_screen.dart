import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:timer_builder/timer_builder.dart';

import '../../commonScreens/page_route_with_animation.dart';
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/utilities/utilities_dalddong.dart';
import '../../main_screen.dart';
import '../dalddongRequest/dr_match_screen.dart';
import 'dv_vote_status_screen.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({
    Key? key,
    required this.voteDates,
    required this.dalddongId,
    required this.dalddongMembers,
  }) : super(key: key);

  final List<DateTime> voteDates;
  final String dalddongId;
  final List<QueryDocumentSnapshot>? dalddongMembers;

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  bool isExpiredAlarm = false;
  bool isMatched = false;

  // Timestamp? expiredTime;
  Timer? _timer;
  late Duration _remainingDuration = const Duration(hours: 1);

  Future<Timestamp?> _getExpiredTime() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference documentReference =
        firestore.collection('DalddongList').doc(widget.dalddongId);

    return await documentReference
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      return documentSnapshot.get('ExpiredTime');
    });
  }

  // 여기서 Timer.periodic 으로 계산한다?
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: GeneralUiConfig.backgroundColor,
        appBar: BaseAppBar(
          appBar: AppBar(),
          title: "투표하기",
          backBtn: false,
          center: true,
        ),
        body: FutureBuilder(
          future: _getExpiredTime(),
          builder: (context, expiredSnapshot) {

            if(expiredSnapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }
            else if (!expiredSnapshot.hasData){
              return const Center(child: Text("Has no expired date "),);
            }

            _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
              _remainingDuration = DateTime.fromMillisecondsSinceEpoch(expiredSnapshot.data!.seconds * 1000)
                  .difference(DateTime.now());
            });


            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('DalddongList')
                  .doc(widget.dalddongId)
                  .get(),
              builder: (context, dalddongSnapshot) {
                if (!dalddongSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // var expiredTime = dalddongSnapshot.data?.get("ExpiredTime");
                isMatched = dalddongSnapshot.data?.get('isAllConfirmed');
                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('DalddongList')
                      .doc(widget.dalddongId)
                      .collection('Members')
                      .get(),
                  builder: (context, memberSnapshot) {
                    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('DalddongList')
                            .doc(widget.dalddongId)
                            .collection('voteDates')
                            .snapshots(),
                        builder: (context, datesSnapshot) {
                          List<VoteDatesCheckBoxList> datesList = [];
                          datesSnapshot.data?.docs.forEach((element) {
                            VoteDatesCheckBoxList dateBox = VoteDatesCheckBoxList(
                              voteDatesList: element,
                              membersNumber : memberSnapshot.data?.docs.length,
                              dalddongId: widget.dalddongId,
                            );
                            datesList.add(dateBox);
                          });

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                  text: "${dalddongSnapshot.data?.get('hostName')}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff025645)),
                                ),
                                const TextSpan(text: " 님이 "),
                                TextSpan(
                                  text: "${memberSnapshot.data?.docs.length} 명",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff025645)),
                                ),
                                const TextSpan(text: " 에게 \n "),
                                TextSpan(
                                  text:
                                      "${dalddongSnapshot.data?.get('LunchOrDinner') == true ? "점심" : "저녁"} ",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff025645)),
                                ),
                                const TextSpan(
                                    text: "날짜 투표를 요청했습니다! \n 원하는 날짜를 골라주세요!")
                              ])),
                              Flexible(
                                fit: FlexFit.tight,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  child: ListView(
                                    children: datesList,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TimerBuilder.periodic(
                                      const Duration(seconds: 1),
                                      builder: (context) {
                                        if (_remainingDuration.inSeconds <= 0) {
                                          return const Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 20, 0),
                                            child: Text(
                                              "만료된 투표..입니다",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 20, 0),
                                            child: Text(
                                              "${_remainingDuration.inHours % 24} 시간 ${_remainingDuration.inMinutes} 분전",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    GeneralUiConfig
                                                        .floatingBtnColor)),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('DalddongList')
                                              .doc(widget.dalddongId)
                                              .collection('Members')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.email)
                                              .update({'currentStatus': 1});

                                          if (context.mounted) {
                                            var votedMember =
                                                await FirebaseFirestore.instance
                                                    .collection('DalddongList')
                                                    .doc(widget.dalddongId)
                                                    .collection('Members')
                                                    .where('currentStatus',
                                                        isEqualTo: 1)
                                                    .get()
                                                    .then((value) {
                                              return value.docs;
                                            });

                                            var totalMembers =
                                                await FirebaseFirestore.instance
                                                    .collection('DalddongList')
                                                    .doc(widget.dalddongId)
                                                    .collection('Members')
                                                    .get()
                                                    .then((value) {
                                              return value.docs;
                                            });

                                            if (context.mounted) {
                                              if (votedMember.length ==
                                                  totalMembers.length) {
                                                await completeDalddongVote(context,
                                                    widget.dalddongId, votedMember);

                                                if (context.mounted) {
                                                  PageRouteWithAnimation pageRoute =
                                                      PageRouteWithAnimation(
                                                          CompleteAccept(
                                                    dalddongId: widget.dalddongId,
                                                  ));
                                                  Navigator.push(
                                                      context,
                                                      pageRoute
                                                          .slideRitghtToLeft());
                                                }
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const MainScreen(),
                                                    ));
                                              }
                                            }
                                          }
                                        },
                                        child: const Text(
                                          "투표완료",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          );
                        });
                  },
                );
              },
            );
          }
        ),
      ),
    );
  }
}

// 투표날짜 체크박스
class VoteDatesCheckBoxList extends StatefulWidget {
  final QueryDocumentSnapshot voteDatesList;
  final int? membersNumber;
  final String? dalddongId;

  const VoteDatesCheckBoxList(
      {Key? key, required this.voteDatesList, required this.membersNumber, required this.dalddongId})
      : super(key: key);

  @override
  State<VoteDatesCheckBoxList> createState() => _VoteDatesCheckBoxListState();
}

class _VoteDatesCheckBoxListState extends State<VoteDatesCheckBoxList> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {

    var votedRate =
        List.from(widget.voteDatesList.get('votedMembers')).length / widget.membersNumber!;

    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 80,
          decoration: BoxDecoration(
            color: selected == true ? Colors.blue : GeneralUiConfig.backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: GestureDetector(
            onTap: () {
              print(widget.voteDatesList.id);
              FirebaseFirestore.instance
                  .collection('DalddongList')
                  .doc(widget.dalddongId)
                  .collection('voteDates')
                  .doc(widget.voteDatesList.id)
                  .get()
                  .then((value) {
                if (List.from(value.get('votedMembers'))
                    .contains(FirebaseAuth.instance.currentUser?.email)) {
                  FirebaseFirestore.instance
                      .collection('DalddongList')
                      .doc(widget.dalddongId)
                      .collection('voteDates')
                      .doc(widget.voteDatesList.id)
                      .update({
                    "votedMembers": FieldValue.arrayRemove(
                        [FirebaseAuth.instance.currentUser?.email])
                  });
                  selected = false;
                } else {
                  try {
                    FirebaseFirestore.instance
                        .collection('DalddongList')
                        .doc(widget.dalddongId)
                        .collection('voteDates')
                        .doc(widget.voteDatesList.id)
                        .update({
                      "votedMembers": FieldValue.arrayUnion(
                          [FirebaseAuth.instance.currentUser?.email])
                    });
                  } catch (e) {
                    FirebaseFirestore.instance
                        .collection('DalddongList')
                        .doc(widget.dalddongId)
                        .collection('voteDates')
                        .doc(widget.voteDatesList.id)
                        .update({
                      "votedMembers": FieldValue.arrayUnion(
                          [FirebaseAuth.instance.currentUser?.email])
                    });
                  }

                  selected = true;
                }

                // update 'voted' number
                FirebaseFirestore.instance
                    .collection('DalddongList')
                    .doc(widget.dalddongId)
                    .collection('voteDates')
                    .doc(widget.voteDatesList.id)
                    .get()
                    .then((value) {
                  var votedNumber = List.from(value.get('votedMembers')).length;
                  FirebaseFirestore.instance
                      .collection('DalddongList')
                      .doc(widget.dalddongId)
                      .collection('voteDates')
                      .doc(widget.voteDatesList.id)
                      .update({'voted': votedNumber});
                });

                setState(() {});
              });

              // widget.voteDatesList.
            },
            child: Column(
              children: [
                ListTile(
                  // tileColor :
                  leading: Icon(selected == true
                      ? Icons.check_circle
                      : Icons.circle_outlined),
                  title: Text(
                    widget.voteDatesList.id,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Row(
                  children: [
                    LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width * 0.7,
                      animation: true,
                      lineHeight: 20.0,
                      animationDuration: 1000,
                      percent: votedRate,
                      // center: Text("${(votedRate * 100)} %"),
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      progressColor: GeneralUiConfig.floatingBtnColor,
                    ),
                    Text('${widget.voteDatesList.get('votedMembers').length} 명')
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
