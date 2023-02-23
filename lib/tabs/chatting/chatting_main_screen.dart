// import 'dart:html';

// firebase
import 'package:cloud_firestore/cloud_firestore.dart';
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

class _ChatRoomsState extends State<ChatRooms> {
  final firebase = FirebaseFirestore.instance;

  bool isDalddong = false;


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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width* 0.6;

    return WillPopScope(
      onWillPop: () async{
        final value = await yesNoDialog(context, "앱을 종료하십니까?");
        return value == true;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          appBar: BaseAppBar(
            appBar: AppBar(),
            title: "채팅",
            backBtn: false,
            center: false,),

          body:

          Column(
            children: [

              const SizedBox(height: 10,),
              // 개인약속채팅, 달똥약속채팅 구분
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        isDalddong = false;
                      });
                    },

                    child: Column(
                      children: [
                        Text(
                          '친구약속',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: !isDalddong ? Colors.black
                                  : Colors.grey
                          ),
                        ),
                        if(!isDalddong)
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            height: 2,
                            width: 55,
                            color: Colors.orange,
                          )
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: (){
                      setState(() {
                        isDalddong = true;
                      });
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '달똥약속',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDalddong ? Colors.black
                                      : Colors.grey
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                        if(isDalddong)
                          Container(
                            margin: const EdgeInsets.fromLTRB(0,3,35,0),
                            height: 2,
                            width: 55,
                            color: Colors.orange,
                          )
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 10,),

              // 대화내용 검색
              const SizedBox(height: 10,),

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

              const SizedBox(height: 10,),

              // 친구약속 채팅방 리스트
              if(!isDalddong)
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('chatRoomList').where("isDalddong", isEqualTo: false)
                        .orderBy('latestTime', descending: true)
                        .snapshots(),

                    builder: (context, snapshot) {
                      if (snapshot.data != null && !snapshot.hasError){

                        return Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,

                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) => Card(
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
                                      radius : 30,
                                      backgroundImage: NetworkImage(snapshot.data?.docs[index]['userImage']),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
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
                                                      fontSize: 18,
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
                                                      fontSize: 13,
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
                                                        fontSize: 15,
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

              // 달똥약속 채팅방 리스트
              if(isDalddong)
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('chatRoomList').where("isDalddong", isEqualTo: true)
                        .snapshots(),

                    builder: (context, dalddongSnapshot) {
                      if (dalddongSnapshot.data != null && !dalddongSnapshot.hasError){

                        return Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,

                            itemCount: dalddongSnapshot.data?.docs.length,
                            itemBuilder: (context, index) => Container(
                              padding: const EdgeInsets.all(0.5),
                              child: Card(
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
                                        radius : 30,
                                        backgroundImage: NetworkImage(dalddongSnapshot.data?.docs[index]['userImage']),
                                      ),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: width * 0.7,
                                                    child: Text(
                                                      dalddongSnapshot.data?.docs[index]['chatRoomName'],
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),

                                                  const Spacer(),

                                                  SizedBox(
                                                    width: width * 0.4,
                                                    child: Text(
                                                      "${dalddongSnapshot.data?.docs[index]['latestTimeString'] ?? ""}",
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              // Description 길이 때매 반응형으로 (화면전환)

                                              SizedBox(
                                                width: width,
                                                child: Text(
                                                  dalddongSnapshot.data?.docs[index]['latestText'],
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey[500]
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      else{
                        return const Center(child: CircularProgressIndicator());
                      }
                    }
                ),
            ],

          ),



          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xff025645),
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
      ),
    );
  }
}

