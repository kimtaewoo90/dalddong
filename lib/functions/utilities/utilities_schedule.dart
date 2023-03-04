/*
  - selectStartDate
  - selectEndDate
  - showStartTime
  - showEndTime
  - showSelectColorModal
*/
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:provider/provider.dart';

import '../../commonScreens/config.dart';
import '../providers/calendar_provider.dart';
import 'Utility.dart';


void selectStartDate(BuildContext context) {
  Future<DateTime?> selectedStartDate = showDatePicker(
    context: context,
    initialDate: context.read<FromToProvider>().startTime, //초기값
    firstDate: DateTime(2022), //시작일
    lastDate:DateTime(2100), //마지막일
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light(), //다크 테마
        child: child!,
      );
    },
  );
  selectedStartDate.then((dateTime) {
    if(dateTime != null) {
      context.read<FromToProvider>().changeStartDate(dateTime);
    }
    // context.read<FromToProvider>().changeEndDate(dateTime);
  });
}

void selectEndDate(BuildContext context) {
  Future<DateTime?> selectEndDate = showDatePicker(
    context: context,
    initialDate: context.read<FromToProvider>().startTime, //초기값
    firstDate: DateTime(2022), //시작일
    lastDate:DateTime(2100), //마지막일
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light(), //다크 테마
        child: child!,
      );
    },
  );
  selectEndDate.then((dateTime) {
    if(dateTime != null) {
      context.read<FromToProvider>().changeEndDate(dateTime);
    }
  });
}

void showStartTime(BuildContext context){
  showDialog(
      context: context,
      builder: (context){
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),

            child: TimePickerSpinner(
              spacing: 30,
              minutesInterval: 5,
              is24HourMode: false,
              isForce2Digits: true,
              onTimeChange: (time) {
                context.read<FromToProvider>().changeStartTime(time);
                context.read<FromToProvider>().changeEndTime(time.add(const Duration(hours: 2)));
              },
            ),
          ),
        );
      });
}

void showEndTime(BuildContext context){
  showDialog(
      context: context,
      builder: (context){
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),

            child: TimePickerSpinner(
              spacing: 30,
              minutesInterval: 5,
              is24HourMode: false,
              isForce2Digits: true,
              onTimeChange: (time) {
                context.read<FromToProvider>().changeEndTime(time);
              },
            ),
          ),
        );
      });
}

Future showSelectColorModal(BuildContext mainContext) {
  return showModalBottomSheet(
      context: mainContext,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter mainState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )),
                child: BlockPicker(
                  pickerColor:
                  Color(int.parse(context.read<ColorProvider>().color)),
                  onColorChanged: (Color color) {
                    // print(color);
                    try {
                      context.read<ColorProvider>().changeColor(color
                          .toString()
                          .substring(35, color.toString().length - 2));
                      Navigator.pop(context);
                    } catch (e) {
                      showAlertDialog(context, e.toString());
                    }
                  },
                ),
              );
            });
      });
}

