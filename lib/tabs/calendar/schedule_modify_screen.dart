// firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// flutter
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// provider
import 'package:provider/provider.dart';

// common functions
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/providers/calendar_provider.dart';
import '../../functions/utilities/utilities_schedule.dart';

// screens
import 'calendar_main_screen.dart';



class ModifyDeleteSchedule extends StatefulWidget {
  final Meeting meetingData;

  const ModifyDeleteSchedule({Key? key, required this.meetingData})
      : super(key: key);

  @override
  State<ModifyDeleteSchedule> createState() => _ModifyDeleteSchedule();
}

class _ModifyDeleteSchedule extends State<ModifyDeleteSchedule> {
  bool isDelete = false;

  late bool isClickStartTime;
  late bool isClickEndTime;
  late bool isAppointment;

  TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FromToProvider>().changeIsAllDay(widget.meetingData.isAllDay);
      context.read<FromToProvider>().changeStartDate(widget.meetingData.from);
      context.read<FromToProvider>().changeEndDate(widget.meetingData.to);
      context.read<FromToProvider>().changeStartTime(widget.meetingData.from);
      context.read<FromToProvider>().changeEndTime(widget.meetingData.to);
      // context
      //     .read<FromToProvider>()
      //     .changeAlarmMins(widget.meetingData.alarmMins);
      context.read<ColorProvider>().changeColor(widget.meetingData.background);
    });

    textFieldController = TextEditingController(text: widget.meetingData.eventName);
    isAppointment = widget.meetingData.isAppointment;
    isClickStartTime = false;
    isClickEndTime = false;
  }

  void saveAppointment(DateTime startDate, DateTime endDate, bool isAllDay,
      bool isAppointment, String color, int alarmMins) async {
    final String scheduleId = widget.meetingData.scheduleId;

    // DB 저장
    FirebaseFirestore.instance.collection('user')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('AppointmentList').doc(scheduleId)
        .set({
      'scheduleId': scheduleId,
      'title':
      textFieldController.text == "" ? "제목없음" : textFieldController.text,
      'startDate': startDate,
      'endDate': endDate,
      'isAllDay': isAllDay,
      'isAppointment': isAppointment,
      'color': color,
      'alarm': alarmMins, // DateTime 형식으로 입력
      'updateTime' : DateTime.now(),
    }).onError((error, stackTrace) => print("error modifying document $error"));
  }

  void deleteAppointment() async {
    final String scheduleId = widget.meetingData.scheduleId;

    final user = FirebaseAuth.instance.currentUser;

    FirebaseFirestore.instance
        .collection('user')
        .doc(user!.email)
        .collection('AppointmentList')
        .doc(scheduleId)
        .delete();
  }

  Future showSelectAlarmModal(BuildContext mainContext) {
    bool? isChecked_10 = false;
    bool? isChecked_60 = false;
    bool? isChecked_1440 = false;

    if(context.read<FromToProvider>().alarmMins == 10){
      isChecked_10 = true;
    }
    else if (context.read<FromToProvider>().alarmMins == 60){
      isChecked_60 = true;
    }
    else if (context.read<FromToProvider>().alarmMins == 1440){
      isChecked_1440 = true;
    }
    else{
      isChecked_10 = true;
    }

    return showModalBottomSheet(
      context: mainContext,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter mainState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
                // color: const Color(0xff025645),
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
                              activeColor: const Color(0xff025645),
                              // controlAffinity: ListTileControlAffinity.leading,
                              value: isChecked_60,
                              onChanged: (bool? value) {
                                context.read<FromToProvider>().changeAlarmMins(60);
                                mainState(() {
                                  setState(() {
                                    isChecked_60 = value;
                                    isChecked_10 = false;
                                    isChecked_1440 = false;
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
                              activeColor: const Color(0xff025645),
                              // controlAffinity: ListTileControlAffinity.leading,
                              value: isChecked_10,
                              onChanged: (bool? value) {
                                context.read<FromToProvider>().changeAlarmMins(10);
                                mainState(() {
                                  setState(() {
                                    isChecked_10 = value;
                                    isChecked_60 = false;
                                    isChecked_1440 = false;
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
                              activeColor: const Color(0xff025645),
                              // controlAffinity: ListTileControlAffinity.leading,
                              value: isChecked_1440,
                              onChanged: (bool? value) {
                                context
                                    .read<FromToProvider>()
                                    .changeAlarmMins(1440);
                                mainState(() {
                                  setState(() {
                                    isChecked_10 = false;
                                    isChecked_60 = false;
                                    isChecked_1440 = value;
                                  });
                                });
                              },
                            )),
                        const SizedBox(
                          height: 10,
                        ),

                        ElevatedButton(
                          child: const Text('Done!'),
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
    var alarmMins = context.read<FromToProvider>().alarmMins;
    var isAllDay = context.read<FromToProvider>().isAllday;

    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
        title: "일정수정",
        backBtn: true,
        center: false,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('user')
                .doc(FirebaseAuth.instance.currentUser!.email)
                .collection('AppointmentList')
                .doc(widget.meetingData.scheduleId)
                .snapshots(),
            builder: (context, snapshot) {

              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              alarmMins = snapshot.data?.get('alarmMins');

              return GestureDetector(
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
                                        show_start_times(context);
                                      } else {
                                        isClickStartTime = false;
                                        show_start_times(context);
                                      }
                                    },
                                    child: Container(
                                      height: 40,
                                      margin: const EdgeInsets.all(10.0),
                                      padding: const EdgeInsets.all(10.0),
                                      width: MediaQuery.of(context).size.width / 2 - 70,
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
                                        show_end_times(context);
                                      } else {
                                        isClickEndTime = false;
                                        show_end_times(context);
                                      }
                                    },
                                    child: Container(
                                      height: 40,
                                      margin: const EdgeInsets.all(10.0),
                                      padding: const EdgeInsets.all(10.0),
                                      width: MediaQuery.of(context).size.width / 2 - 70,
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
                              // child: Colors.green,
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
                                    show_colors(context, selectedColor);
                                  },
                                  child: const Text(
                                    "색상선택",
                                    style: TextStyle(
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
                                    context.read<FromToProvider>().changeAlarmMins(alarmMins);
                                    showSelectAlarmModal(context);
                                  },
                                  child: textForAlarm(context.read<FromToProvider>().alarmMins),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
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
                  onTap: () {
                    saveAppointment(
                        context.read<FromToProvider>().startTime,
                        context.read<FromToProvider>().endTime,
                        context.read<FromToProvider>().isAllday,
                        isAppointment,
                        context.read<ColorProvider>().color.toString(),
                        context.read<FromToProvider>().alarmMins);

                    Fluttertoast.showToast(
                      msg: '수정되었습니다!',
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      fontSize: 20,
                      textColor: Colors.white,
                      toastLength: Toast.LENGTH_SHORT,
                    );

                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    height: kToolbarHeight,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        '수정',
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
