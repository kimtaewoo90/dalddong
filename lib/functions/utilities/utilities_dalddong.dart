import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/functions/pushManager/push_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/calendar_provider.dart';
import 'Utility.dart';

// 투표완료, 달똥일자, 스케줄 저장 및 푸쉬
void completeDalddongVote(BuildContext context, String? dalddongId,
    List<QueryDocumentSnapshot> dalddongMembers) {
  List<Map<String, dynamic>> dateDic = [
    {'date': 'none', 'voted': -1}
  ];

  final pushManager = PushManager();

  // 투표한 날짜 중에 최다득표날짜 -> 동점이 있으면 가까운 날짜 선택
  FirebaseFirestore.instance
      .collection('DalddongList')
      .doc(dalddongId)
      .collection('voteDates')
      .snapshots()
      .forEach((element) {
    element.docs.forEach((eachDates) {
      dateDic.add({
        'date': eachDates.id,
        'voted': List.from(eachDates.get('votedMembers')).length
      });
    });
  });

  var max = dateDic.first;
  dateDic.forEach((maxVoted) {
    if (maxVoted['voted'] > max['voted']) {
      max = maxVoted;
    }
  });

  DateTime dalddongDate = DateTime.parse(max['date']);

  // Update dalddong Date
  FirebaseFirestore.instance
      .collection('DalddongList')
      .doc(dalddongId).update({'DalddongDate': dalddongDate});

  FirebaseFirestore.instance.collection('DalddongList').doc(dalddongId).get().then((value) {
    // 모든 맴버에게 달똥 완료 푸쉬 보내기
    dalddongMembers.forEach((members) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(members.get('userEmail'))
          .get()
          .then((pushTokenValue) {
        var userToken = pushTokenValue.get('pushToken');
        var title = "달똥날짜 확정!";
        var body =
            "${DateFormat('yyyy-MM-dd').format(dalddongDate)} ${value.get('LunchOrDinner') == true ? "점심" : "저녁"} 약속이 확정되었습니다.";
        var details = {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': "",
          'eventId': dalddongId,
          'eventType': "CDDV",
          'membersNum': dalddongMembers.length,
          'hostName': value.get('hostName'),
        };

        pushManager.sendPushMsg(
            userToken: userToken, title: title, body: body, details: details);


        // Register Dalddong Schedule at calendar
        FirebaseFirestore.instance
            .collection('user')
            .doc(members.get('userEmail'))
            .collection('AppointmentList')
            .doc(dalddongId)
            .set({
          'scheduleId': dalddongId,
          'title':
          "${value.get('hostName')} 외 ${dalddongMembers.length}명 과의 ${value.get('LunchOrDinner') == true ? '점심' : '저녁'}",
          'startDate': dalddongDate,
          'endDate': dalddongDate,
          'isAllDay': false,
          'isAppointment': true,
          'color': value.get('Color'),
          'alarm': 1440, // TODO: 기본 하루 전 알람
        });

        // 달똥참가 인원의 BlockDate 추가
        DateTime blockDate = dalddongDate;
        FirebaseFirestore.instance
            .collection('user')
            .doc(members.get('userEmail'))
            .collection('BlockDatesList')
            .doc("$blockDate")
            .set({
          'LunchOrDinner': value.get('LunchOrDinner'),
          'isDalddong': true,
        });
      });
    });
  });

}

Future<String> addDalddongVoteList(
    List<QueryDocumentSnapshot> dalddongMembers, List<DateTime> voteList, bool dalddongLunch, int starRating) async {
  String dalddongId = generateRandomString(15);
  final pushManager = PushManager();

  List<String> membersEmail = [];
  dalddongMembers.forEach((element) {
    membersEmail.add(element.get('userEmail'));
  });

  // My DB
  String? myName;

  var color = dalddongLunch  == true ? // lunch
        starRating == 1 ? "0xFFFFECB3"
      : starRating == 2 ? "0xFFFFE082"
      : starRating == 3 ? "0xFFFFD54F"
      : starRating== 4 ? "0xFFFFCA28"
      : "0xFFFFC107"
      :  starRating == 1 ? "0xFFC5CAE9"
      : starRating == 2 ? "0xFF9FA8DA"
      : starRating == 3 ? "0xFF7986CB"
      : starRating== 4 ? "0xFF5C6BC0"
      : "0xFF3F51B5";

  await SharedPreferences.getInstance().then((value) {
    SharedPreferences prefs = value;
    myName = prefs.getString('userName');

    // Main Dalddong List DB
    FirebaseFirestore.instance.collection('DalddongList').doc(dalddongId).set({
      'DalddongDate': null,
      'hostName': myName,
      'LunchOrDinner':
      dalddongLunch == true ? 0 : 1,
      'Color': color,
      'DalddongId': dalddongId,
      'Importance': starRating,
      'CreateTime': DateTime.now(),
      'ExpiredTime': DateTime.now().add(const Duration(hours: 24)),
      'dalddongMembers': FieldValue.arrayUnion(membersEmail),
      'MemberNumbers': dalddongMembers.length,
      'voteDates': FieldValue.arrayUnion(voteList),
      'isAllConfirmed': false
    });
    print("done insert main dalddong list to db");



    // Member 개인DB에 저장
    dalddongMembers.forEach((value) {
      // DalddongList Members에 저장 & 수락/거절 표시 field 생성
      FirebaseFirestore.instance
          .collection('DalddongList')
          .doc(dalddongId)
          .collection("Members")
          .doc(value['userEmail'])
          .set({
        'userName': value['userName'],
        'userEmail': value['userEmail'],
        'userImage': value['userImage'],
        'currentStatus': 0,
      });
      print('${value['userName']} 를 Members에 추가 완료');
    });
  });

  return dalddongId;
}

