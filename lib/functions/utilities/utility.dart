/*
  - generateRandomString
  - getMyName
  - getMyEmail
  - getMyImage
  - getMyNumber
  - setActiveStatus
  - inertFriendList
  - showAlertDialog
  - addBlockTypeDialog
  - yesNoDialog
  - signOut
*/

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../signInUp/signIn/socialSignIn/kakao/kakao_sign_in.dart';
import '../signInUp/signIn/socialSignIn/kakao/kakao_sign_in_model.dart';


String generateRandomString(int len) {
  var r = Random();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}

Future<String?> getMyName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userName');
}

Future<String?> getMyEmail() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userEmail');
}

Future<String?> getMyImage() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userImage');
}

Future<String> getMyNumber() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getString('phoneNumber'))!;
}

void setActiveStatus(bool isActive, [String? activeChatRoom]) async {
  // print("setActiveStatus");

  // String? activeChatRoom = isActive == true ? widget.room_id : "";

  // print(activeChatRoom);
  if (activeChatRoom == null){
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .update({
      'isActive' : isActive,
    });
  }
  else{
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .update({
      'isActive' : isActive,
      'activeChatRoom' : activeChatRoom
    });
  }
}

void insertFriendList(String userEmail) async{


  var userData = await FirebaseFirestore.instance.collection('user').doc(userEmail).get();
  FirebaseFirestore.instance.collection('user')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .collection('friendsList').doc(userEmail)
      .set({
    'phoneNumber' : userData.get('phoneNumber'),
    'userEmail' : userEmail,
    'userName' : userData.get('userName'),
    'userImage' : userData.get('userImage'),
  });
}

Future<void> showAlertDialog(BuildContext context, String msg) async {
  return await showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(msg),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인')),
        ],
      );
    },
  );
}

Future<int?> addBlockTypeDialog(BuildContext context, String msg) async {
  return await showDialog<int>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(msg),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: const Text('점심')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 1),
              child: const Text('저녁')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, 2),
              child: const Text('종일')),
        ],
      );
    },
  );
}

Future<bool?> yesNoDialog(BuildContext context, String msg) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(msg),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('네')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('아니요')),
        ],
      );
    },
  ) ?? false;
}

Future signOut() async {

  await FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.email).update({'pushToken' : ""});

  if (FirebaseAuth.instance.currentUser!.uid.contains('kakao')){
    final kakaoLoginModel = KakaoLoginModel(KaKaoLogin());
    await kakaoLoginModel.logout();
    print("소셜 로그아웃~");
  }
  else{
    try{
      await FirebaseAuth.instance.signOut();
      print("일반 로그아웃~");
    } catch (e){
      return null;
    }
  }
}
