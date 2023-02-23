import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


List<QueryDocumentSnapshot> initialInvitedFriends = [];
class ChatroomProvider with ChangeNotifier {

  // List<int> cache = [];
  // // 로딩
  // bool loading = false;
  // // 대화가 더 있는지 확인
  // bool hasMore = true;
  //
  // _makeRequest({required int nextId,}) async {
  //
  //   await Future.delayed(const Duration(seconds: 1));
  //
  //   // nextId 다음의 20개의 값을 리스트로 리턴
  //   return List.generate(20, (index) => nextId + index);
  // }
  //
  // fetchItems(int nextId) async {
  //   nextId ?? 0;
  //
  //   loading = true;
  //   notifyListeners();
  //
  //   final items = await _makeRequest(nextId: nextId);
  //
  //   cache = [
  //     ...cache,
  //     ...items,
  //   ];
  //
  //   loading = false;
  //   notifyListeners();
  // }

  List<QueryDocumentSnapshot> _newInvitedFriends = initialInvitedFriends;
  List<QueryDocumentSnapshot> get newInvitedFriends => _newInvitedFriends;

  void changeNewInvitedFriends(QueryDocumentSnapshot eachUser){
    final isChecked = _newInvitedFriends.contains(eachUser);
    if(isChecked){
      _newInvitedFriends.remove(eachUser);
    }
    else{
      _newInvitedFriends.add(eachUser);
    }
    notifyListeners();
  }

  void resetAllList(){
    _newInvitedFriends = [];
    notifyListeners();
  }
}