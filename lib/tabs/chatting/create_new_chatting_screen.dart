import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/providers/new_message_provider.dart';
import '../../functions/utilities/utilities_chat.dart';
import 'chatting_screen.dart';


// 상단
class MakeNewMessage extends StatefulWidget {
  const MakeNewMessage({Key? key}) : super(key: key);

  @override
  State<MakeNewMessage> createState() => _MakeNewMessage();
}

class _MakeNewMessage extends State<MakeNewMessage> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? futureSearchResults;

  @override
  void initState() {
    super.initState();

    //  Provider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewMessageProvider>().resetAllList();
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

    context.watch<NewMessageProvider>().newMsgFriends;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        appBar: AppBar(),
        title: '새로운 채팅',
        backBtn: true,
        hasIcon: false,
        isCreateChatRoom: true,
      ),

      body: Column(
        children: <Widget>[
          // if(context.read<NewMessageProvider>().newMsgFriends.isNotEmpty)

          searchText(),
          const SizedBox(
            height: 10,
          ),
          futureSearchResults == null
              ? FutureBuilder(
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
              })
              : FutureBuilder(
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
              }),
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
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                context.read<NewMessageProvider>().changeNewMsgFriends(eachUser);
                setState(() {});
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
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
                    .read<NewMessageProvider>()
                    .newMsgFriends
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
