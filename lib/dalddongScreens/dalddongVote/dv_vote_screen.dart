import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';

import '../../commonScreens/page_route_with_animation.dart';
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/utilities/utilities_dalddong.dart';
import '../dalddongRequest/dr_match_screen.dart';
import 'dv_vote_status_screen.dart';


class VoteScreen extends StatefulWidget {
  const VoteScreen({Key? key,
    required this.voteDates,
    required this.chatroomId,
    required this.dalddongMembers}) : super(key: key);

  final List<DateTime> voteDates;
  final String chatroomId;
  final List<QueryDocumentSnapshot>? dalddongMembers;

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {

  int? diffHour;
  int? diffMin;

  var votedMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
          appBar: AppBar(),
          title: "투표하기",
          backBtn: false,
          center: true,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatrooms')
              .doc(widget.chatroomId)
              .collection('dalddong')
              .doc(widget.chatroomId)
              .collection('hostInfo')
              .doc('hostInfo')
              .snapshots(),
          builder: (context, hostSnapshot){
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chatrooms')
                  .doc(widget.chatroomId)
                  .collection('dalddong')
                  .doc(widget.chatroomId)
                  .collection('dalddongMembers')
                  .snapshots(),
              builder: (context, memberSnapshot){
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(widget.chatroomId)
                        .collection('dalddong')
                        .doc(widget.chatroomId)
                        .collection('voteDates')
                        .snapshots(),
                    builder: (context, datesSnapshot){

                      List<VoteDatesCheckBoxList> datesList = [];
                      datesSnapshot.data?.docs.forEach((element) {
                        VoteDatesCheckBoxList dateBox = VoteDatesCheckBoxList(voteDatesList: element, chatroomId: widget.chatroomId,);
                        datesList.add(dateBox);
                      });

                      return Column(
                        children: [
                          const SizedBox(height: 30,),

                          Text("${hostSnapshot.data?.get('userName')} 님이 모으는 "
                              "${memberSnapshot.data?.docs[0].get('userName')}님 ${memberSnapshot.data?.docs[1].get('userName')}님 등 ${memberSnapshot.data?.docs.length}명과의 \n"
                              "${hostSnapshot.data?.get('lunchOrDinner') == true ? "점심" : "저녁"} 날짜들을 뽑아왔어요! \n"
                              "원하는 날짜를 골라주세요!"),

                          Flexible(
                            fit: FlexFit.tight,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: ListView(
                                children: datesList,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10,),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('chatrooms')
                                      .doc(widget.chatroomId)
                                      .collection('dalddong')
                                      .doc(widget.chatroomId)
                                      .collection('ExpiredTime')
                                      .doc('ExpiredTime')
                                      .snapshots(),
                                  builder: (context, expiredSnapshot){
                                    if(expiredSnapshot.connectionState == ConnectionState.waiting){
                                      return Container(
                                        alignment: Alignment.center,
                                        child: const CircularProgressIndicator(),
                                      );
                                    }

                                    Timestamp ExpiredTime =
                                    expiredSnapshot.data?.get("ExpiredTime");

                                    return TimerBuilder.periodic(
                                      const Duration(minutes: 1),
                                      builder: (context) {
                                        diffHour = (DateTime.fromMillisecondsSinceEpoch(
                                            ExpiredTime.seconds * 1000)
                                            .difference(DateTime.now())
                                            .inMinutes / 60).floor();

                                        diffMin = (DateTime.fromMillisecondsSinceEpoch(
                                            ExpiredTime.seconds * 1000)
                                            .difference(DateTime.now())
                                            .inMinutes % 60);


                                        if (diffHour! >= 0 && diffMin! > 0) {
                                          return Padding(
                                            padding:
                                            const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                            child: Text(
                                              "$diffHour 시간 $diffMin 분전",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          );
                                        }

                                        // TODO: 1.만료되고 2.달똥생성이 되지 않았을 경우, 초대되었던 사람의 DB 컬렉션 삭제.
                                        else {
                                          return const Padding(
                                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                                            child: Text(
                                              "만료된 투표..입니다",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  }),

                              const SizedBox(
                                height: 10,
                              ),

                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.all(const Color(0xff025645))),
                                  onPressed: () async {

                                    await FirebaseFirestore.instance
                                        .collection('chatrooms')
                                        .doc(widget.chatroomId)
                                        .collection('dalddong')
                                        .doc(widget.chatroomId)
                                        .collection('dalddongMembers')
                                        .doc(FirebaseAuth.instance.currentUser!.email)
                                        .update({'currentStatus' : 1});

                                    await FirebaseFirestore.instance
                                        .collection('chatrooms')
                                        .doc(widget.chatroomId)
                                        .collection('dalddong')
                                        .doc(widget.chatroomId)
                                        .collection('dalddongMembers')
                                        .snapshots().forEach((element) {
                                      element.docs.forEach((docs) {
                                        if (docs.get('currentStatus') == 1){
                                          votedMembers.add(docs.get('userEmail'));
                                        }
                                      });
                                      setState(() {});

                                      List voted = votedMembers.toSet().toList();

                                      if (voted.length >= element.docs.length){
                                        if (kDebugMode){
                                          print("모든 맴버 투표완료");
                                        }
                                        completeDalddongVote(context, widget.chatroomId, element.docs);

                                        PageRouteWithAnimation pageRoute =
                                        PageRouteWithAnimation(CompleteAccept(dalddongId: widget.chatroomId,));
                                        Navigator.push(context, pageRoute.slideRitghtToLeft());

                                      }
                                      else{
                                        if (kDebugMode) {
                                          print("개인 투표완료~~");
                                        }
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => VoteStatus(eventId: widget.chatroomId),
                                            ));
                                      }


                                    });
                                  },
                                  child: const Text("투표완료"),
                                ),
                              )
                            ],

                          )
                        ],
                      );
                    });
              },
            );
          },
        )
    );
  }
}


