import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../commonScreens/page_route_with_animation.dart';
import '../../functions/utilities/utilities_chat.dart';
import '../../functions/utilities/utilities_dalddong.dart';
import '../../main_screen.dart';


class ResponseDV extends StatefulWidget {
  final String? dalddongId;

  const ResponseDV({Key? key, required this.dalddongId}) : super(key: key);

  @override
  State<ResponseDV> createState() => _ResponseDVState();
}

class _ResponseDVState extends State<ResponseDV> {

  List<QueryDocumentSnapshot> acceptMembers = [];
  String? chatRoomName;
  late Timestamp dalddongDate;
  late int lunchOrDinner;

  @override
  Widget build(BuildContext context) {
    // FirebaseFirestore.instance
    //     .collection('DalddongList')
    //     .doc(widget.DalddongId)
    //     .collection('Members')
    //     .doc(FirebaseAuth.instance.currentUser?.email)
    //     .update({'currentStatus' : 1});

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: GeneralUiConfig.backgroundColor,
        body: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('DalddongList')
                .doc(widget.dalddongId).get(),
            builder: (context, snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) {
                return Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              }

              lunchOrDinner = snapshots.data?.get('LunchOrDinner');

              return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Expanded(
                      flex: 2,
                      child: Image.asset('images/dalddongResponse.png')
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('DalddongList')
                              .doc(widget.dalddongId)
                              .collection('Members')
                              .get(),
                          builder: (context, memberSnapshot) {
                            if (memberSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              );
                            }

                            List<UserResponse> responseMembers = [];
                            memberSnapshot.data?.docs.forEach((document) {
                              UserResponse userResponse = UserResponse(document);
                              responseMembers.add(userResponse);
                            });

                            return Column(
                              children: [
                                Text(
                                  "$chatRoomName",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: ListView(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: responseMembers,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Expanded(
                      child: Text(
                        '${lunchOrDinner == 0 ? "점심" : "저녁"}달똥!\n\n 어떠신가요?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ]);
            }),

        bottomNavigationBar: Row(
          children: [
            Material(
              color: Colors.grey,
              child: InkWell(
                onTap: () async{

                  // 거절 시, DalddongList Members 에서 삭제.
                  await FirebaseFirestore.instance
                      .collection('DalddongList')
                      .doc(widget.dalddongId)
                      .collection('Members')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .delete();

                  // 거절 시, 개인테이블의 DalddongInProcess 에서 삭제
                  await FirebaseFirestore.instance
                      .collection('user')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .collection('DalddongInProcess')
                      .doc(widget.dalddongId).delete();


                  if(context.mounted) {
                    PageRouteWithAnimation pageRoute =
                      PageRouteWithAnimation(const MainScreen());
                    Navigator.push(context, pageRoute.slideRitghtToLeft());
                  }
                },
                child: const SizedBox(
                  height: kToolbarHeight,
                  width: 100,
                  child: Center(
                    child: Text(
                      '거절하기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                child: Material(
              color: Colors.black,
              child: InkWell(
                onTap: () async {
                  // Change the isConfirmed = true
                  await FirebaseFirestore.instance
                      .collection('DalddongList')
                      .doc(widget.dalddongId)
                      .collection('Members')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .update({'currentStatus': 2});

                  await FirebaseFirestore.instance
                      .collection('DalddongList')
                      .doc(widget.dalddongId)
                      .collection('Members')
                      .snapshots()
                      .forEach((element) {
                    element.docs.forEach((docs) {
                      if (docs.get('currentStatus') == 2) {
                        acceptMembers.add(docs);
                      }
                    });

                    // setState(() {});


                  });
                },
                child: const SizedBox(
                  height: kToolbarHeight,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      '수락하기',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ))
          ],
        ),
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
                                color: Colors.yellow,
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
