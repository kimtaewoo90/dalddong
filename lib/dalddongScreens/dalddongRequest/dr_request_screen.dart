import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../commonScreens/shared_app_bar.dart';
import '../../functions/providers/calendar_provider.dart';
import '../../functions/utilities/Utility.dart';
import '../../functions/utilities/utilities_dalddong.dart';
import 'dr_response_status_screen.dart';

class RegistrationDalddong extends StatefulWidget {
  const RegistrationDalddong({Key? key}) : super(key: key);

  @override
  State<RegistrationDalddong> createState() => _RegistrationDalddongState();
}

class _RegistrationDalddongState extends State<RegistrationDalddong> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? futureSearchResults;

  bool isError = false;
  bool isMyBlockDate = false;
  bool isBlockDate = false;
  bool isMyDalddongIngDate = false;
  bool isDalddongIngDate = false;

  @override
  void initState() {
    super.initState();

    // Provider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DalddongProvider>().resetAllProvider();
    });

    Future<QuerySnapshot> friends = FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('friendsList')
        .get();

    setState(() {
      futureSearchResults = friends;
    });
  }

  // TODO: 동명이인이 있으면 어떻게 처리하나
  controlSearching(str) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Future<QuerySnapshot> allUsers = FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('friendsList')
        .where('userName', isNotEqualTo: prefs.getString('userName'))
        .where('userName', isGreaterThanOrEqualTo: str)
        .get();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DalddongProvider>().DalddongDate;
    context.watch<DalddongProvider>().DalddongLunch;
    context.watch<DalddongProvider>().DalddongDinner;
    context.watch<DalddongProvider>().newDdFriends;
    context.watch<DalddongProvider>().starRating;

    final List<String> weekday_list = ['월', '화', '수', '목', '금', '토', '일'];

    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: GeneralUiConfig.backgroundColor,
        appBar: BaseAppBar(
          appBar: AppBar(),
          title: "달똥약속",
          backBtn: true,
          center: false,
        ),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "언제에요?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GeneralUiConfig.floatingBtnColor,
                  ),
                  child: Text(
                    "${context.read<DalddongProvider>().DalddongDate.year}년 "
                    "${context.read<DalddongProvider>().DalddongDate.month}월 "
                    "${context.read<DalddongProvider>().DalddongDate.day}일 "
                    "(${weekday_list[context.read<DalddongProvider>().DalddongDate.weekday - 1]})",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: GeneralUiConfig.hintSize),
                  ),
                  onPressed: () {
                    isError = false;
                    isMyBlockDate = false;
                    isBlockDate = false;
                    isMyDalddongIngDate = false;
                    isDalddongIngDate = false;

                    Future<DateTime?> selectedStartDate = showDatePicker(
                      context: context,
                      initialDate:
                          context.read<DalddongProvider>().DalddongDate,
                      //초기값
                      firstDate: DateTime(2022),
                      //시작일
                      lastDate: DateTime(2100),
                      //마지막일
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light(), // 테마
                          child: child!,
                        );
                      },
                    );
                    selectedStartDate.then((datetime) {
                      context
                          .read<DalddongProvider>()
                          .changeDalddongDate(datetime!);
                    });
                  },
                ),
              ),
            ]),
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "간점or헵저(간단점심, 헤비한저녁)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        context.read<DalddongProvider>().DalddongLunch == true
                            ? GeneralUiConfig.floatingBtnColor
                            : Colors.grey,
                  ),
                  child: const Text("점심"),
                  onPressed: () {
                    context.read<DalddongProvider>().changeDalddongLunch(true);
                    context
                        .read<DalddongProvider>()
                        .changeDalddongDinner(false);
                    context.read<DalddongProvider>().changeLunchOrDinner(0);
                  },
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        context.read<DalddongProvider>().DalddongDinner == true
                            ? GeneralUiConfig.floatingBtnColor
                            : Colors.grey,
                  ),
                  child: const Text("저녁"),
                  onPressed: () {
                    context.read<DalddongProvider>().changeDalddongLunch(false);
                    context.read<DalddongProvider>().changeDalddongDinner(true);
                    context.read<DalddongProvider>().changeLunchOrDinner(1);
                  },
                ),
              ),
            ]),
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
              child: Text(
                "맴버는 누구?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // 달똥메이트
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                height: 400,
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Column(
                  children: <Widget>[
                    const Center(
                      child: Text(
                        "달똥메이트",
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                    ),

                    if (context
                        .read<DalddongProvider>()
                        .newDdFriends
                        .isNotEmpty)
                      Flexible(
                        fit: FlexFit.loose,
                        child: SizedBox(
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: context
                                .read<DalddongProvider>()
                                .newDdFriends
                                .length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.black,
                                        backgroundImage: NetworkImage(
                                          context
                                              .read<DalddongProvider>()
                                              .newDdFriends[index]['userImage'],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(context
                                          .read<DalddongProvider>()
                                          .newDdFriends[index]['userName']),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                    const SizedBox(
                      height: 10,
                    ),
                    // 검색창
                    TextFormField(
                      controller: searchTextEditingController,
                      // 검색창 컨트롤러
                      decoration: const InputDecoration(
                        hintText: '이름, 회사, 전화번호로 검색해보세요!',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.person_pin,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      onFieldSubmitted: controlSearching,
                      onChanged: controlSearching,
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    futureSearchResults == null
                        ? const Center(child: Text("달똥메이트가 없습니다. 추가해보세요!"))
                        : FutureBuilder(
                            future: futureSearchResults,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              List<UserResult> friendsListResult = [];

                              snapshot.data?.docs.forEach((document) {
                                UserResult userResult = UserResult(document);
                                friendsListResult.add(userResult);
                              });

                              return Expanded(
                                // fit: FlexFit.tight,
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  child: ListView(
                                    // physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: friendsListResult,
                                  ),
                                ),
                              );
                            }),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "얼마나 중요한 약속인가요?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index <= context.read<DalddongProvider>().starRating
                        ? Icons.star
                        : Icons.star_border,
                  ),
                  onPressed: () {
                    context.read<DalddongProvider>().changeStarRating(index);
                    setState(() {});
                  },
                );
              }),
            ),

            const SizedBox(
              height: 10,
            ),

            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        GeneralUiConfig.floatingBtnColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ))),
                onPressed: () async {
                  isError = false;
                  if (context.read<DalddongProvider>().newDdFriends.isEmpty) {
                    showAlertDialog(context, "한명이상의 메이트를 선택해주세요");
                    isError = true;
                    return;
                  }

                  if (int.parse(context
                          .read<DalddongProvider>()
                          .DalddongDate
                          .difference(DateTime.now())
                          .inDays
                          .toString()) <
                      0) {
                    showAlertDialog(context, "과거로는 돌아갈 수 없어요 ㅠ");
                    isError = true;
                    return;
                  }

                  // 신청인 블락 날짜 계산
                  isMyBlockDate = await FirebaseFirestore.instance
                      .collection('user')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .collection('BlockDatesList')
                      .get()
                      .then((value) {
                    var temp = false;
                    value.docs.forEach((docs) {
                      if (DateTime.parse(docs.id) ==
                          context.read<DalddongProvider>().DalddongDate) {
                        if (docs.get('LunchOrDinner') ==
                            context.read<DalddongProvider>().lunchOrDinner) {
                          temp = true;
                          return;
                        }
                      }
                    });
                    return temp;
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    var temp = false;
                    context
                        .read<DalddongProvider>()
                        .newDdFriends
                        .forEach((eachUser) async {
                      // 해당날짜에 진행중인 달똥이 있을 경우
                      isDalddongIngDate = await FirebaseFirestore.instance
                          .collection('DalddongList')
                          .where('isAllConfirmed', isEqualTo: false)
                          .get()
                          .then((value) {
                        value.docs.forEach((element) {
                          // 신청인 진행중인 달똥
                          if (element.get('DalddongDate') != null) {
                            if (List.from(element.get('dalddongMembers'))
                                .contains(
                                    FirebaseAuth.instance.currentUser?.email)) {
                              if (DateTime.fromMillisecondsSinceEpoch(
                                      element.get('DalddongDate').seconds *
                                              1000 ??
                                          DateTime.now()) ==
                                  context
                                      .read<DalddongProvider>()
                                      .DalddongDate) {
                                if (element.get('LunchOrDinner') ==
                                    context
                                        .read<DalddongProvider>()
                                        .lunchOrDinner) {
                                  temp = true;
                                  return;
                                }
                              }
                            } else if (List.from(element.get('dalddongMembers'))
                                .contains(eachUser.get('userEmail'))) {
                              if (DateTime.fromMillisecondsSinceEpoch(
                                      element.get('DalddongDate').seconds *
                                              1000 ??
                                          DateTime.now()) ==
                                  context
                                      .read<DalddongProvider>()
                                      .DalddongDate) {
                                if (element.get('LunchOrDinner') ==
                                    context
                                        .read<DalddongProvider>()
                                        .lunchOrDinner) {
                                  temp = true;
                                  return;
                                }
                              }
                            }
                          }
                        });
                        return temp;
                      });

                      if (!isDalddongIngDate) {
                        isBlockDate = await FirebaseFirestore.instance
                            .collection('user')
                            .doc(eachUser.get('userEmail'))
                            .collection('BlockDatesList')
                            .get()
                            .then((blockValue) {
                          blockValue.docs.forEach((blockDates) {
                            if (DateTime.parse(blockDates.id) ==
                                context.read<DalddongProvider>().DalddongDate) {
                              if (blockDates.get('LunchOrDinner') ==
                                  context
                                      .read<DalddongProvider>()
                                      .lunchOrDinner) {
                                temp = true;
                                return;
                              }
                            }
                          });
                          return temp;
                        });
                      }

                      if (isDalddongIngDate || isBlockDate) {
                        return;
                      }
                    });
                  });

                  if(context.mounted){
                    // print("isDalddongIngDate : $isDalddongIngDate");
                    // print("isMyDalddongIngDate : $isMyDalddongIngDate");
                    // print("isMyBlockDate : $isMyBlockDate");
                    // print("isBlockDate : $isBlockDate");


                    if (isMyBlockDate || isBlockDate) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showAlertDialog(
                            context,
                            "${DateFormat('yyyy-MM-dd', 'ko_KR').format(context.read<DalddongProvider>().DalddongDate)}"
                                " ${context.read<DalddongProvider>().lunchOrDinner == 0 ? '점심' : context.read<DalddongProvider>().lunchOrDinner == 1 ? '저녁' : '종일'} 이미 블락되어있습니다. 날짜를 바꿔보세요!!!");
                      });
                      return;
                    }

                    if (isDalddongIngDate) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showAlertDialog(
                            context,
                            "${DateFormat('yyyy-MM-dd', 'ko_KR').format(context.read<DalddongProvider>().DalddongDate)}"
                                " ${context.read<DalddongProvider>().lunchOrDinner == 0 ? '점심' : context.read<DalddongProvider>().lunchOrDinner == 1 ? '저녁' : '종일'}  달똥약속이 진행중인 인원이 있습니다. 날짜를 바꿔보세요!!!'");
                      });
                      return;
                    }

                    // if (!isDalddongIngDate &&
                    //     !isBlockDate &&
                    //     !isMyBlockDate &&
                    //     !isMyDalddongIngDate) {
                      // WidgetsBinding.instance.addPostFrameCallback((_) {
                        var dalddongId = addDalddongList(context,
                            context.read<DalddongProvider>().newDdFriends);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResponseStatus(
                                dalddongId: dalddongId,
                              ),
                            ));
                      // });
                    // }
                  // });
                  }
                },
                child: const Text("달력에 동그라미"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 하단
class UserResult extends StatefulWidget {
  final QueryDocumentSnapshot eachUser;

  const UserResult(this.eachUser, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<UserResult> createState() => _UserResult(eachUser);
}

class _UserResult extends State<UserResult> {
  final QueryDocumentSnapshot eachUser;

  _UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white54,
      width: MediaQuery.of(context).size.width - 15,
      // height: MediaQuery.of(context).size.height -15,
      // margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.all(3.0),

      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              context.read<DalddongProvider>().changeNewDdFriends(eachUser);
              setState(() {});
            },
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
              trailing: Icon(context
                      .read<DalddongProvider>()
                      .newDdFriends
                      .contains(eachUser)
                  ? Icons.check_circle
                  : Icons.circle_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
