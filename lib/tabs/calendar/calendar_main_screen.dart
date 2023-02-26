// flutter
// firebase
import 'package:cloud_firestore/cloud_firestore.dart';

// screens
import 'package:dalddong/dalddongScreens/dalddongRequest/dr_request_screen.dart';
import 'package:dalddong/tabs/calendar/schedule_modify_screen.dart';
import 'package:dalddong/tabs/calendar/schedule_register_screen.dart';
import 'package:dalddong/tabs/chatting/chatting_screen.dart';

// location
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// provider
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// calendar
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../commonScreens/config.dart';

// common functions
import '../../commonScreens/page_route_with_animation.dart';
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/providers/calendar_provider.dart';

// utility
import '../../functions/utilities/Utility.dart';
import 'bottom_agenda_screen.dart';

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

  bool agenda = false;
  late Color backgroundColor;
  late List<DateTime> blackoutDates;

  final CalendarController _calendarController = CalendarController();
  final panelController = PanelController();


  @override
  void initState() {
    super.initState();

    // build시 provider 변수 reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().resetAllScheduleData();
    });

    _calendarController.selectedDate = DateTime.now();

    blackoutDates = context.read<ScheduleProvider>().blockDates;

    print("initialDate : ${_calendarController.selectedDate}");
  }

  // Alarm Modal bottom sheet
  Future showAgendaDetails(BuildContext mainContext) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: mainContext,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter mainState) {
          return Container(
            color: Colors.black12,
            child: ListView.separated(
              padding: const EdgeInsets.all(2),
              itemCount:
                  context.read<ScheduleProvider>().appointmentDetails.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.all(2),
                  height: 60,
                  color: Color(int.parse(context
                      .read<ScheduleProvider>()
                      .appointmentDetails[index]
                      .background)),
                  child: ListTile(
                    onTap: () async {
                      if (context
                              .read<ScheduleProvider>()
                              .appointmentDetails[index]
                              .isAppointment ==
                          true) {
                        print("달똥완료 페이지로 이동");
                        // PageRouteWithAnimation pageRoute =
                        // PageRouteWithAnimation(CompleteAccept(dalddongId: _appointmentDetails[index].scheduleId,));
                        // Navigator.push(context, pageRoute.slideBottonToTop());
                        var chatRoomName = await FirebaseFirestore.instance
                            .collection('user')
                            .doc(FirebaseAuth.instance.currentUser?.email)
                            .collection('chatRoomList')
                            .doc(context
                                .read<ScheduleProvider>()
                                .appointmentDetails[index]
                                .scheduleId)
                            .get()
                            .then((value) {
                          return value.get('chatRoomName');
                        });

                        PageRouteWithAnimation pageRoute =
                            PageRouteWithAnimation(ChatScreen(
                                context
                                    .read<ScheduleProvider>()
                                    .appointmentDetails[index]
                                    .scheduleId,
                                chatRoomName));
                        await Navigator.push(
                            context, pageRoute.slideBottonToTop());
                      } else {
                        PageRouteWithAnimation pageRoute =
                            PageRouteWithAnimation(ModifyDeleteSchedule(
                          meetingData: context
                              .read<ScheduleProvider>()
                              .appointmentDetails[index],
                        ));
                        Navigator.push(context, pageRoute.slideBottonToTop());
                      }
                    },
                    leading: Column(
                      children: <Widget>[
                        Text(
                          context
                                  .read<ScheduleProvider>()
                                  .appointmentDetails[index]
                                  .isAllDay
                              ? ''
                              : DateFormat('hh:mm a').format(context
                                  .read<ScheduleProvider>()
                                  .appointmentDetails[index]
                                  .from),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.7),
                        ),
                        Text(
                          context
                                  .read<ScheduleProvider>()
                                  .appointmentDetails[index]
                                  .isAllDay
                              ? 'All day'
                              : '',
                          style:
                              const TextStyle(height: 0.5, color: Colors.white),
                        ),
                        Text(
                          context
                                  .read<ScheduleProvider>()
                                  .appointmentDetails[index]
                                  .isAllDay
                              ? ''
                              : DateFormat('hh:mm a').format(context
                                  .read<ScheduleProvider>()
                                  .appointmentDetails[index]
                                  .to),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                    title: Text(
                        context
                            .read<ScheduleProvider>()
                            .appointmentDetails[index]
                            .eventName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                height: 5,
              ),
            ),
          );
        });
      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    // print('build calendar');
    // print(initialDate);

    final panelHeightClosed = MediaQuery.of(context).size.height * 0.0;
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.4;

    return WillPopScope(
      onWillPop: () async {
        final value = await yesNoDialog(context, "앱을 종료하십니까?");
        return value ?? true;
      },
      child: Scaffold(
          backgroundColor: GeneralUiConfig.backgroundColor,
          resizeToAvoidBottomInset: true,
          appBar: BaseAppBar(
            appBar: AppBar(),
            title: "켈린더",
            backBtn: false,
            center: false,
          ),
          // body: _calendar(),
          body: SizedBox(
            // height: 500,
            child: SlidingUpPanel(
                backdropEnabled: false,
                controller: panelController,
                minHeight: panelHeightClosed,
                maxHeight: panelHeightOpen,
                parallaxEnabled: true,
                parallaxOffset: 1,
                panelSnapping: true,
                color: Colors.white,
                // collapsed: _calendar(),
                body: Column(
                  children: [
                    Expanded(
                        child: _calendar(MediaQuery.of(context).size.height - 80)),
                  // child: Container()

                  ],
                ),
              panelBuilder: (controller){
                  return BottomAgenda(
                    controller: controller,
                    panelController: panelController);
                }
            ),
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
                    child: const Icon(Icons.search),
                    label: "달똥찾기",
                    onTap: () {}),
                SpeedDialChild(
                    child: const Icon(Icons.message),
                    label: "달똥등록",
                    onTap: () {
                      PageRouteWithAnimation pageRoute =
                          PageRouteWithAnimation(
                              const RegistrationDalddong());
                      Navigator.push(context, pageRoute.slideBottonToTop());
                    }),
                SpeedDialChild(
                    child: const Icon(Icons.event_note),
                    label: "일정등록",
                    onTap: () {
                      PageRouteWithAnimation pageRoute =
                          PageRouteWithAnimation(const RegistrationSchedule(
                        isModify: false,
                      ));
                      Navigator.push(context, pageRoute.slideBottonToTop());
                    }),
                SpeedDialChild(
                    child: const Icon(Icons.event_note),
                    label: "권한받기",
                    onTap: () async {
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

                      if (settings.authorizationStatus ==
                          AuthorizationStatus.authorized) {
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
          )
      ),
    );
  }

  Widget _calendar(double calendarHeight) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dy < 0) {

          // print("위로 ${panelController.isAttached }");
          if(panelController.isAttached == true){
            panelController.animatePanelToPosition(1);

          }
        }
        if (details.delta.dy > 0) {
          // print("아래로 ${panelController.isAttached }");
          if(panelController.isAttached == true){
            panelController.animatePanelToPosition(0);


            // panelController.open();
          }
        }
      },
      child: StreamBuilder(
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
                  Map<DateTime, int> blockInfo = Map.fromIterables(blockDates, lunchOrDinner);
                  context.read<ScheduleProvider>().setInitialBlockDate(blockDates);

                  print(calendarHeight - panelController.panelPosition);
                  return Column(children: [
                    SizedBox(
                      height: calendarHeight - panelController.panelPosition,
                      child: SfCalendar(
                        controller: _calendarController,
                        onViewChanged:
                            (ViewChangedDetails viewChangedDetails) {
                          SchedulerBinding.instance
                              .addPostFrameCallback((Duration duration) {
                            if (viewChangedDetails.visibleDates.first.year == DateTime.now().year &&
                                viewChangedDetails.visibleDates[0].month == DateTime.now().month) {
                              // _calendarController.selectedDate = DateTime.now();
                            } else {
                              _calendarController.selectedDate = viewChangedDetails.visibleDates[0];
                            }
                          });
                        },
                        view: CalendarView.month,
                        showNavigationArrow: true,
                        showDatePickerButton: true,
                        todayHighlightColor: Colors.red,
                        monthViewSettings: const MonthViewSettings(
                          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                          showTrailingAndLeadingDates: false,
                          dayFormat: 'EEE',
                          navigationDirection: MonthNavigationDirection.horizontal,
                        ),
                        dataSource: MeetingDataSource(_getDataSource(snapshot.data!.docs)),
                        monthCellBuilder: (BuildContext buildContext,
                            MonthCellDetails details) {
                          // Block Date
                          if (blockDates.contains(details.date)) {
                            // blocked lunch
                            if (blockInfo[details.date] == 0) {
                              backgroundColor = GeneralUiConfig.blockLunchColor;
                            }
                            // blocked dinner
                            else if (blockInfo[details.date] == 1) {
                              backgroundColor = GeneralUiConfig.blockDinnerColor;
                            }
                            // blocked allDay
                            else {
                              backgroundColor = GeneralUiConfig.blockAlldayColor;
                            }
                          }
                          // Open Date
                          else {
                            backgroundColor = GeneralUiConfig.backgroundColor;
                          }

                          final Color defaultColor =
                              Theme.of(context).brightness == Brightness.dark
                                  ? GeneralUiConfig.borderDarkModeColor
                                  : GeneralUiConfig.borderWhiteModeColor;
                          return Container(
                            decoration: BoxDecoration(
                                color: backgroundColor,
                                border: Border.all(
                                    color: defaultColor, width: 0.5)),
                            child: Text(
                              details.date.day.toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 10),
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

                        onLongPress:
                            (CalendarLongPressDetails details) async {
                          DateTime date = details.date!;
                          blackoutDates =
                              context.read<ScheduleProvider>().blockDates;

                          if (!blackoutDates.contains(date)) {
                            final result = await addBlockTypeDialog(
                                context, "달똥요청을 막으시겠어요?");
                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(FirebaseAuth
                                    .instance.currentUser!.email)
                                .collection('BlockDatesList')
                                .doc('${details.date}')
                                .set({
                              'LunchOrDinner': result,
                              'isDalddong': false,
                            });
                          } else {
                            final result =
                                await yesNoDialog(context, '정말 해제하시겠어용?');
                            if (result == true) {
                              await FirebaseFirestore.instance
                                  .collection('user')
                                  .doc(FirebaseAuth
                                      .instance.currentUser!.email)
                                  .collection('BlockDatesList')
                                  .doc('${details.date}')
                                  .delete();
                            }
                          }

                          context.read<ScheduleProvider>().changeBlockDates(date);

                          // setState(() {
                          //   context.read<ScheduleProvider>().changeBlockDates(date);
                          // });
                        },
                        onTap: (CalendarTapDetails calendarTapDetails) {

                          _calendarController.selectedDate = calendarTapDetails.date;
                          if (calendarTapDetails.appointments != null) {
                            context.read<ScheduleProvider>()
                                    .changeAppointmentDetails(
                                      calendarTapDetails.appointments!.cast<Meeting>()
                            );
                            setState(() {});
                          }

                          if (calendarTapDetails.date!.month >
                              _calendarController.displayDate!.month) {
                            _calendarController.forward!();
                          }
                          else if(calendarTapDetails.date!.month <
                              _calendarController.displayDate!.month){
                            _calendarController.backward!();
                          }
                        },
                      ),
                    ),

                    // Expanded(child: BottomAgenda()),
                  ]);
                });
          }),
    );
  }
}

