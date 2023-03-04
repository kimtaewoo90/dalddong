import 'dart:math';

// firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:firebase_auth/firebase_auth.dart';

// flutter
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// packages
import 'package:nb_utils/nb_utils.dart';

// provider
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

// common functions
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/providers/calendar_provider.dart';
import '../../functions/pushManager/push_manager.dart';
import '../../functions/utilities/Utility.dart';

// utility
import '../../functions/utilities/utilities_schedule.dart';

class RegistrationSchedule extends StatefulWidget {
  final bool isModify;

  const RegistrationSchedule({Key? key, required this.isModify})
      : super(key: key);

  @override
  State<RegistrationSchedule> createState() => _RegistrationSchedule();
}

class _RegistrationSchedule extends State<RegistrationSchedule> {
  late bool isClickStartTime;
  late bool isClickEndTime;
  late String selectedColor;

  @override
  void initState() {
    super.initState();

    isClickStartTime = false;
    isClickEndTime = false;
    selectedColor = "0xff025645";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FromToProvider>().resetAllData();
    });
  }

  final textFieldController = TextEditingController();

  Future<void> saveAppointment(DateTime startDate, DateTime endDate,
      bool isAllDay, bool isAppointment, String color, int alarmMins) async {
    // schedule id random generator
    final String scheduleId = generateRandomString(10);
    final tz.TZDateTime scheduleStartDate = tz.TZDateTime.from(
      startDate,
      tz.getLocation('Asia/Seoul'),
    );
    final tz.TZDateTime scheduleEndDate = tz.TZDateTime.from(
      endDate,
      tz.getLocation('Asia/Seoul'),
    );
    final prefs = await SharedPreferences.getInstance();
    var phoneNumber = prefs.getString('phoneNumber');

    var r = Random();
    var localNotificationId = int.parse(
        phoneNumber!.substring(3, 7).toString() + r.nextInt(100).toString());

    // DB 저장
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('AppointmentList')
        .doc(scheduleId)
        .set({
      'scheduleId': scheduleId,
      'title':
          textFieldController.text == "" ? "제목없음" : textFieldController.text,
      'startDate': scheduleStartDate,
      'endDate': scheduleEndDate,
      'isAllDay': isAllDay,
      'isAppointment': isAppointment,
      'color': color,
      'alarmMins': alarmMins, // DateTime 형식으로 입력
      'localNotificationId': localNotificationId,
      'updateTime': DateTime.now(),
    });

    // print(scheduleStartDate.subtract(Duration(minutes: alarmMins)));
    final pushManager = PushManager();
    var alarmDateTime =
        scheduleStartDate.subtract(Duration(minutes: alarmMins));

    // register local push Notification
    await pushManager.registerLocalNotification(
      title:
          "${scheduleStartDate.month}-${scheduleStartDate.day} ${scheduleStartDate.hour}:${scheduleStartDate.minute} 일정",
      body: textFieldController.text,
      alarmTime: alarmDateTime,
    );
  }

  // Alarm Modal bottom sheet
  Future showSelectAlarmModal(BuildContext mainContext) {


    return showModalBottomSheet(
      context: mainContext,
      builder: (BuildContext context) {

        bool? isChecked_10 =
        context.read<FromToProvider>().alarmMins == 10 ? true : false;
        bool? isChecked_60 =
        context.read<FromToProvider>().alarmMins == 60 ? true : false;
        bool? isChecked_1440 =
        context.read<FromToProvider>().alarmMins == 1440 ? true : false;

        return StatefulBuilder(
            builder: (BuildContext context, StateSetter mainState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.4,
                color: Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      )),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // const Text('Modal BottomSheet'),

                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: CheckboxListTile(
                              title: const Text("한시간 전"),
                              activeColor: GeneralUiConfig.floatingBtnColor,
                              // controlAffinity: ListTileControlAffinity.leading,
                              value: isChecked_60,
                              onChanged: (bool? value) {
                                context.read<FromToProvider>().changeAlarmMins(60);
                                mainState(() {
                                  setState(() {
                                    isChecked_60 = value;
                                  });
                                });
                              },
                            )),
                        const SizedBox(
                          height: 10,
                        ),

                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: CheckboxListTile(
                              title: const Text("10분 전"),
                              activeColor: GeneralUiConfig.floatingBtnColor,
                              // controlAffinity: ListTileControlAffinity.leading,
                              value: isChecked_10,
                              onChanged: (bool? value) {
                                context.read<FromToProvider>().changeAlarmMins(10);
                                mainState(() {
                                  setState(() {
                                    isChecked_10 = value;
                                  });
                                });
                              },
                            )),
                        const SizedBox(
                          height: 10,
                        ),

                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: CheckboxListTile(
                              title: const Text("하루 전"),
                              activeColor: GeneralUiConfig.floatingBtnColor,
                              // controlAffinity: ListTileControlAffinity.leading,
                              value: isChecked_1440,
                              onChanged: (bool? value) {
                                context
                                    .read<FromToProvider>()
                                    .changeAlarmMins(1440);
                                mainState(() {
                                  setState(() {
                                    isChecked_1440 = value;
                                  });
                                });
                              },
                            )),
                        const SizedBox(
                          height: 10,
                        ),

                        ElevatedButton(
                          child: const Text('저장'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var startDate = context.watch<FromToProvider>().startTime;
    var endDate = context.watch<FromToProvider>().endTime;
    var selectedColor = context.watch<ColorProvider>().color;

    var alarmMins = context.watch<FromToProvider>().alarmMins;
    var isAllDay = context.watch<FromToProvider>().isAllday;

    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
        title: "일정등록",
        backBtn: true,
        center: false,
        isCreateChatRoom: false,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 10,
            width: MediaQuery.of(context).size.width - 10,
            child: Container(
              padding: const EdgeInsets.all(23),
              child: Column(
                children: [
                  // 제목입력
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '제목을 입력하세요',
                    ),
                    controller: textFieldController,

                    // TextStyle: Alignment.center,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // AllDay Switch
                  Row(
                    children: [
                      Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Icon(Icons.access_time)),
                      const SizedBox(
                        width: 10,
                      ),
                      // AllDay 스위치
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(10.0),
                        alignment: Alignment.center,
                        child: const Text(
                          "하 루 종 일",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Flexible(
                          fit: FlexFit.tight,
                          child: SizedBox(
                            width: 50,
                          )),
                      Switch(
                        value: context.read<FromToProvider>().isAllday,
                        onChanged: (value) {
                          context.read<FromToProvider>().changeIsAllDay(value);
                        },
                        activeColor: Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // DatePicker Row
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          selectStartDate(context);
                        },
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width / 2 - 70,
                          alignment: Alignment.center,
                          child: Text(
                            '${startDate.year.toString().padLeft(2, '0')}-'
                            '${startDate.month.toString().padLeft(2, '0')}-'
                            '${startDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          selectEndDate(context);
                        },
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width / 2 - 70,
                          alignment: Alignment.center,
                          child: Text(
                            '${endDate.year.toString().padLeft(2, '0')}-'
                            '${endDate.month.toString().padLeft(2, '0')}-'
                            '${endDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 1,
                  ),

                  // TimePicker Row
                  if (isAllDay == false)
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: const Icon(Icons.arrow_forward),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                if (isClickStartTime == false) {
                                  isClickStartTime = true;
                                  isClickEndTime = false;
                                  showStartTime(context);
                                } else {
                                  isClickStartTime = false;
                                  showStartTime(context);
                                }
                              },
                              child: Container(
                                height: 40,
                                margin: const EdgeInsets.all(10.0),
                                padding: const EdgeInsets.all(10.0),
                                width:
                                    MediaQuery.of(context).size.width / 2 - 70,
                                alignment: Alignment.center,
                                child: Text(
                                  '${startDate.hour.toString().padLeft(2, '0')}:'
                                  '${startDate.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (isClickEndTime == false) {
                                  isClickEndTime = true;
                                  isClickStartTime = false;
                                  showEndTime(context);
                                } else {
                                  isClickEndTime = false;
                                  showEndTime(context);
                                }
                              },
                              child: Container(
                                height: 40,
                                margin: const EdgeInsets.all(10.0),
                                padding: const EdgeInsets.all(10.0),
                                width:
                                    MediaQuery.of(context).size.width / 2 - 70,
                                alignment: Alignment.center,
                                child: Text(
                                  '${endDate.hour.toString().padLeft(2, '0')}:'
                                  '${endDate.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(
                    height: 1,
                  ),

                  // 색상선택
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: CircleAvatar(
                            backgroundColor: Color(
                          int.parse(selectedColor),
                        )),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width / 2 - 50,
                          child: TextButton(
                            onPressed: () {
                              // show_colors(context, selectedColor);
                              showSelectColorModal(context);
                            },
                            child: Text(
                              selectedColor,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  // Alarm
                  Row(
                    children: [
                      Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: const Icon(Icons.alarm)),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width / 2 - 50,
                          child: TextButton(
                            onPressed: () {
                              // alarmDialog(alarmMins);
                              showSelectAlarmModal(context);
                            },
                            child: textForAlarm(alarmMins),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Material(
            color: Colors.grey,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const SizedBox(
                height: kToolbarHeight,
                width: 100,
                child: Center(
                  child: Text(
                    '취소',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              child: Material(
            color: Colors.black,
            child: InkWell(
              onTap: () async {
                await saveAppointment(
                  context.read<FromToProvider>().startTime,
                  context.read<FromToProvider>().endTime,
                  context.read<FromToProvider>().isAllday,
                  context.read<FromToProvider>().isAppointment,
                  context.read<ColorProvider>().color.toString(),
                  context.read<FromToProvider>().alarmMins,
                );

                Fluttertoast.showToast(
                  msg: '저장되었습니다!',
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: GeneralUiConfig.floatingBtnColor,
                  fontSize: 20,
                  textColor: Colors.black,
                  toastLength: Toast.LENGTH_SHORT,
                );

                if(context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const SizedBox(
                height: kToolbarHeight,
                width: double.infinity,
                child: Center(
                  child: Text(
                    '저장',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget textForAlarm(mins) {
    switch (mins) {
      case 10:
        return const Text("10분 전");
      case 60:
        return const Text("1시간 전");
      case 1440:
        return const Text("하 루 전");

      default:
        return const Text("10분 전");
    }
  }
}
