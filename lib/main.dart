// flutter
import 'package:flutter/material.dart';

// firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// localization
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


// notification
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// providers
import 'package:provider/provider.dart';
import 'commonScreens/welcome_screen.dart';
import 'firebase_options.dart';
import 'functions/providers/calendar_provider.dart';
import 'functions/providers/chatroom_provider.dart';
import 'functions/providers/community_provider.dart';
import 'functions/providers/new_message_provider.dart';

// kakao sdk
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart' as kakao;

// Screens
import 'functions/signInUp/signIn/socialSignIn/kakao/kakao_sign_in.dart';
import 'functions/signInUp/signIn/socialSignIn/kakao/kakao_sign_in_model.dart';
import 'main_screen.dart';

// Utility
import 'functions/utilities/Utility.dart';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  print('Handling a background message ${message.messageId}');

  FirebaseFirestore.instance.collection('user')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .collection('AlarmList').doc(message.messageId)
      .set({
    'messageId' : message.messageId,
    'title' : message.notification?.title,
    'body' : message.notification?.body,
    'details' : message.data,
    'alarmTime' : DateTime.now(),
  });
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFirst = true;

void main() async {

  kakao.KakaoSdk.init(nativeAppKey: '7f2a7d94e60d8b127f66b7f43d7d8430');
  WidgetsFlutterBinding.ensureInitialized();

  //firebase 사용시 초기화메소드 (비동기방식으로 초기화)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
      'push notification',    // channel Id
      'push notification to others',  // channel title
      description:
      "This channel is used for push to others",
      importance: Importance.high);

  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = const DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // onSelectNotification :
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // var token = await FirebaseMessaging.instance.getToken();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CommunityProvider()),
          ChangeNotifierProvider(create: (_) => FromToProvider()),
          ChangeNotifierProvider(create: (_) => ColorProvider()),
          ChangeNotifierProvider(create: (_) => ScheduleProvider()),
          ChangeNotifierProvider(create: (_) => DalddongProvider()),
          ChangeNotifierProvider(create: (_) => ChatroomProvider()),
          ChangeNotifierProvider(create: (_) => NewMessageProvider()),
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  // final String token;
  MyApp({Key? key}) : super(key: key);

  String? userInfo = "";

  final kakaoLoginModel = KakaoLoginModel(KaKaoLogin());


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      navigatorKey: GlobalVariable.navState,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true
      ),
      localizationsDelegates: const [
        // AppLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SfGlobalLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      locale: const Locale('ko', 'KR'),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  // final String token;
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state == AppLifecycleState.resumed){
      setActiveStatus(true);
    }
    else{
      setActiveStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {

    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      var androidNotiDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
      );
      var iOSNotiDetails = const DarwinNotificationDetails();

      var details = NotificationDetails(
        android: androidNotiDetails,
        iOS: iOSNotiDetails,
      );

      if(notification != null && android != null){
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            details);
      }

      if(message.data['alarmType'] == "MSG"){
        var chatroomId = message.data['eventId'];
        var chatroomName = message.data['chatroomName'];
        Navigator.of(GlobalVariable.navState.currnetContext!)
        .push(MaterialPageRoute(builder:(context) => ChatScreen(chatroomId, chatroomName),));
      }

 
      // 알람테이블(AlarmList)에 적재
      if(message.data['alarmType'] != "MSG") {
        FirebaseFirestore.instance.collection('user')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('AlarmList').doc(message.messageId)
          .set({
        'messageId' : message.messageId,
        'title' : message.notification?.title,
        'body' : message.notification?.body,
        'details' : message.data,
        'alarmTime' : DateTime.now(),
      });
      }
    });

    // background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      
      // rendering for MSG push
      if(message.data['alarmType'] == "MSG"){
        var chatroomId = message.data['eventId'];
        var chatroomName = message.data['chatroomName'];
        SchedulerBinding.instance!.addPostFrameCallback((_){
          Navigator.of(GlobalVariable.navState.currnetContext!)
        .push(MaterialPageRoute(builder:(context) => ChatScreen(chatroomId, chatroomName),));
        })     
      }

      if(message.data['alarmType'] != "MSG") {
        FirebaseFirestore.instance.collection('user')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection('AlarmList').doc(message.messageId)
            .set({
          'messageId' : message.messageId,
          'title' : message.notification?.title,
          'body' : message.notification?.body,
          'details' : message.data,
          'alarmTime' : DateTime.now(),
        });
      }
    });

    return Scaffold(
      body:  StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData || snapshot.data?.email != null){
            // Main Page.
            return const MainScreen();
          }
          else{
            // Login SignUp page
            return const WelcomeScreen();
          }

        },
      ),
    );
  }
}
