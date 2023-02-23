import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/functions/signInUp/signIn/socialSignIn/kakao/kakao_sign_in.dart';
import 'package:dalddong/functions/signInUp/signIn/socialSignIn/kakao/kakao_sign_in_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../commonScreens/page_route_with_animation.dart';
import '../../../main_screen.dart';
import '../signUp/sign_up_1_name_screen.dart';
import '../signUp/sign_up_4_phone_screen.dart';


class SignIn extends StatefulWidget {

  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final kakaoLogin = KakaoLoginModel(KaKaoLogin());
  bool _isKakaoLogin = false;

  final _formKey = GlobalKey<FormState>();

  bool showSpinner = false;
  bool passwordForm = true;
  String userEmail = "";
  String userPassword = "";

  void _tryValidation() {
    final isValid = _formKey.currentState?.validate();
    if(isValid != null){
      if (isValid) {
        _formKey.currentState!.save();
      }
    }
  }

  Future<bool> isFirstVisit(String uid) async{
    bool isFirst = await FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid).get().then((value){
      if(value.docs.isEmpty) {
        return true;
      } else {
        return false;
      }
    });

    return isFirst;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xff025645),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: GestureDetector(
              onTap: (){
                FocusScope.of(context).unfocus();
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      // fit: FlexFit.tight,
                        child: Center(
                          child: Text(
                            "누구보다 빠르고 편하게, \n  약속을 관리해볼까요?",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent),
                          ),
                        )
                    ),

                    Expanded(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const Text("로그인이 필요합니다 :)",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.amberAccent,
                                ),),

                              const SizedBox(height: 10,),

                              // email
                              TextFormField(
                                key: const ValueKey(1),
                                validator: (value){
                                  if(value!.isEmpty || !value.contains('@')){
                                    return "이메일 형식을 다시 확인해주세요!";
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  userEmail = value;
                                },
                                onSaved: (value){
                                  userEmail = value!;
                                },

                                decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.account_circle,
                                      // color: Palette.iconColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    hintText: "이메일 주소를 입력해주세요",
                                    hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white
                                    ),
                                    contentPadding: EdgeInsets.all(10)
                                ),
                              ),

                              const SizedBox(height: 10,),

                              // password
                              TextFormField(
                                obscureText: passwordForm,
                                key: const ValueKey(2),
                                validator: (value){
                                  if(value!.isEmpty || value.length < 6){
                                    return "비밀번호를 다시 확인해주세요!";
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  userPassword = value;
                                },
                                onSaved: (value){
                                  userPassword = value!;
                                },

                                decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.password,
                                      // color: Palette.iconColor,
                                    ),
                                    suffixIcon: Align(
                                      widthFactor: 1.0,
                                      heightFactor: 1.0,
                                      child: IconButton(
                                        onPressed: (){
                                          setState(() {
                                            passwordForm = !passwordForm;
                                          });
                                        },
                                        icon: const Icon(Icons.remove_red_eye),

                                      ),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    hintText: "비밀번호를 입력하세요",
                                    hintStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white
                                    ),
                                    contentPadding: const EdgeInsets.all(10)
                                ),
                              ),

                              const SizedBox(height: 10,),


                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      showSpinner = false;
                                    });

                                    var pushToken = await FirebaseMessaging.instance.getToken();

                                    _tryValidation();
                                    try{
                                      final loginUser = await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                          email: userEmail,
                                          password: userPassword
                                      );

                                      if(loginUser.user != null){
                                        FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(userEmail)
                                            .get()
                                            .then((doc) async {
                                          final prefs = await SharedPreferences.getInstance();
                                          prefs.setString('userName', doc.get('userName'));
                                          prefs.setString('userEmail', doc.get('userEmail'));
                                          prefs.setString('uid', doc.get('uid'));
                                          prefs.setString('userImage', doc.get('userImage'));
                                          prefs.setString('phoneNumber', doc.get('phoneNumber'));

                                          await FirebaseFirestore.instance
                                              .collection('user')
                                              .doc(loginUser.user!.email)
                                              .set({
                                            'userName': doc.get('userName'),
                                            'userEmail': doc.get('userEmail'),
                                            'userImage': doc.get('userImage'),
                                            'phoneNumber' : doc.get('phoneNumber'),
                                            'uid': doc.get('uid'),
                                            'pushToken': pushToken,
                                          });
                                        });

                                        PageRouteWithAnimation pageRoute = PageRouteWithAnimation(const MainScreen());
                                        Navigator.push(context, pageRoute.slideBottonToTop());

                                      }
                                    }catch(e){
                                      toasty(context, '이메일과 비밀번호를 확인해주세요');

                                      setState(() {
                                        showSpinner = false;
                                      });
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: getColorFromHex('#f2866c'),
                                    primary: getColorFromHex('#f2866c'),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: Text(
                                    '로 그 인',
                                    style: primaryTextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    Expanded(
                        child: Column(
                          children: [
                            const Center(
                              child: Text("SNS 계정으로 할래요",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.amberAccent,
                                ),),
                            ),

                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.yellow)),
                                onPressed: () async {
                                  var pushToken = await FirebaseMessaging.instance.getToken();

                                  setState(() {
                                    showSpinner = true;
                                  });

                                  try{
                                    var kakao = await kakaoLogin.login(pushToken!);
                                    _isKakaoLogin = kakao[0];
                                    var uid = kakao[1];
                                    var userName = kakao[2];
                                    var userEmail = kakao[3];
                                    var userImage = kakao[4];
                                    var isFirst = kakao[5];

                                    if(_isKakaoLogin){
                                      setState(() {showSpinner = false;});

                                      if(isFirst==true){
                                        PageRouteWithAnimation pageRoute = PageRouteWithAnimation(SignupPhone(
                                          userName: userName,
                                          userEmail: userEmail,
                                          userImage: userImage,
                                          uId: uid,
                                        ));
                                        Navigator.push(context, pageRoute.slideBottonToTop());
                                      }
                                      else{
                                        // reset page state after login with kakao.
                                        setState(() {showSpinner = false;});
                                        PageRouteWithAnimation pageRoute = PageRouteWithAnimation(const MainScreen());
                                        Navigator.push(context, pageRoute.slideBottonToTop());
                                      }
                                    }

                                    else{
                                      setState(() {
                                        showSpinner = false;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              '카카오톡 로그인 실패, 개발자에게 문의하세요'),
                                        ),
                                      );
                                    }
                                  } catch(e){
                                    setState(() {
                                      showSpinner = false;
                                    });
                                    print(e);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            '카카오톡 로그인 실패, 개발자에게 문의하세요'),
                                      ),
                                    );
                                  }


                                  // print(userImage);

                                },
                                child: const Text(
                                  "카카오로 시작하기",
                                  style: TextStyle(color: Colors.black),),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.green)),
                                onPressed: () async {
                                  // await kakaoLogin.login();
                                  // setState(() {
                                  //   // reset page state after login with kakao.
                                  //   // PageRouteWithAnimation pageRoute = PageRouteWithAnimation(const MainScreen());
                                  //   Navigator.push(context, pageRoute.slideBottonToTop());
                                  // });
                                },
                                child: const Text("네이버로 시작하기"),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.indigoAccent)),
                                onPressed: () async {
                                  // await kakaoLogin.login();
                                  setState(() {
                                    // reset page state after login with kakao.
                                  });
                                },
                                child: const Text("페이스북으로 시작하기"),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.black)),
                                onPressed: () async {
                                  // await kakaoLogin.login();
                                  setState(() {
                                    // reset page state after login with kakao.
                                  });
                                },
                                child: const Text("애플ID로 시작하기"),
                              ),
                            ),

                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.white38)),
                                onPressed: () async {
                                  PageRouteWithAnimation pageRoute = PageRouteWithAnimation(SignupName());
                                  Navigator.push(context, pageRoute.slideBottonToTop());
                                  setState(() {
                                    // reset page state after login with kakao.
                                  });
                                },
                                child: const Text(
                                  "회원가입",
                                  style: TextStyle(
                                      color: Colors.orangeAccent
                                  ),),
                              ),
                            ),
                          ],
                        ))
                  ],

                ),
              ),
            ),

          ),
        ),
      ),
    );
  }
}
