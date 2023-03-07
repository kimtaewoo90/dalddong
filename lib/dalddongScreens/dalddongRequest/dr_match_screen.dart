import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:flutter/material.dart';

import '../../../main_screen.dart';
import '../../commonScreens/shared_app_bar.dart';

class CompleteAccept extends StatefulWidget {
  const CompleteAccept({Key? key, required this.dalddongId}) : super(key: key);
  final String? dalddongId;

  @override
  State<CompleteAccept> createState() => _CompleteAcceptState();
}

class _CompleteAcceptState extends State<CompleteAccept> {

  String? lunchOrDinner;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: GeneralUiConfig.backgroundColor,
        appBar: BaseAppBar(
          appBar: AppBar(),
          title: "",
          backBtn: false,

        ),
        body: Center(
          child: Stack(
              children:
              [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "짝짝짝",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20,),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('DalddongList')
                            .doc(widget.dalddongId)
                            .snapshots(),

                        builder: (context, snapshot){
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            );
                          }

                          // isAllConfirmed update to true.
                          FirebaseFirestore.instance.collection('DalddongList').doc(widget.dalddongId).update(
                              {'isAllConfirmed' : true});

                          lunchOrDinner = snapshot.data!.get('LunchOrDinner') == 0 ? "점심" : "저녁";


                          return Text("   ${DateTime.fromMillisecondsSinceEpoch(snapshot.data?.get('DalddongDate').seconds * 1000).year}년 "
                              "${DateTime.fromMillisecondsSinceEpoch(snapshot.data?.get('DalddongDate').seconds * 1000).month}월 "
                              "${DateTime.fromMillisecondsSinceEpoch(snapshot.data?.get('DalddongDate').seconds * 1000).day}일",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 35,
                            ),
                          );
                        }
                    ),

                    StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('DalddongList').doc(widget.dalddongId).collection('Members').snapshots(),
                        builder: (context, snapshotMembers) {

                          if(snapshotMembers.connectionState == ConnectionState.waiting){
                            return Container(
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            );
                          }

                          List<UserAccept> responseMembers = [];
                          snapshotMembers.data?.docs.forEach((document) {
                            UserAccept userResponse = UserAccept(document);
                            responseMembers.add(userResponse);
                          });

                          return Flexible(
                            child: Column(
                              children : [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: ListView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: responseMembers,
                                  ),
                                ),

                                const SizedBox(height: 20,),

                                Text('${snapshotMembers.data?.docs.length}명의 $lunchOrDinner 약속이\n'
                                    '달력에 동그라미 되었습니다!',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),

                                Image.asset('images/dalddong.jpg'),

                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                        MaterialStateProperty.all(GeneralUiConfig.btnColor),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(0.0),
                                                // side: BorderSide(color: Colors.red)
                                            )
                                        )),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MainScreen(),
                                          ));
                                    },
                                    child: const Text("메인화면"),
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                    )
                  ],
                ),
              ]
          ),
        ),
      ),
    );
  }
}



class UserAccept extends StatefulWidget{
  final QueryDocumentSnapshot eachUser;
  const UserAccept(this.eachUser, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<UserAccept> createState() => _UserAccept(eachUser);
}

class _UserAccept extends State<UserAccept>{
  final QueryDocumentSnapshot eachUser;
  _UserAccept(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // width: MediaQuery.of(context).size.width - 100,
      // margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.all(3.0),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.black,
          backgroundImage: NetworkImage(eachUser['userImage'],),
        ),
        title: Text(eachUser['userName'], style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        ),
      ),
    );
  }
}

