import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/functions/utilities/Utility.dart';
import 'package:dalddong/functions/utilities/utilities_dalddong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../commonScreens/shared_app_bar.dart';
import '../../functions/providers/calendar_provider.dart';
import 'dv_calculate_available_date_screen.dart';


class RegistrationDalddongInChat extends StatefulWidget {
  const RegistrationDalddongInChat(
      {Key? key, required this.chatMembers, required this.chatroomId})
      : super(key: key);

  final List<QueryDocumentSnapshot>? chatMembers;
  final String? chatroomId;

  @override
  State<RegistrationDalddongInChat> createState() =>
      _RegistrationDalddongInChatState();
}

class _RegistrationDalddongInChatState
    extends State<RegistrationDalddongInChat> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? futureSearchResults;
  List<String> alreadyInChatRoom = [];

  @override
  void initState() {
    super.initState();

    // Provider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DalddongProvider>().resetAllProvider();
    });

    widget.chatMembers?.forEach((element) {
      alreadyInChatRoom.add(element.get('userName'));
    });

    Future<QuerySnapshot> friends = FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('friendsList')
        .where('userName', whereNotIn: alreadyInChatRoom)
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
        .where('userName', whereNotIn: alreadyInChatRoom)
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


    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: BaseAppBar(
        appBar: AppBar(),
        title: "달똥투표",
        backBtn: true,
        center: false,
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 30,
          ),

          const Text(
            '함께할 친구',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.chatMembers?.length,
                        itemBuilder: (context, index) {

                          return Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    widget.chatMembers?[index].get('userImage')),
                              ),
                              Text(
                                  "${widget.chatMembers?[index].get('userName')}")
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Text(
              "간점 or 헵저(간단점심, 헤비한저녁)",
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
                  context.read<DalddongProvider>().changeDalddongDinner(false);
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
                },
              ),
            ),
          ]),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
            child: Text(
              "추가할 친구가 있으신가요?",
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

                  if (context.read<DalddongProvider>().newDdFriends.isNotEmpty)
                    Flexible(
                      fit: FlexFit.loose,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: context
                            .read<DalddongProvider>()
                            .newDdFriends
                            .length,
                        itemBuilder: (context, index) {
                          return Column(
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
                                width: 15,
                              ),
                              Text(context
                                  .read<DalddongProvider>()
                                  .newDdFriends[index]['userName']),
                            ],
                          );
                        },
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

                        return Flexible(
                          fit: FlexFit.tight,
                          child: SizedBox(
                            height: 10,
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
            height: 60,
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(const Color(0xff025645))),
              onPressed: () async {
                // 기존 맴버 provider에 추가
                widget.chatMembers?.forEach((element) {
                  context.read<DalddongProvider>().changeNewDdFriends(element);
                });

                if (context.read<DalddongProvider>().newDdFriends.isNotEmpty) {
                  var myName = await getMyName();

                  if(context.mounted) {
                    // var dalddongId = addDalddongVoteList(context, context.read<DalddongProvider>().newDdFriends);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WaitCalculateDates(
                              dalddongMembers: context.read<DalddongProvider>().newDdFriends,
                              hostName: myName!
                          ),
                        ));
                  }
                }
              },
              child: const Text("날짜 찾기", style: TextStyle(color: Colors.white),),
            ),
          )
        ],
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
      // margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.all(3.0),

      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              context.read<DalddongProvider>().changeNewDdFriends(eachUser);
              // print(eachUser['userName']);
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
