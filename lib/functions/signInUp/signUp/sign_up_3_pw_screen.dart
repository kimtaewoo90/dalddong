
import 'package:dalddong/functions/signInUp/signUp/sign_up_4_phone_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../commonScreens/config.dart';
import '../../../commonScreens/page_route_with_animation.dart';
import '../../../commonScreens/shared_app_bar.dart';


class SignupPw extends StatefulWidget {

  final String userName;
  final String userEmail;

  const SignupPw({Key? key, required this.userName, required this.userEmail})
      : super(key: key);

  @override
  State<SignupPw> createState() => _SignupPwState();
}

class _SignupPwState extends State<SignupPw> {
  final _formKeyPw = GlobalKey<FormState>();

  String password = "";
  String checkPassword = "";
  bool passwordForm = true;
  bool checkPasswordForm = true;
  String url = "https://ifh.cc/g/TCQ7BM.png";


  void _tryValidationPw() {
    final isValid = _formKeyPw.currentState?.validate();
    if (isValid != null) {
      if (isValid) {
        _formKeyPw.currentState!.save();
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
          resizeToAvoidBottomInset: false,
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Text(
                    "비밀번호를 입력해주세요",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GeneralUiConfig.titleTextColor),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Form(
                      key: _formKeyPw,
                      child: Column(children: [
                        // email
                        TextFormField(
                          obscureText: passwordForm,
                          key: const ValueKey(3),
                          validator: (value) {
                            if (value!.isEmpty || value.length < 6) {
                              return "비밀번호를 다시 확인해주세요!";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            password = value;
                          },
                          onSaved: (value) {
                            password = value!;
                          },
                          decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.password,
                                color: GeneralUiConfig.iconColor,
                              ),
                              suffixIcon: Align(
                                widthFactor: 1.0,
                                heightFactor: 1.0,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passwordForm = !passwordForm;
                                    });
                                  },
                                  icon: const Icon(Icons.remove_red_eye),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: GeneralUiConfig.borderColor),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: GeneralUiConfig.focusBorderColor),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              hintText: "비밀번호를 입력해주세요",
                              hintStyle: const TextStyle(
                                  fontSize: 14, color: GeneralUiConfig.hintColor),
                              contentPadding: const EdgeInsets.all(10)),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        TextFormField(
                          obscureText: checkPasswordForm,
                          key: const ValueKey(4),
                          validator: (value) {
                            if (value! != password || value.isEmpty) {
                              return "비밀번호가 일치하지 않아요!";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            checkPassword = value;
                          },
                          onSaved: (value) {
                            checkPassword = value!;
                          },
                          decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.spellcheck_rounded,
                                color: GeneralUiConfig.iconColor,
                              ),
                              suffixIcon: Align(
                                widthFactor: 1.0,
                                heightFactor: 1.0,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      checkPasswordForm = !checkPasswordForm;
                                    });
                                  },
                                  icon: const Icon(Icons.remove_red_eye),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: GeneralUiConfig.borderColor),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: GeneralUiConfig.focusBorderColor),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              hintText: "비밀번호를 확인해주세요",
                              hintStyle: const TextStyle(
                                  fontSize: GeneralUiConfig.hintSize, color: GeneralUiConfig.hintColor),
                              contentPadding: const EdgeInsets.all(10)),
                        ),
                      ])),

                  const SizedBox(height: 15,),

                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(GeneralUiConfig.btnColor)),
                        onPressed: () async {
                          _tryValidationPw();

                          if(_formKeyPw.currentState?.validate() != null &&
                              _formKeyPw.currentState?.validate() == true){
                            try{
                              var newUser = await FirebaseAuth
                                  .instance
                                  .createUserWithEmailAndPassword(
                                  email: widget.userEmail,
                                  password: password);

                              // 전화번호 인증 페이지 이동.
                              PageRouteWithAnimation pageRoute =
                              PageRouteWithAnimation(
                                  SignupPhone(
                                    userName: widget.userName,
                                    userEmail: widget.userEmail,
                                    userImage: url,
                                    uId : newUser.user?.uid,
                                  ));
                              Navigator.push(context, pageRoute.slideBottonToTop());


                            } on FirebaseAuthException catch (e){
                              if (e.code == 'weak-password') {
                                print('The password provided is too weak.');
                              } else if (e.code == 'email-already-in-use') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${widget.userEmail}은 이미 사용중입니다ㅠㅠ!'),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            }
                          }


                        },
                        child: const Text(
                          "다음",
                          style: TextStyle(color: GeneralUiConfig.btnTextColor),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
          // bottomSheet:
        ),
      ),
    );
  }
}