List<Meeting> _getDataSource(List<QueryDocumentSnapshot<Object?>> collection) {
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

class ShowBottomAgenda extends StatefulWidget {
  final List<dynamic> details;

  const ShowBottomAgenda({Key? key, required this.details}) : super(key: key);

  @override
  State<ShowBottomAgenda> createState() => _ShowBottomAgendaState();
}

class _ShowBottomAgendaState extends State<ShowBottomAgenda> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: ListView.separated(
        padding: const EdgeInsets.all(2),
        itemCount: context.read<ScheduleProvider>().appointmentDetails.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.all(2),
            height: 60,
            color: Color(int.parse(context
                .read<ScheduleProvider>()
                .appointmentDetails[index]
                .background)),
            child: ListTile(
              onTap: () async {
                if (context
                        .read<ScheduleProvider>()
                        .appointmentDetails[index]
                        .isAppointment ==
                    true) {
                  print("달똥완료 페이지로 이동");

                  var chatRoomName = await FirebaseFirestore.instance
                      .collection('user')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .collection('chatRoomList')
                      .doc(context
                          .read<ScheduleProvider>()
                          .appointmentDetails[index]
                          .scheduleId)
                      .get()
                      .then((value) {
                    return value.get('chatRoomName');
                  });

                  PageRouteWithAnimation pageRoute = PageRouteWithAnimation(
                      ChatScreen(
                          context
                              .read<ScheduleProvider>()
                              .appointmentDetails[index]
                              .scheduleId,
                          chatRoomName));
                  await Navigator.push(context, pageRoute.slideBottonToTop());
                } else {
                  PageRouteWithAnimation pageRoute =
                      PageRouteWithAnimation(ModifyDeleteSchedule(
                    meetingData: context
                        .read<ScheduleProvider>()
                        .appointmentDetails[index],
                  ));
                  Navigator.push(context, pageRoute.slideBottonToTop());
                }
              },
              leading: Column(
                children: <Widget>[
                  Text(
                    context
                            .read<ScheduleProvider>()
                            .appointmentDetails[index]
                            .isAllDay
                        ? ''
                        : DateFormat('hh:mm a').format(context
                            .read<ScheduleProvider>()
                            .appointmentDetails[index]
                            .from),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.7),
                  ),
                  Text(
                    context
                            .read<ScheduleProvider>()
                            .appointmentDetails[index]
                            .isAllDay
                        ? 'All day'
                        : '',
                    style: const TextStyle(height: 0.5, color: Colors.white),
                  ),
                  Text(
                    context
                            .read<ScheduleProvider>()
                            .appointmentDetails[index]
                            .isAllDay
                        ? ''
                        : DateFormat('hh:mm a').format(context
                            .read<ScheduleProvider>()
                            .appointmentDetails[index]
                            .to),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
              title: Text(
                  context
                      .read<ScheduleProvider>()
                      .appointmentDetails[index]
                      .eventName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          height: 5,
        ),
      ),
    );
  }
}
