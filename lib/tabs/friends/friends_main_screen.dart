import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../commonScreens/page_route_with_animation.dart';
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/utilities/Utility.dart';
import 'friends_profile_screen.dart';
import 'friends_search_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final firebase = FirebaseFirestore.instance;

  late String? _myName;
  late String? _myEmail;
  late String? _myImage;
  late String _myPhoneNumber;

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  getMyInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _myName = prefs.getString('userName');
    _myEmail = prefs.getString('userEmail');
    _myImage = prefs.getString('userImage');
  }

  // final kakaoLoginModel = KakaoLoginModel(KaKaoLogin());

  // TODO: 카카오톡 친구목록(달똥가입자 한) 불러오기
  // KAKAO FRIENDS API
  void kakao_friends() async {
    try {
      kakao.Friends friends = await kakao.TalkApi.instance.friends();
      print('카카오톡 친구 목록 가져오기 성공'
          '\n${friends.elements?.map((friend) => friend.profileNickname).join('\n')}');
    } catch (error) {
      print('카카오톡 친구 목록 가져오기 실패 $error');
    }
  }

  Future<bool> getPermission() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // kakao_friends();

    try {
      return WillPopScope(
        onWillPop: () async {
          final value = await yesNoDialog(context, "앱을 종료하십니까?");
          return value == true;
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scaffold(
            backgroundColor: GeneralUiConfig.backgroundColor,
            appBar: BaseAppBar(
              appBar: AppBar(),
              title: "달똥메이트",
              backBtn: false,
              center: false,
              hasIcon: true,

            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(FirebaseAuth.instance.currentUser?.email)
                  .collection('friendsList').orderBy('userName', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "내 프로필",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),

                    ListTile(
                      leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(_myImage!)
                          //ExactAssetImage('image/default_profile.png'),
                          ),
                      title: Text(
                        _myName!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        _myEmail!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      "친구 ${snapshot.data?.docs.length}",
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),

                    if (snapshot.data!.docs.isEmpty)
                      const Center(
                        child: Text("친구가 없습니다. 아래 추가하기 버튼을 친구를 추가해주세요"),
                      ),

                    if (snapshot.data!.docs.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => showProfile(
                                        userName: snapshot.data?.docs[index]['userName'],
                                        userEmail: snapshot.data?.docs[index]['userEmail'],
                                        userImage: snapshot.data?.docs[index]['userImage'],
                                        myEmail: _myEmail,
                                      ),
                                    ));
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(snapshot
                                            .data?.docs[index]['userImage'])
                                    ),
                                title: Text(
                                  snapshot.data?.docs[index]['userName'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  snapshot.data?.docs[index]['userEmail'],
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[500]),
                                ),
                              ),
                            );
                          },
                          // separatorBuilder: (BuildContext context, int index) => null,
                        ),
                      ),
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: GeneralUiConfig.floatingBtnColor,
              highlightElevation: 100,
              child: const Icon(
                Icons.person_add_alt_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      color: Colors.black,
                                      size: 50,
                                    ), // 설정 아이콘 생성
                                    onPressed: () {
                                      // 아이콘 버튼 실행
                                      PageRouteWithAnimation pageRoute =
                                          PageRouteWithAnimation(
                                              const SearchFriends());
                                      Navigator.push(context,
                                          pageRoute.slideBottonToTop());
                                    },
                                  ),
                                  const Text('친구검색'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.perm_contact_calendar_rounded,
                                      color: Colors.black,
                                      size: 50,
                                    ), // 설정 아이콘 생성
                                    onPressed: () async {
                                      // 아이콘 버튼 실행
                                      var status =
                                          await Permission.contacts.status;
                                      if (status.isGranted) {
                                        var contacts =
                                            await ContactsService.getContacts();
                                        contacts.forEach((contactsElement) {
                                          contactsElement.phones
                                              ?.forEach((phoneNumbers) async {
                                            // phoneNumbers.value;
                                            var docs = await FirebaseFirestore
                                                .instance
                                                .collection('user')
                                                .where('phoneNumber',
                                                    isEqualTo:
                                                        phoneNumbers.value)
                                                .get();

                                            if (docs.docs.isNotEmpty) {
                                              docs.docs.forEach((element) {
                                                insertFriendList(
                                                    element.get('userEmail'));
                                              });
                                            }
                                          });
                                        });
                                        setState(() {});
                                      } else if (status.isDenied) {
                                        Permission.contacts.request();
                                      }
                                    },
                                  ),
                                  const Text('연락처로 업데이트'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              },
            ),
          ),
        ),
      );
    } catch (e) {
      showAlertDialog(context, e.toString());
      return Text(e.toString());
    }
  }
}
