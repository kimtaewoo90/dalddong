import 'package:flutter/material.dart';
// import 'package:prokit_flutter/main.dart';
import 'package:nb_utils/nb_utils.dart';

class RejectedDalddong extends StatefulWidget {
  const RejectedDalddong({Key? key}) : super(key: key);

  @override
  State<RejectedDalddong> createState() => _RejectedDalddongState();
}

class _RejectedDalddongState extends State<RejectedDalddong> {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   setStatusBarColor(appStore.scaffoldBackground!);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Image.asset('images/dalddongRejected.png', height: context.height(), fit: BoxFit.cover),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('이런!..', style: secondaryTextStyle(color: Colors.blueAccent, size: 40)),
                32.height,
                Text(
                  '달똥 요청이 거절되었네요..혹시 모르니 다시 요청해보세요..',
                  style: primaryTextStyle(color: Colors.grey, size: 18),
                ),
                48.height,
                AppButton(
                  child: Text('HOME', style: boldTextStyle()),
                  shapeBorder: RoundedRectangleBorder(borderRadius: radius(30)),
                  elevation: 30,
                  color: white,
                  onTap: () {
                    toast('HOME');
                  },
                ),
              ],
            ).paddingAll(32),
          ],
        ),
      ),
    );
  }
}
