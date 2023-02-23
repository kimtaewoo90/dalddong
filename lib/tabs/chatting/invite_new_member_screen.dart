import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../commonScreens/page_route_with_animation.dart';
import '../../functions/providers/chatroom_provider.dart';
import '../../functions/utilities/utilities_chat.dart';
import 'chatting_screen.dart';


class InviteChatMembers extends StatefulWidget {
  final String? chatroomId;
  final bool? isNeedMakeGroup;
  final List<QueryDocumentSnapshot> existedUser;
  const InviteChatMembers({Key? key,
    required this.chatroomId,
    required this.isNeedMakeGroup,
    required this.existedUser}) : super(key: key);

  @override
  State<InviteChatMembers> createState() => _InviteChatMembersState();
}

class _InviteChatMembersState extends State<InviteChatMembers> {

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? futureSearchResults;

  @override
  void initState(){
    super.initState();

    // provider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatroomProvider>().resetAllList();
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

  emptyTheTextFormField() {
    searchTextEditingController.clear();
  }

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

  Widget searchText() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: TextFormField(
        controller: searchTextEditingController,
        // 검색창 컨트롤러
        decoration: InputDecoration(
            hintText: '이름, 회사, 전화번호로 검색해보세요!',
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            filled: true,
            prefixIcon: const Icon(
              Icons.person_pin,
              color: Colors.white,
              size: 30,
            ),
            suffixIcon: IconButton(
                onPressed: () {
                  emptyTheTextFormField;
                  setState(() {});
                },
                icon: const Icon(
                  Icons.clear,
                  color: Colors.white,
                ))),
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
        onFieldSubmitted: controlSearching,
        onChanged: controlSearching,
      ),
    );
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
            // User users = document.;
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

  displayUsersFoundScreen() {
    return FutureBuilder(
        future: futureSearchResults,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          List<UserResult> searchUserResult = [];

          snapshot.data?.docs.forEach((document) {
            // User users = document.;
            UserResult userResult = UserResult(document);
            searchUserResult.add(userResult);
          });

          return Flexible(
            fit: FlexFit.tight,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView(
                // shrinkWrap: true,
                children: searchUserResult,
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Image.asset("assets/images/ic_chevron_30_back.png", width: 24, height: 24,),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xff025645),
        centerTitle: true,
        title: const Text(
          "대화상대 초대",
          style: TextStyle(
              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w700),
        ),

        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.navigate_next),
            color: context.read<ChatroomProvider>().newInvitedFriends.isEmpty ? Colors.grey : Colors.white,// 설정 아이콘 생성
            onPressed: () async {

              // Invite others in privateChat => make New groupChat.
              if (widget.isNeedMakeGroup!){
                // 기존 1:1채팅하던 상대 추가.
                widget.existedUser.forEach((element) {
                  context.read<ChatroomProvider>().changeNewInvitedFriends(element);
                });

                var groupRoomId = await makeNewGroupChatRoom(context.read<ChatroomProvider>().newInvitedFriends);
                var title = await FirebaseFirestore.instance.collection('chatrooms').doc(groupRoomId).get().then((value){
                  return value.get('chatRoomName');
                });

                PageRouteWithAnimation pageRoute = PageRouteWithAnimation(ChatScreen(groupRoomId, title));
                Navigator.push(context, pageRoute.slideBottonToTop());
              }

              // Invite others in existed GroupChat.
              else{
                if (context.read<ChatroomProvider>().newInvitedFriends.isEmpty){}
                else{
                  inviteToChatRoom(widget.chatroomId!, context.read<ChatroomProvider>().newInvitedFriends);
                  Navigator.pop(context);
                }
              }

            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          searchText(),
          const SizedBox(
            height: 10,
          ),
          futureSearchResults == null
              ? displayNoSearchResultScreen()
              : displayUsersFoundScreen(),
        ],
      ),
    );  }
}


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
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                context
                    .read<ChatroomProvider>()
                    .changeNewInvitedFriends(eachUser);
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
                    .read<ChatroomProvider>()
                    .newInvitedFriends
                    .contains(eachUser)
                    ? Icons.check_circle
                    : Icons.circle_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
