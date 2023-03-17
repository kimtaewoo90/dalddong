import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../alarm_screen.dart';


Widget noMatchedDalddongEvent(BuildContext context){
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      ClipPath(
        clipper: SemiCircleClipper(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: context.height() / 2,
              decoration: const BoxDecoration(color: Color(0xFFEEF1FA)),
            ),
            Image.asset('images/taskDone3.png', height: 250),
          ],
        ),
      ),
      50.height,
      Text('No Event', style: boldTextStyle(size: 20)),
      16.height,
      Text(
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
        style: primaryTextStyle(size: 15, color: Colors.blueGrey),
        textAlign: TextAlign.center,
      ).paddingSymmetric(vertical: 8, horizontal: 60),
      50.height,
      AppButton(
        shapeBorder: RoundedRectangleBorder(borderRadius: radius(30)),
        color: Color(0xFF5B98F3),
        elevation: 10,
        onTap: () {
          toast('Add Event');
        },
        child: Text('Add Event', style: boldTextStyle(color: white)).paddingSymmetric(horizontal: 32),
      ),
      50.height,
    ],
  );
}