import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../commonScreens/page_route_with_animation.dart';
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/utilities/Utility.dart';
import 'friends_profile_screen.dart';
import 'friends_search_from_phone_screen.dart';
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
                    .collection('friendsList')
                    .orderBy('userName', descending: false)
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
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[500]),
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
                                          userName: snapshot.data?.docs[index]
                                              ['userName'],
                                          userEmail: snapshot.data?.docs[index]
                                              ['userEmail'],
                                          userImage: snapshot.data?.docs[index]
                                              ['userImage'],
                                          myEmail: _myEmail,
                                        ),
                                      ));
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(snapshot
                                          .data?.docs[index]['userImage'])),
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
              floatingActionButton: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                child: SpeedDial(
                  overlayOpacity: 0.5,
                  animatedIcon: AnimatedIcons.add_event,
                  backgroundColor: GeneralUiConfig.floatingBtnColor,
                  // icon: Icon(Icons.edit),

                  children: [
                    SpeedDialChild(
                        child: const Icon(Icons.phone),
                        label: "연락처로 업데이트",
                        onTap: () async {
                          var status = await Permission.contacts.request();
                          print(
                              "status : ${status.isGranted}/${status.isDenied}/${status.isLimited}/${status.isPermanentlyDenied}");
                          if (status.isGranted) {
                            print('isGranted');
                            PageRouteWithAnimation pageRoute =
                                PageRouteWithAnimation(const SearchFromPhone());
                            if (context.mounted) {
                              Navigator.push(
                                  context, pageRoute.slideBottonToTop());
                            }
                          } else if (status.isDenied) {
                            print("isDenied");
                            if (Platform.isAndroid) {
                              print('isAndroid');
                              // 안드로이드에서는 권한 요청 팝업이 자동으로 표시됩니다.
                              status = await Permission.contacts.request();

                              if (status.isGranted) {
                                PageRouteWithAnimation pageRoute =
                                    PageRouteWithAnimation(
                                        const SearchFromPhone());
                                if (context.mounted) {
                                  Navigator.push(
                                      context, pageRoute.slideBottonToTop());
                                }
                              }
                            } else if (Platform.isIOS) {
                              print("isIos");
                              // iOS에서는 권한 요청 메시지를 직접 추가해야 합니다.
                              // 사용자에게 권한 요청에 대한 이유를 설명합니다.
                              if (await Permission
                                  .contacts.shouldShowRequestRationale) {
                                if (context.mounted) {
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text("Contacts Permission"),
                                      content: const Text(
                                          "This app needs access to your contacts to function properly."),
                                      actions: [
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }

                              // 권한 요청 팝업을 표시합니다.
                              status = await Permission.contacts.request();

                              if (context.mounted) {
                                if (status.isGranted) {
                                  PageRouteWithAnimation pageRoute =
                                      PageRouteWithAnimation(
                                          const SearchFromPhone());

                                  Navigator.push(
                                      context, pageRoute.slideBottonToTop());
                                }
                              }
                            }
                          } else if (status.isPermanentlyDenied) {
                            // 사용자가 권한 요청을 영구적으로 거부한 경우,
                            // 설정으로 이동할 수 있는 버튼을 표시합니다.

                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text("전화번호부 권한설정"),
                                  content: const Text(
                                      "휴대폰의 세팅에서 전화번호부 권한을 설정해야 합니다."),
                                  actions: [
                                    TextButton(
                                      child: const Text("취소"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: const Text("세팅으로 이동"),
                                      onPressed: () async {
                                        await openAppSettings();
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        }),
                    SpeedDialChild(
                        child: const Icon(Icons.search),
                        label: "친구찾기",
                        onTap: () {
                          // 아이콘 버튼 실행
                          PageRouteWithAnimation pageRoute =
                              PageRouteWithAnimation(const SearchFriends());
                          Navigator.push(context, pageRoute.slideBottonToTop());
                        }),
                  ],
                ),
              )),
        ),
      );
    } catch (e) {
      showAlertDialog(context, e.toString());
      return Text(e.toString());
    }
  }
}
