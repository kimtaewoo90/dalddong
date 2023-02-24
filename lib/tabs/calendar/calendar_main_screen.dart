// flutter
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// google api
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/calendar/v3.dart' as googleApi;
import 'package:http/http.dart';
import 'package:http/io_client.dart';

// calendar
import 'package:syncfusion_flutter_calendar/calendar.dart';

// location
import 'package:easy_localization/easy_localization.dart';

// firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// provider
import 'package:provider/provider.dart';
import '../../commonScreens/config.dart';
import '../../functions/providers/calendar_provider.dart';

// screens
import 'package:dalddong/dalddongScreens/dalddongRequest/dr_request_screen.dart';
import 'package:dalddong/tabs/calendar/schedule_modify_screen.dart';
import 'package:dalddong/tabs/calendar/schedule_register_screen.dart';
import 'package:dalddong/tabs/chatting/chatting_screen.dart';

// common functions
import '../../commonScreens/page_route_with_animation.dart';
import '../../commonScreens/shared_app_bar.dart';

// utility
import '../../functions/utilities/Utility.dart';

class MySchedule extends StatefulWidget {
  const MySchedule({Key? key}) : super(key: key);

  @override
  State<MySchedule> createState() => _MyScheduleState();
}

class _MyScheduleState extends State<MySchedule> {
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   clientId:
  //       '558204187706-dn98v28j827mdcek1m5msfkcq1sg3bop.apps.googleusercontent.com',
  //   scopes: <String>[
  //     googleApi.CalendarApi.calendarScope,
  //   ],
  // );

  late bool showAgenda;
  late DateTime initialDate;
  late Color backgroundColor;
  late List<DateTime> blackoutDates;
  late List<Meeting> _appointmentDetails;

