import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import '../../../../../firebase/firebase_auth_remote_data_source.dart';
import '../social_sign_in.dart';




class KakaoLoginModel {
  final storage = const FlutterSecureStorage();
  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();
  final SocialLogin _socialLogin;
  bool isLoggedIn = false;
  kakao.User? user;

  KakaoLoginModel(this._socialLogin);

  Future<List> login(String pushToken) async {
    isLoggedIn = await _socialLogin.login();
    bool isFirst = false;
    if (isLoggedIn) {


      user =  await kakao.UserApi.instance.me();

      // 서버에서 받아오는 토큰
      final token = await _firebaseAuthDataSource.createCustomToken({
        'uid': user?.id.toString(),
        'displayName': user?.kakaoAccount?.profile?.nickname,
        'userEmail': user?.kakaoAccount?.email,
        'photoURL': user?.kakaoAccount?.profile?.profileImageUrl,
      });

      isFirst = await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: user?.id.toString()).get().then((value){
        if(value.docs.isEmpty) {
          return true;
        } else {
          return false;
        }
      });


      try{
        final userCredential = await FirebaseAuth.instance.signInWithCustomToken(token);
        userCredential.user?.updateEmail(user!.kakaoAccount!.email!);


      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "invalid-custom-token":
            print("The supplied token is not a Firebase custom auth token.");
            break;
          case "custom-token-mismatch":
            print("The supplied token is for a different Firebase project.");
            break;
          default:
            print("Unkown error. \n $e");
        }
      }

      await FirebaseFirestore.instance
          .collection('user')
          .doc(user!.kakaoAccount!.email!)
          .set({
        'userName': user!.kakaoAccount!.profile!.nickname,
        'userEmail': user!.kakaoAccount!.email,
        'userImage': user!.kakaoAccount!.profile!.profileImageUrl!,
        'uid' : 'kakao:${user!.id}',
        'pushToken' : pushToken
      });

      // Save in Device
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userName', user!.kakaoAccount!.profile!.nickname ?? "NoUserName");
      prefs.setString('userEmail',  user!.kakaoAccount!.email!);
      prefs.setString('userImage', user!.kakaoAccount!.profile!.profileImageUrl!);
      prefs.setString('uid', 'kakao:${user!.id}');
    }

    return [
      isLoggedIn,
      'kakao:${user!.id}',
      user!.kakaoAccount!.profile!.nickname!,
      user!.kakaoAccount!.email!,
      user!.kakaoAccount!.profile!.profileImageUrl!,
      isFirst
    ];
  }


  Future logout() async {

    Map<String, String> allStorage = await storage.readAll();
    allStorage.forEach((k,v) async {
      if (v == 'STATUS_LOGIN'){
        await storage.write(key: k, value: 'STATUS_LOGOUT');
      }
    });

    await _socialLogin.logout();
    await FirebaseAuth.instance.signOut();
    isLoggedIn = false;
    user = null;
  }
}