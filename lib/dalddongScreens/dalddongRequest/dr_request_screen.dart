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

  displayUsersFoundScreen() {
    double width = MediaQuery.of(context).size.width * 0.6;

    return FutureBuilder(
        future: futureSearchResults,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          return SizedBox(
            child: ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (ctx, index) => Container(
                padding: const EdgeInsets.all(1),
                child: Card(
                  child: InkWell(
                    onTap: () {},
                    child: Row(children: [
                      Checkbox(
                          value: false,
                          onChanged: (value) {
                            setState(() {});
                          }),
                      SizedBox(
                        width: 90,
                        height: 80,
                        child: Image.network(
                            snapshot.data?.docs[index]['picked_image']),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            SizedBox(
                              width: width,
                              child: Text(
                                snapshot.data?.docs[index]['userName'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ),
          );
        });
  }

  displayNoSearchResultScreen() {
    // final Orientation orientation = MediaQuery.of(context).orientation;
    return FutureBuilder(
        future: futureSearchResults,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          List<UserResult> friendsListResult = [];

          snapshot.data?.docs.forEach((document) {
            UserResult userResult = UserResult(document);
            friendsListResult.add(userResult);
          });

          return Flexible(
            fit: FlexFit.tight,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView(
                // shrinkWrap: true,
                children: friendsListResult,
              ),
            ),
          );
        });
  }

  allDoneRequestDalddong() {
    if (isError == false) {
      var dalddongId = addDalddongList(
          context, context.read<DalddongProvider>().newDdFriends);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponseStatus(
              dalddongId: dalddongId,
            ),
          ));
    }
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
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                      "${context.read<DalddongProvider>().DalddongDate.year}년 "
                      "${context.read<DalddongProvider>().DalddongDate.month}월 "
                      "${context.read<DalddongProvider>().DalddongDate.day}일 "
                      "(${weekday_list[context.read<DalddongProvider>().DalddongDate.weekday - 1]})"),
                  onPressed: () {
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
                          data: ThemeData.light(), //다크 테마
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
                            ? Colors.blue
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
                            ? Colors.blue
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
                    // futureSearchResults == null
                    // ? displayNoSearchResultScreen()
                    // : displayUsersFoundScreen()
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
                    backgroundColor:
                        MaterialStateProperty.all(GeneralUiConfig.btnColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      // side: BorderSide(color: Colors.red)
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

                  isMyBlockDate = await FirebaseFirestore.instance
                      .collection('user')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .collection('BlockDatesList')
                      .get()
                      .then((value) {
                    bool myTemp = false;
                    value.docs.forEach((docs) {
                      if (DateTime.parse(docs.id) ==
                              context.read<DalddongProvider>().DalddongDate &&
                          (docs.get('LunchOrDinner') == context.read<DalddongProvider>().lunchOrDinner ||
                              docs.get('LunchOrDinner') == 2)) {
                        print(context.read<DalddongProvider>().lunchOrDinner);
                        myTemp = true;
                        showAlertDialog(
                            context,
                            "${DateFormat('yyyy-MM-dd', 'ko_KR').format(context.read<DalddongProvider>().DalddongDate)}"
                            " ${docs.get('LunchOrDinner') == 0 ? '점심에 이미 달똥약속이 존재합니다. 날짜를 바꿔보세요!!!' : docs.get('LunchOrDinner') == 1 ? '저녁에 이미 달똥약속이 존재합니다. 날짜를 바꿔보세요!!!' : '종일 달똥약속이 존재합니다. 날짜를 바꿔보세요!!'}");
                        return;
                      }
                    });
                    return myTemp;
                  });

                  if (context.mounted) {
                    if (isMyBlockDate == false) {
                      context
                          .read<DalddongProvider>()
                          .newDdFriends
                          .forEach((eachUser) async {
                        bool temp = false;
                        isError = await FirebaseFirestore.instance
                            .collection('user')
                            .doc(eachUser.get('userEmail'))
                            .collection('BlockDatesList')
                            .get()
                            .then((value) {
                          value.docs.forEach((blockDate) {
                            if (DateTime.parse(blockDate.id) == context.read<DalddongProvider>().DalddongDate &&
                                (blockDate.get('LunchOrDinner') == context.read<DalddongProvider>().lunchOrDinner ||
                                    blockDate.get('LunchOrDinner') == 2)) {
                              print((blockDate.get('LunchOrDinner') == context.read<DalddongProvider>().lunchOrDinner ||
                                  blockDate.get('LunchOrDinner') == 2));
                              showAlertDialog(
                                  context,
                                  "${DateFormat('yyyy-MM-dd', 'ko_KR').format(context.read<DalddongProvider>().DalddongDate)}"
                                  " ${blockDate.get('LunchOrDinner') == 0 ? '점심에 이미 달똥약속이 존재하는 인원이 있습니다. 날짜를 바꿔보세요!!!' : blockDate.get('LunchOrDinner') == 1 ? '저녁에 이미 달똥약속이 존재하는 인원이 있습니다. 날짜를 바꿔보세요!!!' : '종일 달똥약속이 존재하는 인원이 있습니다. 날짜를 바꿔보세요!!'}");
                              temp = true;
                              return;
                            }
                          });
                          return temp;
                        });
                      });

                      if (context.mounted) {
                        if (!isError) {
                          var dalddongId = addDalddongList(context,
                              context.read<DalddongProvider>().newDdFriends);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResponseStatus(
                                  dalddongId: dalddongId,
                                ),
                              ));
                        }
                      }
                    }
                  }
                },
                child: const Text("달력에 동그라미"),
              ),
            )
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
