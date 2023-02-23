import 'package:dalddong/functions/signInUp/signUp/sign_up_3_pw_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../commonScreens/config.dart';
import '../../../commonScreens/page_route_with_animation.dart';
import '../../../commonScreens/shared_app_bar.dart';


class SignUpEmail extends StatefulWidget {
  final String userName;

  const SignUpEmail({Key? key, required this.userName}) : super(key: key);

  @override
  State<SignUpEmail> createState() => _SignUpNameState();
}

class _SignUpNameState extends State<SignUpEmail> {

  final _formKey = GlobalKey<FormState>();

  String email = "";

  void _tryValidation() {
    final isValid = _formKey.currentState?.validate();
    if(isValid != null){
      if (isValid) {
        _formKey.currentState!.save();
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
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    // progress status

                    // email
                    const Text(
                      "이메일을 입력하세요",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: GeneralUiConfig.titleTextColor),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Form(
                        key: _formKey,
                        child: Column(children: [
                          // email
                          TextFormField(
                            key: const ValueKey(1),
                            validator: (value) {
                              if (value!.isEmpty || !value.contains('@')) {
                                return "이메일 형식을 다시 확인해주세요!";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              email = value;
                            },
                            onSaved: (value) {
                              email = value!;
                            },
                            decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  // color: Palette.iconColor,
                                ),
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
                                hintText: "이메일 주소를 입력해주세요",
                                hintStyle: TextStyle(
                                    fontSize: GeneralUiConfig.hintSize, color: GeneralUiConfig.hintColor),
                                contentPadding: EdgeInsets.all(10)),
                          ),

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

                                  _tryValidation();
                                  if(_formKey.currentState?.validate() == true){
                                    print(_formKey.currentState?.validate());
                                    try{
                                      PageRouteWithAnimation pageRoute =
                                      PageRouteWithAnimation(
                                          SignupPw(
                                            userName : widget.userName,
                                            userEmail: email,));
                                      Navigator.push(context, pageRoute.slideBottonToTop());

                                    } catch(e){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('$e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  "다음",
                                  style: TextStyle(
                                      color: GeneralUiConfig.btnTextColor
                                  ),),
                              ),
                            ),
                          ),


                          // Spacer(),
                        ])
                    ),
                  ],
                ),
              ),
            ),
          ),

          // bottomSheet:
        ),
      ),
    );
  }
}
