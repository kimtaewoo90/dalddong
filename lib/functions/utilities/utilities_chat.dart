// QueryDocumentSnapshot<Object?> data
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Utility.dart' as util;


// Make the Dalddong Chat Room
void makeDalddongChatRoom(String? dalddongId, List<dynamic> dalddongMembers, String chatRoomName) {
  // make Dalddong ChatRoom
  FirebaseFirestore.instance.collection('chatrooms').doc(dalddongId).set({
    "isDalddong": true,
  });

  dalddongMembers.forEach((element) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(element)
        .get()
        .then((userValue) {
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(dalddongId)
          .collection('participants')
          .add({
        'userName': userValue.get('userName'),
        'userImage': userValue.get('userImage'),
        'userEmail': userValue.get('userEmail'),
      });

      FirebaseFirestore.instance
          .collection('user')
          .doc(element)
          .collection('chatRoomList')
          .doc(dalddongId)
          .set({
        "isDalddong": true,
        "chatRoomId": dalddongId,
        "userName": userValue.get('userName'),
        "userEmail": userValue.get('userEmail'),
        'userImage': userValue.get('userImage'),
        'latestText': "",
        'chatRoomName' : chatRoomName,
        'latestTimeString': "",
      });
    });
  });
}


Future<String?> makeNewChatRoom(
    String userName, String userEmail, String userImage) async {
  String? roomId;

  // check duplication
  roomId = await FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .collection("chatRoomList")
      .get()
      .then((value) {
    for (var element in value.docs) {
      if (element.get('userName') == userName) {
        return element.get("chatRoomId");
      }
    }
    return "none";
  });

  if (roomId == "none") {
    roomId = util.generateRandomString(20);
  }

  SharedPreferences.getInstance().then((value) async {
    SharedPreferences prefs = value;
    var myName = prefs.getString('userName');
    var myImage = prefs.getString('userImage');
    var myEmail = prefs.getString('userEmail');

    // 상대방 DB
    await FirebaseFirestore.instance
        .collection('user')
        .doc(userEmail)
        .collection('chatRoomList')
        .doc(roomId)
        .set({
      "isDalddong": false,
      "chatRoomId": roomId,
      "userName": myName,
      "userEmail": myEmail,
      'userImage': myImage,
      'latestText': "",
      'chatMembers' : FieldValue.arrayUnion([myEmail]),
      'chatRoomName' : myName,
    });

    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(roomId)
        .collection('participants')
        .doc(myEmail)
        .set({
      'userName': myName,
      'userImage': myImage,
      'userEmail': myEmail,
    });

    await FirebaseFirestore.instance.collection('user').doc(myEmail).update(
        {'activeChatRoom' : roomId});

    var AMorPM = DateTime.now().hour ~/ 12 == 0 ? "오전" : "오후";
    var hour = AMorPM == "오전" ? DateTime.now().hour : DateTime.now().hour - 12;
    var timeStamp = "$AMorPM $hour : ${DateTime.now().minute}";

    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('chatRoomList')
        .doc(roomId)
        .set({
      "isDalddong": false,
      "chatRoomId": roomId,
      "userName": userName,
      "userEmail": userEmail,
      'userImage': userImage,
      'latestText': "",
      'latestTimeString': timeStamp,
      'chatMembers' : FieldValue.arrayUnion([userEmail]),
      'chatRoomName' : userName,
    });

    FirebaseFirestore.instance.collection('chatrooms').doc(roomId).set({
      "isDalddong": false,
      "chatRoomName" : userName
    });

    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(roomId)
        .collection('participants')
        .doc(userEmail)
        .set({
      'userName': userName,
      'userImage': userImage,
      'userEmail': userEmail,
    });
  });


  return roomId;
}