// Suggest Dalddong Schedule
String addDalddongList(
    BuildContext context, List<QueryDocumentSnapshot> dalddongMembers) {
  String DalddongId = generateRandomString(10);
  final pushManager = PushManager();

  List<String> membersEmail = [];
  dalddongMembers.forEach((element) {
    membersEmail.add(element.get('userEmail'));
  });

  // My DB
  String? myName;
  String? myImage;
  String? myEmail;

  var color = context.read<DalddongProvider>().DalddongLunch  == true ? // lunch
                  context.read<DalddongProvider>().starRating == 1 ? "0xFFFFECB3"
                  : context.read<DalddongProvider>().starRating == 2 ? "0xFFFFE082"
                  : context.read<DalddongProvider>().starRating == 3 ? "0xFFFFD54F"
                  : context.read<DalddongProvider>().starRating == 4 ? "0xFFFFCA28"
                  : "0xFFFFC107"
              :   context.read<DalddongProvider>().starRating == 1 ? "0xFFC5CAE9"
                  : context.read<DalddongProvider>().starRating == 2 ? "0xFF9FA8DA"
                  : context.read<DalddongProvider>().starRating == 3 ? "0xFF7986CB"
                  : context.read<DalddongProvider>().starRating == 4 ? "0xFF5C6BC0"
                  : "0xFF3F51B5";

  print(color);
  SharedPreferences.getInstance().then((value) {
    SharedPreferences prefs = value;
    myName = prefs.getString('userName');
    myImage = prefs.getString('userImage');
    myEmail = prefs.getString('userEmail');
    membersEmail.add(myEmail!);

    // Main Dalddong List DB
    FirebaseFirestore.instance.collection('DalddongList').doc(DalddongId).set({
      'DalddongDate': context.read<DalddongProvider>().DalddongDate,
      'hostName': myName,
      'LunchOrDinner':
          context.read<DalddongProvider>().DalddongLunch == true ? 0 : 1,
      'Color': color,
      'DalddongId': DalddongId,
      'Importance': context.read<DalddongProvider>().starRating,
      'CreateTime': DateTime.now(),
      'ExpiredTime': DateTime.now().add(const Duration(hours: 24)),
      'dalddongMembers': FieldValue.arrayUnion(membersEmail),
      'MemberNumbers': dalddongMembers.length,
      'isAllConfirmed': false
    });

    FirebaseFirestore.instance
        .collection('DalddongList')
        .doc(DalddongId)
        .collection("Members")
        .doc(myEmail)
        .set({
          'userName': myName,
          'userEmail': myEmail,
          'userImage': myImage,
          'currentStatus': 2,
    });

    // push myself
    FirebaseFirestore.instance
        .collection('user')
        .doc(myEmail)
        .get()
        .then((pushTokenValue) {
      var userToken = pushTokenValue.get('pushToken');
      var title = "달똥요청 완료";
      var body =
          "${DateFormat('yyyy-MM-dd').format(context.read<DalddongProvider>().DalddongDate)} ${context.read<DalddongProvider>().DalddongLunch == true ? "점심" : "저녁"}을 초대하였습니다.";
      var details = {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': "",
        'eventId': DalddongId,
        'eventType': "DD",
        'membersNum': dalddongMembers.length,
        'hostName': myName,
      };

      pushManager.sendPushMsg(
          userToken: userToken, title: title, body: body, details: details);

    });

    // Member 개인DB에 저장
    dalddongMembers.forEach((value) {
      // DalddongList Members에 저장 & 수락/거절 표시 field 생성
      FirebaseFirestore.instance
          .collection('DalddongList')
          .doc(DalddongId)
          .collection("Members")
          .doc(value['userEmail'])
          .set({
        'userName': value['userName'],
        'userEmail': value['userEmail'],
        'userImage': value['userImage'],
        'currentStatus': 0,
      });

      FirebaseFirestore.instance
          .collection('user')
          .doc(value['userEmail'])
          .get()
          .then((pushTokenValue) {
        var userToken = pushTokenValue.get('pushToken');
        var title = "달똥요청";
        var body =
            "${DateFormat('yyyy-MM-dd').format(context.read<DalddongProvider>().DalddongDate)} ${context.read<DalddongProvider>().DalddongLunch == true ? "점심" : "저녁"}에 초대되었습니다.";
        var details = {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': "",
          'eventId': DalddongId,
          'eventType': "DD",
          'membersNum': dalddongMembers.length,
          'hostName': myName,
        };

        pushManager.sendPushMsg(
            userToken: userToken, title: title, body: body, details: details);

      });
    });
  });

  return DalddongId;
}

