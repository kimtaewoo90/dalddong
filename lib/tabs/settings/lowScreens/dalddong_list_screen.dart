import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:dalddong/functions/utilities/Utility.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../commonScreens/shared_app_bar.dart';
import '../../../functions/providers/community_provider.dart';


class DalddongList extends StatefulWidget {
  const DalddongList({Key? key}) : super(key: key);

  @override
  State<DalddongList> createState() => _DalddongListState();
}

class _DalddongListState extends State<DalddongList> {

  bool isDone = true;
  bool chiped = true;
  int? comparedYear;
  int comparedMonth = DateTime.now().month;

  @override
  void initState(){
    super.initState();
    // firstCompared = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().resetComparedDate();
    });

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: GeneralUiConfig.backgroundColor,
        appBar: BaseAppBar(
          appBar: AppBar(),
          title: "달똥 리스트",
          backBtn: true,
          center: false,
        ),

        body: Column(
          children: [
            Row(
              children: [
                TextButton(
                    onPressed: (){
                      setState(() {
                        isDone = true;
                      });
                    },
                    child: Text(
                      '확정된 달똥',
                      style: TextStyle(
                          color: isDone ? Colors.black : Colors.grey
                      ),
                    )),
                const SizedBox(width: 5,),
                const Text("|"),
                const SizedBox(width: 5,),
                TextButton(
                    onPressed: (){
                      setState(() {
                        isDone = false;
                      });
                    },
                    child: Text(
                      '진행중인 달똥',
                      style: TextStyle(
                          color: isDone ? Colors.grey : Colors.black
                      ),
                    )),
              ],
            ),

            const Divider(),
            const SizedBox(height: 15,),
            if(isDone == true)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('user')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('AppointmentList')
                        .where('isAppointment', isEqualTo: true)
                        .orderBy('startDate')
                        .get(),
                    builder: (context, snapshots){
                      var docs = snapshots.data?.docs.length;
                      if(docs == 0){
                        return const Center(
                          child: Text("아직 활동을 시작한 달똥이 없습니다."),
                        );
                      }
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshots.data?.docs.length,
                            itemBuilder: (context, index){

                              return FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('DalddongList')
                                      .doc(snapshots.data?.docs[index].get('scheduleId'))
                                      .get(),
                                  builder: (context, dalddongSnapshot) {
                                    return FutureBuilder(
                                        future: FirebaseFirestore.instance
                                            .collection('DalddongList')
                                            .doc(snapshots.data?.docs[index].get('scheduleId'))
                                            .collection('Members')
                                            .get(),
                                        builder: (context, memberSnapshot) {
                                          if(memberSnapshot.connectionState == ConnectionState.waiting){
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }

                                          List<MembersImage> membersImage = [];
                                          memberSnapshot.data?.docs.forEach((element) {
                                            MembersImage image = MembersImage(memberInfo: element);
                                            membersImage.add(image);
                                          });

                                          Timestamp startDateTimeStamp = snapshots.data?.docs[index].get('startDate');
                                          var startDate = DateTime.fromMillisecondsSinceEpoch(startDateTimeStamp.seconds * 1000);
                                          if(startDate.month != comparedMonth){
                                            chiped = true;
                                            comparedMonth = startDate.month;
                                          }
                                          else{
                                            chiped = false;
                                          }


                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              if(chiped)
                                                ActionChip(
                                                  visualDensity: const VisualDensity(horizontal: 4.0, vertical: -4),
                                                  label: Text('${startDate.year}년 ${startDate.month}월'),
                                                  backgroundColor: Colors.lightBlueAccent,
                                                ),

                                              const SizedBox(height: 5,),
                                              Card(
                                                child: InkWell(
                                                  onTap: (){},
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: SizedBox(
                                                      height: 90,
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                width : 80,
                                                                height: 75,
                                                                child: CircleAvatar(
                                                                  child: Text(
                                                                    "${startDate.day}",
                                                                    style: const TextStyle(
                                                                        fontSize: 25
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                              const SizedBox(width: 30,),
                                                              Expanded(
                                                                child: SizedBox(
                                                                  height: 75,
                                                                  width: 80,
                                                                  child: ListView(
                                                                    shrinkWrap: true,
                                                                    scrollDirection: Axis.horizontal,
                                                                    children: membersImage,
                                                                  ),
                                                                ),
                                                              ),


                                                              Expanded(
                                                                child: Text(
                                                                  "${DateFormat("yyyy년 MM월 dd일").format(startDate)}\n "
                                                                      "${dalddongSnapshot.data?.get('LunchOrDinner') == 0 ? "점심" : "저녁"}",
                                                                  style: const TextStyle(
                                                                      fontSize: 13
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // const SizedBox(height: 10,),
                                            ],
                                          );

                                        }
                                    );
                                  }
                              );
                            }),
                      );
                    },
                  ),
                ),
              ),

            // 진행중인 달똥
            if(isDone == false)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('DalddongList')
                        .where('isAllConfirmed', isEqualTo: false)
                        // .orderBy('startDate')
                        .get(),
                    builder: (context, ingSnapshot){
                      var myIngDalddong = [];
                      ingSnapshot.data?.docs.forEach((element) {
                        if(List.from(element.get('dalddongMembers')).contains(FirebaseAuth.instance.currentUser?.email)){
                          myIngDalddong.add(element);
                        }
                      });
                      var docsCount = myIngDalddong.length;
                      if(docsCount == 0){
                        return const Center(
                          child: Text("진행중인 달똥이 없습니다."),
                        );
                      }

                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: myIngDalddong.length,
                            itemBuilder: (context, index){

                              return FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('DalddongList')
                                      .doc(myIngDalddong[index].get('DalddongId'))
                                      .get(),
                                  builder: (context, dalddongSnapshot) {
                                    return FutureBuilder(
                                        future: FirebaseFirestore.instance
                                            .collection('DalddongList')
                                            .doc(myIngDalddong[index].get('DalddongId'))
                                            .collection('Members')
                                            .get(),
                                        builder: (context, memberSnapshot) {
                                          if(memberSnapshot.connectionState == ConnectionState.waiting){
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }

                                          List<MembersImage> membersImage = [];
                                          memberSnapshot.data?.docs.forEach((element) {
                                            MembersImage image = MembersImage(memberInfo: element);
                                            membersImage.add(image);
                                          });

                                          Timestamp startDateTimeStamp = myIngDalddong[index].get('DalddongDate');
                                          var startDate = DateTime.fromMillisecondsSinceEpoch(startDateTimeStamp.seconds * 1000);
                                          if(startDate.month != comparedMonth){
                                            chiped = true;
                                            comparedMonth = startDate.month;
                                          }
                                          else{
                                            chiped = false;
                                          }


                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              if(chiped)
                                                ActionChip(
                                                  visualDensity: const VisualDensity(horizontal: 4.0, vertical: -4),
                                                  label: Text('${startDate.year}년 ${startDate.month}월'),
                                                  backgroundColor: Colors.lightBlueAccent,
                                                ),

                                              const SizedBox(height: 5,),
                                              Card(
                                                child: InkWell(
                                                  onTap: (){},
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: SizedBox(
                                                      height: 90,
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                width : 80,
                                                                height: 75,
                                                                child: CircleAvatar(
                                                                  child: Text(
                                                                    "${startDate.day}",
                                                                    style: const TextStyle(
                                                                        fontSize: 25
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                              const SizedBox(width: 30,),
                                                              Expanded(
                                                                child: SizedBox(
                                                                  height: 75,
                                                                  width: 80,
                                                                  child: ListView(
                                                                    shrinkWrap: true,
                                                                    scrollDirection: Axis.horizontal,
                                                                    children: membersImage,
                                                                  ),
                                                                ),
                                                              ),


                                                              Expanded(
                                                                child: Text(
                                                                  "${DateFormat("yyyy년 MM월 dd일").format(startDate)}\n "
                                                                      "${myIngDalddong[index].get('LunchOrDinner') == 0 ? "점심" : "저녁"}",
                                                                  style: const TextStyle(
                                                                      fontSize: 13
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // const SizedBox(height: 10,),
                                            ],
                                          );

                                        }
                                    );
                                  }
                              );
                            }),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MembersImage extends StatefulWidget {
  final QueryDocumentSnapshot memberInfo;
  const MembersImage({Key? key, required this.memberInfo}) : super(key: key);

  @override
  State<MembersImage> createState() => _MembersImageState();
}

class _MembersImageState extends State<MembersImage> {
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10, 0.0, 0.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25.3,
                backgroundImage: NetworkImage(widget.memberInfo.get('userImage')),
              ),
              const SizedBox(height: 1,),
              Expanded(child: Text('${widget.memberInfo.get('userName')}', style: const TextStyle(fontSize: 10),)),
            ],
          ),
          const SizedBox(width: 5,)
        ],
      ),
    );
  }
}

//
// class DoneDalddongList extends StatefulWidget {
//   const DoneDalddongList({Key? key}) : super(key: key);
//
//   @override
//   State<DoneDalddongList> createState() => _DoneDalddongListState();
// }
//
// class _DoneDalddongListState extends State<DoneDalddongList> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         // if(index == 0 || startDate.month != context.read<CommunityProvider>().comparedMonth)
//         // Text("startDate.month : ${startDate.month} \n comparedMonth : $comparedMonth \n $firstCompared"),
//         if(chiped)
//           ActionChip(
//             visualDensity: const VisualDensity(horizontal: 4.0, vertical: -4),
//             label: Text('${startDate.year}년 ${startDate.month}월'),
//             backgroundColor: Colors.lightBlueAccent,
//           ),
//
//         const SizedBox(height: 5,),
//         Card(
//           child: InkWell(
//             onTap: (){},
//             child: Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: SizedBox(
//                 height: 90,
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width : 80,
//                           height: 75,
//                           child: CircleAvatar(
//                             child: Text(
//                               "${startDate.day}",
//                               style: const TextStyle(
//                                   fontSize: 25
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(width: 30,),
//                         Expanded(
//                           child: SizedBox(
//                             height: 75,
//                             width: 80,
//                             child: ListView(
//                               shrinkWrap: true,
//                               scrollDirection: Axis.horizontal,
//                               children: membersImage,
//                             ),
//                           ),
//                         ),
//
//
//                         Expanded(
//                           child: Text(
//                             "${DateFormat("yyyy년 MM월 dd일").format(startDate)}\n "
//                                 "${dalddongSnapshot.data?.get('LunchOrDinner') == 0 ? "점심" : "저녁"}",
//                             style: const TextStyle(
//                                 fontSize: 13
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         // const SizedBox(height: 10,),
//       ],
//     );();
//   }
// }


