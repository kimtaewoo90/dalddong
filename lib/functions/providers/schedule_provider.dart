
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

List<QueryDocumentSnapshot> initialDdFriends = [];
int _initialStarRating = 5;

int _initialComparedYear = DateTime.now().year;
int _initialComparedMonth = DateTime.now().month;

class AppointmentProviderArchive extends ChangeNotifier{

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

  int _comparedYear = _initialComparedYear;
  int get comparedYear => _comparedYear;

  int _comparedMonth = _initialComparedMonth;
  int get comparedMonth => _comparedMonth;

  void changeComparedDate(DateTime startDate){
    _comparedYear = startDate.year;
    _comparedMonth = startDate.month;
  }

  void resetAllList(){
    _newDdFriends = [];
    notifyListeners();
  }
}