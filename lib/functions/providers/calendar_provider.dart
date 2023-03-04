// import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final DateTime initialStartTime = DateTime.now().add(const Duration(hours : 1));
final DateTime initialEndTime =  DateTime.now().add(const Duration(hours : 3));
final DateTime initialAlarm = DateTime.now().subtract(const Duration(minutes: 10));
const int initialAlarmMins = 10;
const bool initialAllDay = false;
const bool initialAppointment = false;
const String initialTitle = "";

class FromToProvider with ChangeNotifier{

  DateTime _startTime = initialStartTime;
  DateTime get startTime => _startTime;

  DateTime _endTime = initialEndTime;
  DateTime get endTime => _endTime;

  DateTime _alarmTime = initialAlarm;
  DateTime get alarmTime => _alarmTime;

  int _alarmMins = initialAlarmMins;
  int get alarmMins => _alarmMins;

  bool _isAllDay = initialAllDay;
  bool get isAllday => _isAllDay;

  bool _isAppointment = initialAppointment;
  bool get isAppointment => _isAppointment;

  String _title = initialTitle;
  String get title => _title;

  void changeTitle(String text){
    _title = text;
    notifyListeners();
  }

  void changeStartDate(DateTime dateTime){

    _startTime = dateTime;
    _endTime = dateTime;
    notifyListeners();
  }

  void changeEndDate(DateTime dateTime){
    _endTime = dateTime;
    notifyListeners();
  }

  void changeStartTime(DateTime time){
    _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, time.hour, time.minute);
    notifyListeners();
  }

  void changeEndTime(DateTime time){
    _endTime = DateTime(_endTime.year, _endTime.month, _endTime.day, time.hour, time.minute);
    notifyListeners();
  }

  void changeAlarmTime(int minutes){
    _alarmTime = _startTime.subtract(Duration(minutes: minutes));
    notifyListeners();
  }

  void changeAlarmMins(int alarmMins){
    _alarmMins = alarmMins;
    notifyListeners();
  }

  void changeIsAllDay(bool value) async{
    _isAllDay = value;
    notifyListeners();
  }

  void changeIsAppointment(bool value){
    _isAppointment = value;
    notifyListeners();
  }

  void resetAllData(){
    _startTime = initialStartTime;
    _endTime = initialEndTime;
    _isAllDay = initialAllDay;
    _isAppointment = initialAppointment;
    _alarmMins = initialAlarmMins;
    _alarmTime = initialAlarm;
    _title = initialTitle;
  }
}

const String initialColor = "0xff025645";

class ColorProvider with ChangeNotifier{
  String _color = initialColor;
  String get color => _color;

  void changeColor(String selectedColor){
    _color = selectedColor;
    notifyListeners();
  }
}



// class Meeting {
//   Meeting(this.scheduleId, this.eventName, this.from, this.to, this.background,
//       this.isAllDay, this.isAppointment);
//
//   String scheduleId;
//   String eventName;
//   DateTime from;
//   DateTime to;
//   String background;
//   bool isAllDay;
//   bool isAppointment;
// // bool isDalddong;
// // int alarmMins;
// }

List<String> initialBlockDates = [];
List<dynamic> initialAppointmentDetails = [];
bool initialShowAgenda = false;
class ScheduleProvider with ChangeNotifier{

  List<String> _blockDates = initialBlockDates;
  List<String> get blockDates => _blockDates;
  void setInitialBlockDate(List<String> values){
    initialBlockDates = values;
  }
  void changeBlockDates(String date){
    if(_blockDates.contains(date)){
      _blockDates.removeAt(_blockDates.indexOf((date)));
    }
    else{
      _blockDates.add(date);
    }
    notifyListeners();
  }

  List<dynamic> _appointmentDetails = initialAppointmentDetails;
  List<dynamic> get appointmentDetails => _appointmentDetails;
  void changeAppointmentDetails(List<dynamic> details){
    _appointmentDetails = details;
    notifyListeners();
  }

  bool _showAgenda = initialShowAgenda;
  bool get showAgenda => _showAgenda;
  void changeShowAgenda(bool value){
    _showAgenda = value;
    notifyListeners();
  }

  void resetAllScheduleData(){
    _blockDates = initialBlockDates;
    notifyListeners();
  }
}

final DateTime initialDalddongProvider = DateTime.now();
const bool initialDalddongLunchProvider = true;
const bool initialDalddongDinnerProvider = false;
const int initialLunchOrDinner = 0;

List<QueryDocumentSnapshot> initialDdFriends = [];
int _initialStarRating = 5;

class DalddongProvider with ChangeNotifier{


  void initialAllData(){
    _DalddongDate = initialDalddongProvider;
    _DalddongLunch = initialDalddongLunchProvider;
    _DalddongDinner = initialDalddongDinnerProvider;

  }

  DateTime _DalddongDate = initialDalddongProvider;
  DateTime get DalddongDate => _DalddongDate;

  void changeDalddongDate(DateTime date){
    _DalddongDate = date;
    notifyListeners();
  }

  bool _DalddongLunch = initialDalddongLunchProvider;
  bool get DalddongLunch => _DalddongLunch;

  void changeDalddongLunch(bool value){
    _DalddongLunch = value;
    notifyListeners();
  }

  bool _DalddongDinner = initialDalddongDinnerProvider;
  bool get DalddongDinner => _DalddongDinner;

  void changeDalddongDinner(bool value){
    _DalddongDinner = value;
    notifyListeners();
  }

  int _lunchOrDinner = initialLunchOrDinner;
  int get lunchOrDinner => _lunchOrDinner;
  void changeLunchOrDinner(int value){
    _lunchOrDinner = value;
    notifyListeners();
  }


  List<QueryDocumentSnapshot> _newDdFriends = initialDdFriends;
  List<QueryDocumentSnapshot> get newDdFriends => _newDdFriends;

  void changeNewDdFriends(QueryDocumentSnapshot eachUser){
    final isChecked = _newDdFriends.contains(eachUser);
    if (isChecked){
      _newDdFriends.remove(eachUser);
    } else {
      _newDdFriends.add(eachUser);
    }
    notifyListeners();
  }

  int _starRating = _initialStarRating;
  int get starRating => _starRating;

  void changeStarRating(int value){
    _starRating = value;
  }

  void resetAllProvider(){
    _newDdFriends = [];
    _starRating = _initialStarRating;
    _DalddongLunch = initialDalddongLunchProvider;
    _DalddongDinner = initialDalddongDinnerProvider;
    notifyListeners();
  }
}
