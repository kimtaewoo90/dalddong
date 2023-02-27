import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../functions/utilities/Utility.dart';
import '../../functions/utilities/utilities_chat.dart';
import '../chatting/chatting_screen.dart';


class showProfile extends StatefulWidget {

  // final QueryDocumentSnapshot<Object?>? data;
  final String? userName;
  final String? userEmail;
  final String? userImage;
  final String? myEmail;



  const showProfile({Key? key,
    // this.data,
    required this.userName,
    required this.userEmail,
    required this.userImage,
    required this.myEmail}) : super(key: key);

  @override
  State<showProfile> createState() => _showProfileState();
}

class _showProfileState extends State<showProfile> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: const Color(0xFF4E3535),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('user')
              .doc(widget.myEmail)
              .collection('friendsList').snapshots(),
          builder: (context, snapshot){

            List<String> friendsName = [];
            snapshot.data?.docs.forEach((document) {
              if(document.id != widget.myEmail){
                friendsName.add(document.id);
              }
            });

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50,),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white,),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
                const SizedBox(height: 50,),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                      )
                  ),
                ),
                ClipOval(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.network(widget.userImage!,
                      fit: BoxFit.cover,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    widget.userName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    "${widget.userName!}님과 식사한지 oo일 지났습니다!",
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20,),

                const Spacer(),

                // 친구가 아닐때
                if (!friendsName.contains(widget.userEmail!) && widget.userEmail != widget.myEmail)
                  Center(
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            insertFriendList(widget.userEmail!);
                            setState(() {});
                          },
                          icon: const Icon(Icons.person_add_alt_1),
                          iconSize: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10,),
                        const Text(
                          "친구추가",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ),

                // 친구일 때
                if (friendsName.contains(widget.userEmail))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  var chatroomId = await makeNewChatRoom(widget.userName!, widget.userEmail!, widget.userImage!);
                                  Future.delayed(const Duration(seconds: 1));
                                  String title = await FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(FirebaseAuth.instance.currentUser!.email)
                                      .collection('chatRoomList')
                                      .doc(chatroomId).get().then((value) {return value.get('chatRoomName');});

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context)  =>
                                          ChatScreen(chatroomId, title),
                                      )).then((value) => setState((){}));

                                  setState(() {});
                                },
                                icon: const Icon(Icons.sms_rounded),
                                iconSize: 40,
                                color: Colors.white,
                              ),

                              const SizedBox(height: 10,),
                              const Text(
                                "1:1채팅",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 40,),

                        Expanded(
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {});

                                },
                                icon: const Icon(Icons.waving_hand),
                                iconSize: 40,
                                color: Colors.white,
                              ),

                              const SizedBox(height: 10,),
                              const Text(
                                "달똥하기",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 50,),
              ],
            );
          },
        )
    );
  }
}
