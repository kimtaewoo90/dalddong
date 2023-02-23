import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


const bool initialMyFavorite = false;
const String initialCategory = "전체";
const String initialCommentString = "";

int _initialComparedYear = DateTime.now().year;
int _initialComparedMonth = DateTime.now().month;

class CommunityProvider with ChangeNotifier {

  List<int> cache = [];
  // 로딩
  bool loading = false;
  // 게시물이 더 있는지 확인
  bool hasMore = true;

  _makeRequest({required int nextId,}) async {

    await Future.delayed(const Duration(seconds: 1));

    // nextId 다음의 20개의 값을 리스트로 리턴
    return List.generate(20, (index) => nextId + index);
  }

  fetchItems(int nextId) async {

    loading = true;
    notifyListeners();

    final items = await _makeRequest(nextId: nextId);

    cache = [
      ...cache,
      ...items,
    ];

    loading = false;
    notifyListeners();
  }

  // 댓글, 대댓글
  String _commentString = initialCommentString;
  String get commentString => _commentString;
  void changeCommentString(String value){
    _commentString = value;
    notifyListeners();
  }

  // 카테고리선택
  String _isSelectedCategory = initialCategory;
  String get isSelectedCategory => _isSelectedCategory;
  void changeSelectedCategory(String value){
    _isSelectedCategory = value;
    notifyListeners();
  }

  // 정렬순서


  // 내관심사
  bool _isMyFavorite = initialMyFavorite;
  bool get isMyFavorite => _isMyFavorite;
  void changeMyFavorite(bool value){
    _isMyFavorite = value;
    notifyListeners();
  }

  void resetAllProviderParameters(){
    _isSelectedCategory = initialCategory;
    _isMyFavorite = initialMyFavorite;
    notifyListeners();
  }


  // Dalddong List Menu
  int _comparedYear = _initialComparedYear;
  int get comparedYear => _comparedYear;

  int _comparedMonth = _initialComparedMonth;
  int get comparedMonth => _comparedMonth;

  void changeComparedDate(DateTime startDate){
    _comparedYear = startDate.year;
    _comparedMonth = startDate.month;
  }

  void resetComparedDate(){
    _comparedMonth = _initialComparedMonth;
    _comparedYear = _initialComparedYear;
    notifyListeners();
  }



}