Future<String?> makeNewGroupChatRoom(
    List<QueryDocumentSnapshot> chatMembers) async {

  List<String> chatMembersEmail = [];
  for (var element in chatMembers) {
    chatMembersEmail.add(element['userEmail']);
  }

  chatMembersEmail.add(FirebaseAuth.instance.currentUser!.email!);

  chatMembersEmail.sort((a,b){
    return a.toLowerCase().compareTo(b.toLowerCase());
  });

  // Check duplication for ChatroomId
  String roomId = await FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .collection("chatRoomList").where('chatMembers', isNull: false)
      .get()
      .then((value) {
    for (var element in value.docs) {
      var members = List.from(element.get('chatMembers'));
      members.sort((a,b){
        return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
      });
      if (listEquals(members, chatMembersEmail)){
        return element.get('chatRoomId');
      }
    }
    return "none";
  });

  if (roomId == "none") {
    roomId = util.generateRandomString(20);


    var AMorPM = DateTime
        .now()
        .hour ~/ 12 == 0 ? "오전" : "오후";
    var hour = AMorPM == "오전" ? DateTime
        .now()
        .hour : DateTime
        .now()
        .hour - 12;
    var timeStamp = "$AMorPM $hour : ${DateTime
        .now()
        .minute}";

    var initialRoomName = "";
    chatMembers.forEach((element) {
      initialRoomName = ('$initialRoomName ${element['userName']}, ');
    });

    // For me
    SharedPreferences.getInstance().then((value) {

      SharedPreferences prefs = value;
      String? myName = prefs.getString('userName');
      String? myEmail = prefs.getString('userEmail');
      String? myImage = prefs.getString('userImage');

      FirebaseFirestore.instance.collection('user').doc(myEmail).collection('chatRoomList').doc(roomId).set({
        "isDalddong": false,
        "chatRoomId": roomId,
        "userName": myName,
        "userEmail": myEmail,
        'userImage': myImage,
        'latestText': "",
        'latestTimeString': timeStamp,
        'chatMembers' : FieldValue.arrayUnion(chatMembersEmail),
        "chatRoomName" : '$initialRoomName 과의 그룹채팅',
      });

      FirebaseFirestore.instance.collection('chatrooms').doc(roomId).collection('participants').doc(myEmail).set({
        "userName": myName,
        "userEmail": myEmail,
        'userImage': myImage,
      });
    });


    chatMembers.forEach((member) {
      FirebaseFirestore.instance.collection('user').doc(member['userEmail']).collection('chatRoomList').doc(roomId).set({
        "isDalddong": false,
        "chatRoomId": roomId,
        "userName": member['userName'],
        "userEmail": member['userEmail'],
        'userImage': member['userImage'],
        'latestText': "",
        'latestTimeString': timeStamp,
        'chatMembers' : FieldValue.arrayUnion(chatMembersEmail),
        "chatRoomName" : '$initialRoomName 과의 그룹채팅',
      });

      FirebaseFirestore.instance.collection('chatrooms').doc(roomId).collection('participants').doc(member['userEmail']).set({
        "userName": member['userName'],
        "userEmail": member['userEmail'],
        'userImage': member['userImage'],
      });
    });

    FirebaseFirestore.instance.collection('chatrooms').doc(roomId).set({
      "isDalddong": false,
      'chatRoomName' : '$initialRoomName 과의 그룹채팅',
      'chatMembers' : FieldValue.arrayUnion(chatMembersEmail),
    });

    return roomId;
  }

  else {
    return roomId;
  }
}


void inviteToChatRoom(String roomId, List<QueryDocumentSnapshot> invitedMembers){

  var AMorPM = DateTime
      .now()
      .hour ~/ 12 == 0 ? "오전" : "오후";
  var hour = AMorPM == "오전" ? DateTime
      .now()
      .hour : DateTime
      .now()
      .hour - 12;
  var timeStamp = "$AMorPM $hour : ${DateTime
      .now()
      .minute}";

  // chatMembers, chatRoomName 추출
  FirebaseFirestore.instance.collection('chatrooms').doc(roomId).get().then((value) {

    var chatMembersEmail = [];
    var existedChatMembersEmail = [];

    for (var element in invitedMembers) {
      chatMembersEmail.add(element['userEmail']);
    }

    for (var element in List.from(value.get('chatMembers'))) {
      chatMembersEmail.add(element);
    }

    // 각자 chatRoomList에 해당 채팅방 추가
    invitedMembers.forEach((element) {
      FirebaseFirestore.instance.collection('user').doc(element.get('userEmail')).collection('chatRoomList').doc(roomId).set({
        "isDalddong": false,
        "chatRoomId": roomId,
        "userName": element.get('userName'),
        "userEmail": element.get('userEmail'),
        'userImage': element.get('userImage'),
        'latestText': "",
        'latestTimeString': timeStamp,
        'chatMembers' : FieldValue.arrayUnion(chatMembersEmail),
        "chatRoomName" : value.get('chatRoomName'),
      });

      // chatrooms 해당채팅방에 participants 추가
      FirebaseFirestore.instance.collection('chatrooms').doc(roomId).collection('participants').doc(element.get('userEmail')).set({
        "userName": element.get('userName'),
        "userEmail": element.get('userEmail'),
        'userImage': element.get('userImage'),
      });

      // TODO: conversation 에 "000님께서 초대되었습니다" 메시지 추가
    });
  });
}
