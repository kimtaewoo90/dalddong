// import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';


List<QueryDocumentSnapshot> initialMsgFriends = [];

class NewMessageProvider extends ChangeNotifier{


  List<QueryDocumentSnapshot> _newMsgFriends = initialMsgFriends;
  List<QueryDocumentSnapshot> get newMsgFriends => _newMsgFriends;

  void changeNewMsgFriends(QueryDocumentSnapshot eachUser){
    final isChecked = _newMsgFriends.contains(eachUser);
    if (isChecked){
      // _newMsgFriends.removeAt(_newMsgFriends.indexOf(userName));
      _newMsgFriends.remove(eachUser);
    } else {
      _newMsgFriends.add(eachUser);
    }
    notifyListeners();
  }

  void resetAllList(){
    _newMsgFriends = [];
    notifyListeners();
  }
}