// Register Dalddong Schedule
void completeDalddongSchedule(
    String? dalddongId, List<dynamic> dalddongMembers) {
  final pushManager = PushManager();

  dalddongMembers.forEach((element) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(element)
        .get()
        .then((userValue) {
      FirebaseFirestore.instance
          .collection('DalddongList')
          .doc(dalddongId)
          .get()
          .then((dalddongValue) {
        var pushToken = userValue.get('pushToken');
        var title = "달똥 매칭 완료!";
        Timestamp dalddongDate = dalddongValue.get('DalddongDate');
        var body =
            "'${dalddongValue.get('hostName')}'의 '${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(dalddongDate.seconds * 1000))}' "
            "의 ${dalddongValue.get('LunchOrDinner') == 0 ? '점심' : '저녁'}의 약속이 매칭되었습니다.";

        var details = {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': dalddongId,
          'eventId': dalddongId,
          'eventType': "CDD",
          'membersNum': dalddongMembers.length,
          'hostName': dalddongValue.get('hostName'),
        };

        pushManager.sendPushMsg(
            userToken: pushToken, title: title, body: body, details: details);

        // print(element[''])
        FirebaseFirestore.instance
            .collection('user')
            .doc(element)
            .collection('AlarmList')
            .doc(dalddongId)
            .set({
          'details': details,
          'alarmTime': DateTime.now(),
          'body': "'${dalddongValue.get('hostName')}'의 '${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(dalddongDate.seconds * 1000))}' "
              "의 ${dalddongValue.get('LunchOrDinner') == 0 ? '점심' : '저녁'}의 약속이 매칭되었습니다.",
        });

        // Register Dalddong Schedule at calendar
        FirebaseFirestore.instance
            .collection('user')
            .doc(userValue.get('userEmail'))
            .collection('AppointmentList')
            .doc(dalddongId)
            .set({
          'scheduleId': dalddongId,
          'title':
              "${dalddongValue.get('LunchOrDinner') == 0 ? '점심' : '저녁'} 달똥",
          'startDate': dalddongValue.get('DalddongDate'),
          'endDate': dalddongValue.get('DalddongDate'),
          'isAllDay': false,
          'isAppointment': true,
          'color': dalddongValue.get('Color'),
          'alarm': 1440, // TODO:기본 하루 전 알람
        });

        // 달똥참가 인원의 BlockDate 추가
        String blockDate =
            DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(dalddongDate.seconds * 1000));

        List<DateTime> blockDates = [];
        FirebaseFirestore.instance
            .collection('user')
            .doc(userValue.get('userEmail'))
            .collection('BlockDatesList')
            .get()
            .then((value) {
          bool isExistBlocked = false;
          value.docs.forEach((element) {
            if (element.id == blockDate) {
              isExistBlocked = true;
              return;
            }
          });

          FirebaseFirestore.instance
              .collection('user')
              .doc(userValue.get('userEmail'))
              .collection('BlockDatesList')
              .doc(blockDate)
              .set({
            'LunchOrDinner':
                isExistBlocked ? 2 : dalddongValue.get('LunchOrDinner'),
            'isDalddong': true,
          });
        });
      });
    });
  });
}


List<DateTime> getBlockDatesList(List<QueryDocumentSnapshot>? dalddongMembers)  {

  List<DateTime> blockedDates = [];

  print("getBlockDates Start");
  dalddongMembers?.forEach((element) {
    // get BlockDatesList among members
    FirebaseFirestore.instance
        .collection('user')
        .doc(element.get('userEmail'))
        .collection('BlockDatesList') //.where('isDalddong', isEqualTo: true)
        .snapshots()
        .forEach((blockedCollection) {
      blockedCollection.docs.forEach((blocked) {
        blockedDates.add(DateTime.parse(blocked.id));
      });
    });
  });
  print("getBlockDates End");

  blockedDates = blockedDates.toSet().toList();
  return blockedDates;
}

List<DateTime> getVoteDates(List<QueryDocumentSnapshot>? dalddongMembers, List<DateTime> blockedDates)  {

  List<DateTime> voteDates = [];
  int addedDate = 1;

  print("getVoteDates Start");
  while (true) {
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime candidateDate = today.add(Duration(days: addedDate));
    if (blockedDates.contains(candidateDate) == false) {
      voteDates.add(candidateDate);
    }
    if(voteDates.length == 5){
      break;
    }
    else {
      addedDate += 1;
    }
  }
  print("getVoteDates End");

  return voteDates;
}