// import 'dart:html';

// firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:firebase_auth/firebase_auth.dart';

// packages
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// common functions
import '../../commonScreens/shared_app_bar.dart';

// utility
import '../../functions/utilities/Utility.dart';

// screens
import 'chatting_screen.dart';
import 'create_new_chatting_screen.dart';



class ChatRooms extends StatefulWidget {
  const ChatRooms({Key? key}) : super(key: key);

  @override
  State<ChatRooms> createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> with TickerProviderStateMixin {
  final firebase = FirebaseFirestore.instance;
  bool isDalddong = false;
  late TabController _tabController;


  Stream<QuerySnapshot> myChatRoom =
  FirebaseFirestore.instance.collection('user')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .collection('chatRoomList').snapshots();

  List<String> chatList = [];

  // Searching Chatroom
  TextEditingController searchTextEditingController = TextEditingController();
  emptyTheTextFormField() {
    searchTextEditingController.clear();
  }

  controlSearching(str) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Future<QuerySnapshot> allUsers =
    FirebaseFirestore.instance
        .collection('user').doc(FirebaseAuth.instance.currentUser!.email).collection('friendsList')
        .where('userName', isNotEqualTo: prefs.getString('userName'))
        .where('userName', isGreaterThanOrEqualTo: str).get();
    setState(() {
      // futureSearchResults = allUsers;
    });
  }

  @override
  void initState(){
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width* 0.6;

    return WillPopScope(
      onWillPop: () async{
        final value = await yesNoDialog(context, "앱을 종료하십니까?");
        return value == true;
      },
      child: Scaffold(
        appBar: BaseAppBar(
          appBar: AppBar(),
          title: "채팅",
          backBtn: false,
          center: false,),

        body: Column(
          children: [
            TabBar(
              tabs: [
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: const Text(
                    '친구약속'
                  ),
                ),
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: const Text(
                      '달똥약속'
                  ),
                ),
              ],
              indicator: const BoxDecoration(
                // gradient: LinearGradient(
                //   begin: Alignment.centerLeft,
                //   end: Alignment.centerRight,
                //   colors: [
                //     Colors.lightGreenAccent,
                //     Colors.amberAccent,
                //   ]
                // )
                color: Colors.amberAccent
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              controller: _tabController,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: TextFormField(
                controller: searchTextEditingController,  // 검색창 컨트롤러
                decoration: InputDecoration(
                    hintText: '이름, 회사, 전화번호로 검색해보세요!',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    prefixIcon: const Icon(Icons.person_pin, color: Colors.white, size: 30,),
                    suffixIcon: IconButton(
                        onPressed: (){
                          emptyTheTextFormField;
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear, color: Colors.white,))
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
                onFieldSubmitted: controlSearching,
                onChanged: controlSearching,
              ),
            ),

            Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 친구채팅
                    Container(
                      color: GeneralUiConfig.backgroundColor,
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('user')
                              .doc(FirebaseAuth.instance.currentUser!.email)
                              .collection('chatRoomList').where("isDalddong", isEqualTo: false)
                              .orderBy('latestTime', descending: true)
                              .snapshots(),

                          builder: (context, snapshot) {
                            if (snapshot.data != null && !snapshot.hasError && snapshot.data?.docs.length != 0){

                              return ListView.separated(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                separatorBuilder: (context, int) => const Divider(color: Colors.grey,),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChatScreen(snapshot.data?.docs[index].id, snapshot.data?.docs[index].get('chatRoomName')),
                                        ),
                                      );
                                    },

                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius : 25,
                                          backgroundImage: NetworkImage(snapshot.data?.docs[index]['userImage']),
                                          backgroundColor: Colors.white,
                                        ),
                                        const SizedBox(width: 10,),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(1),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: width * 0.7,
                                                      child: Text(
                                                        snapshot.data?.docs[index]['chatRoomName'],
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),

                                                    const Spacer(),

                                                    SizedBox(
                                                      width: width * 0.4,
                                                      child: Text(
                                                        "${snapshot.data?.docs[index]['latestTimeString'] ?? ""}",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.normal,
                                                          color: Colors.black38,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                // Description 길이 때매 반응형으로 (화면전환)

                                                Row(
                                                  children: [
                                                    Expanded(
                                                      // width: width,
                                                      child: Text(
                                                        snapshot.data?.docs[index]['latestText'],
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey[500]
                                                        ),
                                                      ),
                                                    ),

                                                    const Spacer(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            else{
                              // return const Center(child: CircularProgressIndicator());
                              return const Center(
                                child: Text("채팅이 없습니다. 채팅을 추가해 보세요!"),
                              );
                            }
                          }
                      ),
                    ),

                    // 달똥채팅
                    Container(
                      color: GeneralUiConfig.backgroundColor,
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('user')
                              .doc(FirebaseAuth.instance.currentUser!.email)
                              .collection('chatRoomList').where("isDalddong", isEqualTo: true)
                              .orderBy('dalddongDate', descending: false)
                              .snapshots(),

                          builder: (context, dalddongSnapshot) {
                            if (dalddongSnapshot.data != null && !dalddongSnapshot.hasError && dalddongSnapshot.data!.docs.isNotEmpty){
                              return ListView.separated(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                separatorBuilder: (context, int) => const Divider(color: Colors.grey,),
                                itemCount: dalddongSnapshot.data!.docs.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChatScreen(dalddongSnapshot.data?.docs[index].id, dalddongSnapshot.data?.docs[index].get('chatRoomName')),
                                        ),
                                      );
                                    },

                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius : 25,
                                          backgroundColor: dalddongSnapshot.data?.docs[index].get('lunchOrDinner') == 0 ? Colors.yellowAccent : Colors.grey,
                                          child: dalddongSnapshot.data?.docs[index].get('lunchOrDinner') == 0 ? const Text("점심") : const Text("저녁"),
                                        ),
                                        const SizedBox(width: 10,),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(1),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: width * 0.7,
                                                      child: Text(
                                                        dalddongSnapshot.data?.docs[index]['chatRoomName'],
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),

                                                    const Spacer(),

                                                    SizedBox(
                                                      width: width * 0.4,
                                                      child: Text(
                                                        "${dalddongSnapshot.data?.docs[index]['latestTimeString'] ?? ""}",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.normal,
                                                          color: Colors.black38,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                // Description 길이 때매 반응형으로 (화면전환)

                                                Row(
                                                  children: [
                                                    Expanded(
                                                      // width: width,
                                                      child: Text(
                                                        dalddongSnapshot.data?.docs[index]['latestText'],
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey[500]
                                                        ),
                                                      ),
                                                    ),

                                                    const Spacer(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            else if(dalddongSnapshot.data?.docs == null){
                              return const Center(
                                child: Text("매칭된 달똥약속이 없습니다. 달똥해 보세요!"),
                              );
                            }

                            else{
                              return const Center(
                                child: Text("매칭된 달똥약속이 없습니다. 달똥해 보세요!"),
                              );
                            }
                          }
                      ),
                    ),

                  ],
                )
            )
          ],

        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: GeneralUiConfig.floatingBtnColor,
          child: const Icon(
              Icons.add),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MakeNewMessage()),
            );
          },
        ),
      ),
    );
  }
}

