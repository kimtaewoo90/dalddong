// firebase
import 'package:cloud_firestore/cloud_firestore.dart';
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
          appBar: AppBar(
            backgroundColor: const Color(0xff025645) ,
            title: Text(widget.title ?? "", style: const TextStyle(color: Colors.white, fontSize: 18),),
            centerTitle: false, // 중앙 정렬
            elevation: 0.0,

          ),

          endDrawer: Drawer(

            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.white38,
                      ),
                      child: Text('사진, 텍스트 검색'),
                    ),

                    const Divider(),

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
                                  // scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,

                                  itemCount: snapshot.data?.docs.length,
                                  itemBuilder: (context, index) => SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Card(
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
                                            SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Image.network(
                                                snapshot.data?.docs[index]['userImage'],
                                              ),
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
                                backgroundColor:  const Color(0xff025645),
                              ),
                              child: const Icon(Icons.add, color: Colors.white,),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20,),

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


                    const SizedBox(height: 50,),

                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chatrooms')
                            .doc(widget.roomId)
                            .collection("participants")
                            .snapshots(),
                        builder: (context, snapshot2){

                          return SizedBox(
                            height: 80,
                            width: 80,
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
                                backgroundColor:  const Color(0xff025645),
                              ),
                              child: const Icon(Icons.schedule_send, color: Colors.white,),
                            ),
                          );
                        })



                  ],
                ),
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
