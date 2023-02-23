import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../commonScreens/config.dart';
import '../../../commonScreens/page_route_with_animation.dart';
import '../../../commonScreens/shared_app_bar.dart';
import '../../../main_screen.dart';


class SignupPhone extends StatefulWidget {

  final String userName;
  final String userEmail;
  final String userImage;
  final String? uId;

  const SignupPhone({Key? key,
    required this.userName,
    required this.userEmail,
    required this.userImage,
    required this.uId}) : super(key: key);

  @override
  State<SignupPhone> createState() => _SignupPhoneState();
}

class _SignupPhoneState extends State<SignupPhone> {

  final _formKeyPhone = GlobalKey<FormState>();
  String phoneNumber = "";
  bool isCompletePhoneVerify = false;

  void _tryValidationPhone() {
    final isValid = _formKeyPhone.currentState?.validate();
    if (isValid != null) {
      if (isValid) {
        _formKeyPhone.currentState!.save();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        top: false,
          child: Scaffold(
            backgroundColor: GeneralUiConfig.backgroundColor,
            appBar: BaseAppBar(
              appBar: AppBar(),
              title: "회원가입",
              backBtn: true,
              center: false,
            ),

            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ModalProgressHUD(
                inAsyncCall: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    const Text(
                      "전화번호 인증",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: GeneralUiConfig.titleTextColor),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Form(
                      key: _formKeyPhone,
                      child: Column(
                        children: [
                          TextFormField(
                            key: const ValueKey(5),
                            keyboardType: TextInputType.number,
                            validator: (value){
                              if(value!.isEmpty || value.length != 11){
                                return "휴대전화번호를 다시 확인해주세요";
                              }
                              return null;
                            },
                            onChanged: (value){
                              phoneNumber = value;
                            },
                            onSaved: (value){
                              phoneNumber = value!;
                            },

                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.phone),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: GeneralUiConfig.borderColor),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(35.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: GeneralUiConfig.focusBorderColor),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(35.0),
                                  ),
                                ),
                                hintText: " '-'를 제외하고 작성부탁해요",
                                hintStyle: TextStyle(
                                    fontSize: GeneralUiConfig.hintSize, color: GeneralUiConfig.hintColor),
                                contentPadding: EdgeInsets.all(10)),
                          ),
                          const SizedBox(height: 20,),

                          if(isCompletePhoneVerify == false)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.white38)),
                                onPressed: () {

                                  _tryValidationPhone();

                                  // TODO: Firebase 번호인증 기능 붙이기.
                                  print("여기서 번호인증 실행");
                                  if(_formKeyPhone.currentState?.validate() == true){
                                    setState(() {
                                      isCompletePhoneVerify = true;
                                    });
                                  }

                                },
                                child: const Text(
                                  '인증번호 요청',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),

                    const SizedBox(height: 15,),

                    if(isCompletePhoneVerify == true)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(GeneralUiConfig.btnColor),
                          ),
                          onPressed: () async {

                            var pushToken = await FirebaseMessaging.instance.getToken();

                            if(_formKeyPhone.currentState?.validate() == true){
                              try{
                                // save to DB
                                await FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(widget.userEmail)
                                    .set({
                                  'userName': widget.userName,
                                  'userEmail': widget.userEmail,
                                  'userImage': widget.userImage,
                                  'phoneNumber' : phoneNumber,
                                  'uid': widget.uId,
                                  'pushToken': pushToken,
                                  'isActive' : true,
                                  'activeChatRoom' : ""
                                });

                                // TODO : sharedPreference 저장
                                final prefs = await SharedPreferences.getInstance();
                                prefs.setString('userName', widget.userName);
                                prefs.setString('userEmail', widget.userEmail);
                                prefs.setString('uid', widget.uId!);
                                prefs.setString('userImage', widget.userImage);
                                prefs.setString('phoneNumber', phoneNumber);

                                PageRouteWithAnimation pageRoute =
                                PageRouteWithAnimation(
                                    const MainScreen());
                                Navigator.push(context, pageRoute.slideBottonToTop());

                              } on FirebaseAuthException catch (e){
                                if (kDebugMode) {
                                  print(e);
                                }
                              }
                            }
                          },

                          child: const Text(
                            '완료',
                            style: TextStyle(color: GeneralUiConfig.btnTextColor),
                          ),
                        )
                    )
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}