// 투표날짜 체크박스
class VoteDatesCheckBoxList extends StatefulWidget {

  final QueryDocumentSnapshot voteDatesList;
  final String? chatroomId;
  const VoteDatesCheckBoxList({Key? key,
    required this.voteDatesList,
    required this.chatroomId}) : super(key: key);

  @override
  State<VoteDatesCheckBoxList> createState() => _VoteDatesCheckBoxListState();
}

class _VoteDatesCheckBoxListState extends State<VoteDatesCheckBoxList> {

  bool selected = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10,),

        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,

          decoration: BoxDecoration(
            color: selected == true ? Colors.blue : Colors.grey,
            borderRadius : BorderRadius.circular(10),
          ),
          child: GestureDetector(
            onTap: (){
              FirebaseFirestore.instance
                  .collection('chatrooms')
                  .doc(widget.chatroomId)
                  .collection('dalddong')
                  .doc(widget.chatroomId)
                  .collection('voteDates')
                  .doc(widget.voteDatesList.id)
                  .get().then((value) {

                if(List.from(value.get('votedMembers')).contains(FirebaseAuth.instance.currentUser?.email)){
                  FirebaseFirestore.instance
                      .collection('chatrooms')
                      .doc(widget.chatroomId)
                      .collection('dalddong')
                      .doc(widget.chatroomId)
                      .collection('voteDates')
                      .doc(widget.voteDatesList.id)
                      .update({"votedMembers" : FieldValue.arrayRemove([FirebaseAuth.instance.currentUser?.email])});
                  selected = false;
                }

                else{
                  try{
                    FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(widget.chatroomId)
                        .collection('dalddong')
                        .doc(widget.chatroomId)
                        .collection('voteDates')
                        .doc(widget.voteDatesList.id)
                        .update({"votedMembers" : FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.email])});
                  } catch (e){
                    FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(widget.chatroomId)
                        .collection('dalddong')
                        .doc(widget.chatroomId)
                        .collection('voteDates')
                        .doc(widget.voteDatesList.id)
                        .update({"votedMembers" : FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.email])});
                  }

                  selected = true;
                }

                // update 'voted' number
                FirebaseFirestore.instance
                    .collection('chatrooms')
                    .doc(widget.chatroomId)
                    .collection('dalddong')
                    .doc(widget.chatroomId)
                    .collection('voteDates')
                    .doc(widget.voteDatesList.id).get().then((value) {
                  var votedNumber = List.from(value.get('votedMembers')).length;
                  FirebaseFirestore.instance
                      .collection('chatrooms')
                      .doc(widget.chatroomId)
                      .collection('dalddong')
                      .doc(widget.chatroomId)
                      .collection('voteDates')
                      .doc(widget.voteDatesList.id)
                      .update({'voted' : votedNumber});
                });

                setState(() {});
              });

              // widget.voteDatesList.

            },

            child: ListTile(
              // tileColor :
              leading: Icon(
                  selected == true
                      ? Icons.check_circle
                      : Icons.circle_outlined),
              title: Text(
                widget.voteDatesList.id,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),

            ),
          ),
        ),
      ],
    );
  }
}

