import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:http/http.dart' as http;

class PushManager {
  // TODO: Firebase 서버키 (테스트용)

  final String _serverKey = "AAAAbeX5jEg:APA91bGaJ5nENJrkxDPJy9xgKQXxNjO5oC3kngCquCdY7ZUg37Y4q3lU-bS-aspnErEdlt5DP2tDeUX4oO5W8JvilMu-mnbmzvqL1fFiXtSLo_dY1LRhz1XOvEkiLhE4TY-KmxjHNvtL";

  // 푸쉬 알람
  Future<void> sendPushMsg({
    required String userToken,
    required String title,
    required String body,
    required Map details,
  }) async {

    final http.Response response;

    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    try {
      response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$_serverKey'
          },
          body: jsonEncode({
            'notification': {'title': title, 'body': body, 'sound': 'false'},
            'ttl': '60s',
            "content_available": true,
            'data': details,
            // 상대방 토큰 값, to -> 단일, registration_ids -> 여러명
            'to': userToken
            // 'registration_ids': tokenList
          }));
    } catch (e) {
      print('error $e');
    }
  }

  // 로컬알람
  Future<void> registerLocalNotification({
    required String title,
    required String body,
    required DateTime alarmTime,
  }) async {

    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }

    final bool? result;
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final int notiId = alarmTime.year + alarmTime.month + alarmTime.day + alarmTime.hour + alarmTime.minute;

    if(Platform.isAndroid){
      result = true;
    }
    else{
      result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true
      );
    }
    // Notification Option 생성
    var android = AndroidNotificationDetails(
        '$notiId',
        title,
        channelDescription: "This channel is for schedule alarm",
        importance: Importance.high,
        priority: Priority.high
    );
    var ios = const DarwinNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);

    // 권한이 true 이면 local Notification 실행
    if(result == true){
      try{
        // 해당 id로 존재하던 알람 삭제
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.deleteNotificationChannelGroup('$notiId');

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notiId, // Id
          title, // title
          body,  // description
          _setNotiTime(alarmTime), // alarm time
          detail,  // Notification Details
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );

        print(_setNotiTime(alarmTime));

      }catch(e){
        if (kDebugMode) {
          print("Local Notification Error with -- '$e'");
        }
      }
    }
  }

  tz.TZDateTime _setNotiTime(DateTime alarmTime){
    tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    var alarmDateTime = tz.TZDateTime.from(alarmTime, tz.getLocation('Asia/Seoul'));

    return alarmDateTime;
  }
}