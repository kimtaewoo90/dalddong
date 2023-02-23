import 'package:dalddong/functions/signInUp/signUp/sign_up_2_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../commonScreens/config.dart';
import '../../../commonScreens/page_route_with_animation.dart';
import '../../../commonScreens/shared_app_bar.dart';


class SignupName extends StatefulWidget {

  const SignupName({Key? key}) : super(key: key);

  @override
  State<SignupName> createState() => _SignupNameState();
}

class _SignupNameState extends State<SignupName> {

  final _formKeyName = GlobalKey<FormState>();
  String name = "";

  void _tryValidation() {
    final isValid = _formKeyName.currentState?.validate();
    if(isValid != null){
      if (isValid) {
        _formKeyName.currentState!.save();
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
                  // progress status

                  // email
                  const Text(
                    "이름을 입력해주세요",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GeneralUiConfig.titleTextColor),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  Form(
                      key: _formKeyName,
                      child: Column(children: [
                        // email
                        TextFormField(
                          key: const ValueKey(1),
                          validator: (value) {
                            if (value!.isEmpty || value.length < 2) {
                              return "이름을 입력해주세요!";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            name = value;
                          },
                          onSaved: (value) {
                            name = value!;
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Icon(
                                GeneralUiConfig.icon,
                                color: GeneralUiConfig.iconColor,
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
                              hintText: "이름을 입력해주세요",
                              hintStyle: TextStyle(
                                  fontSize: GeneralUiConfig.hintSize,
                                  color: GeneralUiConfig.hintColor),
                              contentPadding: EdgeInsets.all(10)),
                        ),
                      ])
                  ),
                  const SizedBox(height: 20,),

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

                          try{
                            if(name.isNotEmpty && name.length > 1){
                              PageRouteWithAnimation pageRoute = PageRouteWithAnimation(SignUpEmail(userName: name,));
                              Navigator.push(context, pageRoute.slideBottonToTop());
                            }


                          } catch(e){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$e'),
                              ),
                            );
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