  @override
  void initState() {
    super.initState();

    // build시 provider 변수 reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().resetAllScheduleData();
    });


    showAgenda = false;
    initialDate = context.read<ScheduleProvider>().initialDate;
    blackoutDates = context.read<ScheduleProvider>().blockDates;
    backgroundColor = context.read<ScheduleProvider>().backgroundColor;
    _appointmentDetails = <Meeting>[];
    // print('initState calendar');

  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      setState(() {
        _appointmentDetails = calendarTapDetails.appointments!.cast<Meeting>();

        if (initialDate != calendarTapDetails.date!) {
          initialDate = calendarTapDetails.date!;
          showAgenda = true;
        } else {
          if (showAgenda == true) {
            showAgenda = false;
          } else {
            showAgenda = true;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('build calendar');
    return WillPopScope(
      onWillPop: () async{
        final value = await yesNoDialog(context, "앱을 종료하십니까?");
        return value ?? true;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          backgroundColor: GeneralUiConfig.backgroundColor,
            appBar: BaseAppBar(
              appBar: AppBar(),
              title: "켈린더",
              backBtn: false,
              center: false,
            ),
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .collection("AppointmentList")
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }

                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('BlockDatesList')
                        .snapshots(),
                    builder: (context, blockSnapshot) {
                      if (blockSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      }

                      List<DateTime> blockDates = [];
                      List<int> lunchOrDinner = [];
                      for (var element in blockSnapshot.data!.docs) {
                        blockDates.add(DateTime.parse(element.id));
                        lunchOrDinner.add(element.get('LunchOrDinner'));
                      }
                      Map<String, int> blockInfo = Map.fromIterables(blockDates, lunchOrDinner);
                      context.read<ScheduleProvider>().setInitialBlockDate(blockDates);


                      return Column(
                        children: [
                          Expanded(
                            child: SfCalendar(
                              view: CalendarView.month,
                              monthViewSettings: const MonthViewSettings(
                                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                                showTrailingAndLeadingDates: false,
                                dayFormat: 'EEE',
                              ),
                              // blackoutDates: blockDates,
                              // blackoutDatesTextStyle: const TextStyle(
                              //     backgroundColor: Colors.grey,
                              //     decoration: TextDecoration.lineThrough
                              // ),

                              initialSelectedDate: initialDate,
                              dataSource: MeetingDataSource(
                                  _getDataSource(snapshot.data!.docs)),
                              monthCellBuilder: (BuildContext buildContext, MonthCellDetails details) {
                          
                                if (blockDates.contains(details.date)) {
                                  // blocked lunch
                                  if(blockInfo[details.date] == 0){
                                    backgroundColor = GeneralUiConfig.blockLunchColor;
                                  }
                                  // blocked dinner
                                  else if (blockInfo[details.date] == 1){
                                    backgroundColor = GeneralUiConfig.blockDinnerColor;
                                  }
                                  // blocked allDay
                                  else{
                                  backgroundColor = GeneralUiConfig.blockAlldayColor;                                
                                  }                              
                                }
                                else{
                                  backgroundColor = GeneralUiConfig.backgroundColor;
                                }                                                             

                                final Color defaultColor =
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black54
                                    : Colors.black54;
                                return Container(
                                  decoration: BoxDecoration(
                                      color: backgroundColor,
                                      border: Border.all(
                                          color: defaultColor, width: 0.5)),
                                  child: Text(
                                    details.date.day.toString(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              },

                              selectionDecoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.blue, width: 2),
                                borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                                shape: BoxShape.rectangle,
                              ),

                              onLongPress: (CalendarLongPressDetails details) async {
                                DateTime date = details.date!;

                                if(!blackoutDates.contains(date)){
                                  final result = await addBlockTypeDialog(context, "달똥요청을 막으시겠어요?");
                                  await FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(FirebaseAuth.instance.currentUser!.email)
                                      .collection('BlockDatesList')
                                      .doc('${details.date}')
                                      .set({
                                    'LunchOrDinner' : result,
                                    'isDalddong' : false,
                                  });
                                }
                                else {
                                  final result = await yesNoDialog(context, '정말 해제하시겠어용?');
                                  if (result == true){
                                    await FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(FirebaseAuth.instance.currentUser!.email)
                                        .collection('BlockDatesList')
                                        .doc('${details.date}')
                                        .delete();
                                  }
                                }
                                setState(() {
                                  context.read<ScheduleProvider>().changeBlockDates(date);
                                });
                              },

                              onTap: calendarTapped,

                            ),
                          ),

                          if (showAgenda)
                            Expanded(
                              child: Container(
                                color: Colors.black12,
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(2),
                                  itemCount: _appointmentDetails.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                      padding: const EdgeInsets.all(2),
                                      height: 60,
                                      color: Color(int.parse(
                                          _appointmentDetails[index].background)),
                                      child: ListTile(
                                        onTap: () async{
                                          if(_appointmentDetails[index].isAppointment == true){
                                            print("달똥완료 페이지로 이동");
                                            // PageRouteWithAnimation pageRoute =
                                            // PageRouteWithAnimation(CompleteAccept(dalddongId: _appointmentDetails[index].scheduleId,));
                                            // Navigator.push(context, pageRoute.slideBottonToTop());
                                            var chatRoomName = await FirebaseFirestore.instance
                                                .collection('user')
                                                .doc(FirebaseAuth.instance.currentUser?.email)
                                                .collection('chatRoomList')
                                                .doc(_appointmentDetails[index].scheduleId).get().then((value) {
                                              return value.get('chatRoomName');
                                            });

                                            PageRouteWithAnimation pageRoute =
                                            PageRouteWithAnimation(ChatScreen(_appointmentDetails[index].scheduleId, chatRoomName));
                                            await Navigator.push(context, pageRoute.slideBottonToTop());

                                          }
                                          else{
                                            PageRouteWithAnimation pageRoute =
                                            PageRouteWithAnimation(ModifyDeleteSchedule(meetingData: _appointmentDetails[index],));
                                            Navigator.push(context, pageRoute.slideBottonToTop());
                                          }
                                        },
                                        leading: Column(
                                          children: <Widget>[
                                            Text(
                                              _appointmentDetails[index].isAllDay
                                                  ? ''
                                                  : DateFormat('hh:mm a').format(
                                                  _appointmentDetails[index]
                                                      .from),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  height: 1.7),
                                            ),
                                            Text(
                                              _appointmentDetails[index].isAllDay
                                                  ? 'All day'
                                                  : '',
                                              style: const TextStyle(
                                                  height: 0.5, color: Colors.white),
                                            ),
                                            Text(
                                              _appointmentDetails[index].isAllDay
                                                  ? ''
                                                  : DateFormat('hh:mm a').format(
                                                  _appointmentDetails[index]
                                                      .to),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                          Icons.add,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                        title: Text(
                                            _appointmentDetails[index].eventName,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white)),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                  const Divider(
                                    height: 5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    });
              },
            ),

            floatingActionButton: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
              child: SpeedDial(
                overlayOpacity: 0.5,
                animatedIcon: AnimatedIcons.menu_close,
                backgroundColor: GeneralUiConfig.floatingBtnColor,
                // icon: Icon(Icons.edit),

                children: [
                  SpeedDialChild(
                      child: const Icon(Icons.search), label: "달똥찾기", onTap: () {}),
                  SpeedDialChild(
                      child: const Icon(Icons.message),
                      label: "달똥등록",
                      onTap: () {
                        PageRouteWithAnimation pageRoute =
                        PageRouteWithAnimation(const RegistrationDalddong());
                        Navigator.push(context, pageRoute.slideBottonToTop());
                      }),
                  SpeedDialChild(
                      child: const Icon(Icons.event_note),
                      label: "일정등록",
                      onTap: () {
                        PageRouteWithAnimation pageRoute =
                        PageRouteWithAnimation(const RegistrationSchedule(isModify: false,));
                        Navigator.push(context, pageRoute.slideBottonToTop());
                      }),
                  SpeedDialChild(
                      child: const Icon(Icons.event_note),
                      label: "권한받기",
                      onTap: () async{
                        NotificationSettings settings =
                        await FirebaseMessaging.instance.requestPermission(
                          alert: true,
                          announcement: true,
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
                      })
                ],
              ),
            )),
      ),
    );
  }

  List<Meeting> _getDataSource(
      List<QueryDocumentSnapshot<Object?>> collection) {
    final List<Meeting> meetings = <Meeting>[];

    for (int index = 0; index < collection.length; index++) {
      meetings.add(Meeting(
        collection[index]['scheduleId'],
        collection[index]["title"],
        collection[index]["startDate"].toDate(),
        collection[index]["endDate"].toDate(),
        collection[index]['color'],
        collection[index]['isAllDay'],
        collection[index]['isAppointment'],
        // collection[index]['alarmMins']
      ));
    }
    return meetings;
  }

// Future<List<googleApi.Event>?> getGoogleEventsData() async {
//   try {
//     print("??????");
//     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//     final GoogleAPIClient httpClient =
//         GoogleAPIClient(await googleUser?.authHeaders);
//
//     final googleApi.CalendarApi calendarAPI =
//         googleApi.CalendarApi(httpClient);
//     final googleApi.Events calEvents = await calendarAPI.events.list(
//       "primary",
//     );
//     final List<googleApi.Event> appointments = <googleApi.Event>[];
//     if (calEvents.items != null) {
//       for (int i = 0; i < calEvents.items!.length; i++) {
//         final googleApi.Event event = calEvents.items![i];
//         if (event.start == null) {
//           continue;
//         }
//         appointments.add(event);
//         print(event.description);
//       }
//     }
//
//     return appointments;
//   } catch (e) {
//     print("Error in getGoogleEventsData : $e");
//
//     return null;
//   }
// }
}


class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return Color(int.parse(appointments![index].background));
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.scheduleId, this.eventName, this.from, this.to, this.background,
      this.isAllDay, this.isAppointment);

  String scheduleId;
  String eventName;
  DateTime from;
  DateTime to;
  String background;
  bool isAllDay;
  bool isAppointment;
// bool isDalddong;
// int alarmMins;
}


// class GoogleAPIClient extends IOClient {
//   final Map<String, String>? _headers;
//
//   GoogleAPIClient(this._headers) : super();
//
//   @override
//   Future<IOStreamedResponse> send(BaseRequest request) =>
//       super.send(request..headers.addAll(_headers!));
//
//   @override
//   Future<Response> head(Uri url, {Map<String, String>? headers}) =>
//       super.head(url, headers: headers!..addAll(_headers!));
// }

// class GoogleDataSource extends CalendarDataSource {
//   GoogleDataSource({required List<googleApi.Event> events}) {
//     appointments = events;
//   }
//
//   DateTime? getStartDateTime(int index) {
//     final googleApi.Event event = appointments![index];
//     // event.start!.date;
//     return event.start!.dateTime;
//   }
//
//   @override
//   bool isAllDay(int index) {
//     return appointments![index].start.date != null;
//   }
//
//   @override
//   DateTime getEndTime(int index) {
//     final googleApi.Event event = appointments![index];
//     return event.endTimeUnspecified != null
//         ? (event.start!.date ?? event.start!.dateTime!.toLocal())
//         : (event.end!.date != null
//             ? event.end!.date!.add(const Duration(days: -1))
//             : event.end!.dateTime!.toLocal());
//   }
//
//   @override
//   String getLocation(int index) {
//     return appointments![index].location;
//   }
//
//   @override
//   String getNotes(int index) {
//     return appointments![index].description;
//   }
//
//   String? getTitle(int index) {
//     final googleApi.Event event = appointments![index];
//     return event.summary == null || event.summary!.isEmpty
//         ? 'No Title'
//         : event.summary;
//   }
// }
