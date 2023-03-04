// firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// flutter
import 'package:flutter/material.dart';

// common functions
import '../../commonScreens/page_route_with_animation.dart';
import '../../functions/utilities/Utility.dart';

// screens
import '../../dalddongScreens/dalddongVote/dv_request_vote_screen.dart';
import '../friends/friends_profile_screen.dart';
import 'chatRoom/message.dart';
import 'chatRoom/new_message.dart';
import 'invite_new_member_screen.dart';


class ChatScreen extends StatefulWidget {

  final String? roomId;
  final String? title;
  const ChatScreen(this.roomId, this.title, {Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>  {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String activeChatRoom = "";

  @override
  void initState(){
    super.initState();
    getCurrentUser();
    activeChatRoom = widget.roomId!;
    setActiveStatus(true, activeChatRoom);
  }

  void getCurrentUser(){
    try{
      final user = _authentication.currentUser;

      if (user != null){
        loggedUser = user;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }



  @override
  Widget build(BuildContext context) {

    bool? isPrivateChat;
    List<QueryDocumentSnapshot> existedUser =[];

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          activeChatRoom = "";
          setActiveStatus(true, activeChatRoom);
        });

        return true;
      },

      child: Scaffold(
        backgroundColor: GeneralUiConfig.backgroundColor,
          appBar: AppBar(
            backgroundColor: GeneralUiConfig.backgroundColor ,
            title: Text(widget.title ?? "", style: const TextStyle(color: Colors.black, fontSize: 18),),
            centerTitle: false, // 중앙 정렬
            elevation: 0.0,

          ),

          endDrawer: Drawer(
            surfaceTintColor: Colors.black,
            shadowColor: Colors.white,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Text('사진, 텍스트 검색'),
                  ),

                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chatrooms')
                          .doc(widget.roomId)
                          .collection("participants")
                          .snapshots(),
                      builder: (context, snapshot){
                        isPrivateChat  = snapshot.data?.docs.length == 2 ? true : false;
                        snapshot.data?.docs.forEach((document) {
                          if(document.id != FirebaseAuth.instance.currentUser!.email){
                            existedUser.add(document);
                          }
                        });

                        if(snapshot.data != null && !snapshot.hasError){
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("참여인원 ${snapshot.data?.docs.length}"),
                              ),

                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: snapshot.data?.docs.length,
                                  itemBuilder: (context, index){
                                return Card(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  child: InkWell(
                                    onTap: (){
                                      if(snapshot.data?.docs[index]['userEmail']
                                          == loggedUser?.email){
                                        // PageRouteWithAnimation pageRoute = PageRouteWithAnimation(
                                        //     showMyProfile(myName: snapshot.data?.docs[index]['userName'],
                                        //         myEmail: snapshot.data?.docs[index]['userEmail'],
                                        //         myImage: snapshot.data?.docs[index]['userImage'])
                                        // );
                                        // Navigator.push(context, pageRoute.slideRitghtToLeft());

                                      }

                                      else{
                                        PageRouteWithAnimation pageRoute = PageRouteWithAnimation(
                                            showProfile(userName: snapshot.data?.docs[index]['userName'],
                                              userEmail: snapshot.data?.docs[index]['userEmail'],
                                              userImage: snapshot.data?.docs[index]['userImage'],
                                              myEmail: loggedUser?.email,
                                            )
                                        );
                                        Navigator.push(context, pageRoute.slideRitghtToLeft());
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(snapshot.data?.docs[index]['userImage'],)
                                          //ExactAssetImage('image/default_profile.png'),
                                        ),
                                        const SizedBox(width: 10,),

                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          child: Text(
                                            snapshot.data?.docs[index]['userName'],
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              Card(
                                color: Colors.transparent,
                                elevation: 0,
                                child: InkWell(
                                  onTap:(){
                                    PageRouteWithAnimation pageRoute = PageRouteWithAnimation(
                                        InviteChatMembers(
                                          chatroomId: widget.roomId,
                                          isNeedMakeGroup: isPrivateChat,
                                          existedUser: existedUser,));
                                    Navigator.push(context, pageRoute.slideBottonToTop());
                                  },

                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Image.asset('images/dalddongVote.png')
                                      ),

                                      const SizedBox(width: 10,),

                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.5,
                                        child: const Text(
                                          "친구초대",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        else{
                          return const Center(child: CircularProgressIndicator());
                        }
                      }
                  ),

                  const SizedBox(height: 10,),

                  const Text('달똥투표하기'),

                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chatrooms')
                          .doc(widget.roomId)
                          .collection("participants")
                          .snapshots(),
                      builder: (context, snapshot2){

                        return SizedBox(
                          height: 50,
                          width: 50,
                          child: ElevatedButton(
                            onPressed: (){
                              PageRouteWithAnimation pageRoute =
                              PageRouteWithAnimation(
                                  RegistrationDalddongInChat(
                                    chatMembers: snapshot2.data?.docs,
                                    chatroomId: widget.roomId,
                                  )
                              );

                              Navigator.push(context, pageRoute.slideBottonToTop());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GeneralUiConfig.floatingBtnColor,
                            ),
                            child: const Icon(Icons.schedule_send, color: Colors.black,),
                          ),
                        );
                      }),
                  const SizedBox(height: 20,),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: ElevatedButton(
                            onPressed: (){
                              PageRouteWithAnimation pageRoute = PageRouteWithAnimation(
                                  InviteChatMembers(
                                    chatroomId: widget.roomId,
                                    isNeedMakeGroup: isPrivateChat,
                                    existedUser: existedUser,));
                              Navigator.push(context, pageRoute.slideBottonToTop());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:  Colors.redAccent,
                            ),
                            child: const Icon(Icons.exit_to_app, color: Colors.white,),
                          ),
                        ),
                      ),
                    ],
                  ),



                ]

              ),
            ),
          ),


          body: Column(
            children: [
              Expanded(
                child: Messages(roomId: widget.roomId),
              ),
              NewMessage(roomId: widget.roomId),
            ],
          )
      ),
    );
  }
}


