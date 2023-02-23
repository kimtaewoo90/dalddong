import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'friends_profile_screen.dart';


// 상단

class SearchFriends extends StatefulWidget {
  const SearchFriends({Key? key}) : super(key: key);

  @override
  State<SearchFriends> createState() => _SearchFriendsState();
}

class _SearchFriendsState extends State<SearchFriends> {

  late String _myName;
  late String _myEmail;
  late String _myPicture;

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? futureSearchResults;



  void getMyInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _myName = (prefs.getString('userName'))!;
      _myEmail = (prefs.getString('userEmail'))!;
      _myPicture = (prefs.getString('userImage'))!;
    });
  }

  emptyTheTextFormField() {
    searchTextEditingController.clear();
  }

  // TODO: 동명이인이 있으면 어떻게 처리하나
  controlSearching(str) async {
    Future<QuerySnapshot> allUsers =
    FirebaseFirestore.instance
        .collection('user')
        .where('userName', isNotEqualTo: _myName)
        .where('userName', isGreaterThanOrEqualTo: str).get();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

  AppBar searchAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: TextFormField(
        controller: searchTextEditingController,  // 검색창 컨트롤러
        decoration: const InputDecoration(
          hintText: 'Search here....',
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          filled: true,
          prefixIcon: Icon(Icons.person_pin, color: Colors.white, size: 30,),
          // suffixIcon: IconButton(
          //     onPressed: emptyTheTextFormField,
          //     icon: Icon(Icons.clear, color: Colors.white,))
        ),
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
        onFieldSubmitted: controlSearching,
        onChanged: controlSearching,
      ),
    );
  }

  displayNoSearchResultScreen(){
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: const <Widget> [
          Icon(Icons.group, color: Colors.grey, size: 150,),
          Text(
            'Search Users',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 40,
            ),
          ),
        ],
      ),
    );
  }

  displayUsersFoundScreen(String email) {

    double width = MediaQuery.of(context).size.width* 0.6;

    return FutureBuilder(
        future: futureSearchResults,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          return SizedBox(
            child: ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (ctx, index) =>
                  Container(
                    padding: const EdgeInsets.all(1),

                    child: Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  showProfile(userName: snapshot.data?.docs[index]['userName'],
                                    userEmail: snapshot.data?.docs[index]['userEmail'],
                                    userImage: snapshot.data?.docs[index]['userImage'], myEmail: email,),
                              )).then((value) => setState(() {}));
                          showProfile(
                            userName: snapshot.data?.docs[index]['userName'],
                            userEmail: snapshot.data?.docs[index]['userEmail'],
                            userImage: snapshot.data?.docs[index]['userImage'], myEmail: email,);
                        },

                        child: Row(
                            children: [
                              SizedBox(
                                width: 90,
                                height: 80,
                                child: Image.network(
                                    snapshot.data?.docs[index]['userImage']),
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

                                    const SizedBox(height: 10,),
                                    SizedBox(
                                      width: width,
                                      child: Text(
                                        snapshot.data?.docs[index]['userEmail'],
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[500]
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ]
                        ),
                      ),
                    ),
                  ),
            ),
          );
        }
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchAppBar(),
      body: futureSearchResults == null
          ? displayNoSearchResultScreen()
          : displayUsersFoundScreen(_myEmail),
    );
  }
}


// 하단
class UserResult extends StatelessWidget {
  final QueryDocumentSnapshot eachUser;
  const UserResult(this.eachUser, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: [
            GestureDetector(
              onTap: (){
                // Navigator.push(context, MaterialPageRoute(builder: (context) =>
                //     showProfile(data: eachUser, myEmail: getMyInfo(),),
                // )).then((value) => setState((){}));showProfile(data: snapshot.data?.docs[index], myEmail: email);
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: NetworkImage(eachUser['userImage'],),
                ),
                title: Text(eachUser['userName'], style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                ),

                // TODO: 친구가 아니면 친구추가 버튼 생성.
                trailing: const Text("친구추가"),
              ),

            ),
          ],
        ),
      ),
    );
  }
}
