import 'package:dalddong/commonScreens/config.dart';
import 'package:dalddong/commonScreens/page_route_with_animation.dart';
import 'package:flutter/material.dart';

import '../functions/signInUp/signIn/sign_in_screen.dart';

// import '../common/Functions/PageRouteWithAnimation.dart';
// import 'signIn_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: Scaffold(
        backgroundColor: const Color(0xff025645),
        body: PageView(children: [
          Column(
            children: const [
              Flexible(
                fit: FlexFit.tight,
                child: Center(
                  child: Text(
                    "혼자 먹는 밥, \n 궁금한 다른 회사, \n 퇴근-집의 반복,",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Center(
                    child: Text(
                      "지루하지 않으셨나요?",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent),
                    )),
              ),
            ],
          ),
          Column(
            children: const [
              Flexible(
                fit: FlexFit.tight,
                child: Center(
                  child: Text(
                    "맞지 않은 스케줄, \n 갑작스런 펑크, \n 여기저기 조율하는, \n 뻐꾸기의 삶,",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Center(
                    child: Text(
                      "불편하진 않으셨나요?",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent),
                    )),
              ),
            ],
          ),

          Column(
            children: [
              const Flexible(
                fit: FlexFit.tight,
                child: Center(
                  child: Text(
                    "맞지 않은 스케줄, \n 갑작스런 펑크, \n 여기저기 조율하는, \n 뻐꾸기의 삶,",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent),
                  ),
                ),
              ),
              const Flexible(
                fit: FlexFit.tight,
                child: Center(
                    child: Text(
                      "불편하진 않으셨나요?",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent),
                    )),
              ),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(GeneralUiConfig.floatingBtnColor)),
                  onPressed: () {
                    PageRouteWithAnimation pageRoute = PageRouteWithAnimation(const SignIn());
                    Navigator.push(context, pageRoute.slideBottonToTop());
                  },
                  child: const Text("시작하기"),
                ),
              ),
              const SizedBox(height: 20,),
            ],
          )
        ]),
      ),
    );
  }
}
