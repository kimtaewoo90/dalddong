import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:timer_builder/timer_builder.dart';
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/providers/calendar_provider.dart';
import '../../main_screen.dart';

class ResponseStatus extends StatefulWidget {
  const ResponseStatus({Key? key, this.dalddongId}) : super(key: key);

  final String? dalddongId;
  @override
  State<ResponseStatus> createState() => _ResponseStatusState();
}

class _ResponseStatusState extends State<ResponseStatus> {
  int? diffHour;
  int? diffMin;

  @override
  Widget build(BuildContext context) {
    context.watch<DalddongProvider>().newDdFriends;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: GeneralUiConfig.backgroundColor,
        appBar: BaseAppBar(
          appBar: AppBar(),
          title: "수락대기중",
          backBtn: false,
          center: true,
        ),
        body: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('DalddongList')
                .doc(widget.dalddongId)
                .collection('Members')
                .get(),
            builder: (context, memberSnapshot) {
              if (memberSnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              }
              
              List<String> acceptList = [];
              List<String> rejectList = [];
              List<String> allList = [];
              List<UserResponse> responseMembers = [];

              memberSnapshot.data?.docs.forEach((document) {
                UserResponse userResponse = UserResponse(document);
                responseMembers.add(userResponse);
                allList.add(document.id);
                if (document.get('currentStatus') == 2) {          
                  acceptList.add(document.id);
                }
                if(document.get('currentStatus') == 3){
                  rejectList.add(document.id);
                }
              });
              String responseText = "${acceptList.length + rejectList.length} / ${allList.length}";
              double response = (acceptList.length + rejectList.length) / allList.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 좌측정렬 Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                        child: Center(
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('DalddongList')
                                .doc(widget.dalddongId)
                                .get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> dalddongSnapshot) {
                              if (dalddongSnapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              }

                              return Text(
                                "${dalddongSnapshot.data!['hostName']} 님께서 "
                                    "${dalddongSnapshot.data!['MemberNumbers']}명 에게"
                                    "보낸일정을 검토받고 있어요!\n "
                                    "모든 사람이 수락해주시면 \n "
                                    "채팅방이 만들어져요",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
                        child: Text(
                          "현재응답률",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width - 40,
                          animation: true,
                          lineHeight: 20.0,
                          animationDuration: 1000,
                          percent: response,
                          center: Text(responseText, style: const TextStyle(color: Colors.white38),),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: GeneralUiConfig.floatingBtnColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: SizedBox(
                          child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: responseMembers,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        color: Colors.white70,
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text(
                            "초대 만료까지",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // 우측정렬 Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('DalddongList')
                              .doc(widget.dalddongId)
                              .snapshots(),
                          builder: (context, snapshot3) {
                            if (snapshot3.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              );
                            }

                            Timestamp expiredTime =
                            snapshot3.data?.get("ExpiredTime");

                            return TimerBuilder.periodic(
                              const Duration(minutes: 1),
                              builder: (context) {
                                diffHour = (DateTime.fromMillisecondsSinceEpoch(
                                    expiredTime.seconds * 1000)
                                    .difference(DateTime.now())
                                    .inMinutes /
                                    60)
                                    .floor();
                                diffMin = (DateTime.fromMillisecondsSinceEpoch(
                                    expiredTime.seconds * 1000)
                                    .difference(DateTime.now())
                                    .inMinutes %
                                    60);

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
                                      "만료된 달똥초대장..입니다",
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
                    ],
                  ),

                  const Spacer(),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                    child: Center(
                      child: Text(
                        "수락대기중인 달똥은 [알림] 에서\n "
                            "언제든지 확인 할 수 있어요\n ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
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
                          MaterialStateProperty.all(GeneralUiConfig.btnColor),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                  // side: BorderSide(color: Colors.red)
                              )
                          )
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(),
                            ));
                      },
                      child: const Text("메인화면"),
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}

class UserResponse extends StatefulWidget {
  final QueryDocumentSnapshot eachUser;
  const UserResponse(this.eachUser, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<UserResponse> createState() => _UserResponse(eachUser);
}

class _UserResponse extends State<UserResponse> {
  final QueryDocumentSnapshot eachUser;
  _UserResponse(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // width: MediaQuery.of(context).size.width - 100,
      // margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.all(3.0),

      child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.black,
            backgroundImage: NetworkImage(
              eachUser['userImage'],
            ),
          ),
          title: Text(
            eachUser['userName'],
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing:
          eachUser['currentStatus'] == 0 || eachUser['currentStatus'] == 1
          // 대기
              ? SizedBox(
            height: 40,
            width: 50,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5)),
              child: const Center(
                  child: Text(
                    '대기',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )),
            ),
          )
              : eachUser['currentStatus'] == 2
          // 수락
              ? SizedBox(
            height: 40,
            width: 50,
            child: Container(
              decoration: BoxDecoration(
                  color: GeneralUiConfig.floatingBtnColor,
                  borderRadius: BorderRadius.circular(5)),
              child: const Center(
                  child: Text(
                    '수락',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )),
            ),
          )
          // 거절
              : SizedBox(
            height: 40,
            width: 50,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(5)),
              child: const Center(
                  child: Text(
                    '거절',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )),
            ),
          )),
    );
  }
}
