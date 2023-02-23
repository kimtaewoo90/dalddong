import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../main_screen.dart';
import '../../commonScreens/shared_app_bar.dart';

class VoteStatus extends StatefulWidget {
  final String? eventId;

  const VoteStatus({Key? key, required this.eventId}) : super(key: key);

  @override
  State<VoteStatus> createState() => _VoteStatusState();
}

class _VoteStatusState extends State<VoteStatus> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
        title: "투표현황",
        backBtn: false,
        center: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(widget.eventId)
            .collection('dalddong')
            .doc(widget.eventId)
            .collection('voteDates')
            .snapshots(),
        builder: (context, voteDateSnapshot) {
          if (voteDateSnapshot.connectionState == ConnectionState.waiting) {
            return Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .doc(widget.eventId)
                .collection('dalddong')
                .doc(widget.eventId)
                .collection('dalddongMembers').snapshots(),
            builder: (context, memberSnapshot){

              if(memberSnapshot.connectionState == ConnectionState.waiting){
                return Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              }

              var voteMembers = memberSnapshot.data?.docs.length;
              List<VoteDateStatus> eachVoteDate = [];
              voteDateSnapshot.data?.docs.forEach((element) {
                VoteDateStatus eachDateStatus =
                VoteDateStatus(voteDatesList: element, dalddongMembers: voteMembers,);
                eachVoteDate.add(eachDateStatus);
              });

              return Column(children: [
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    shrinkWrap: true,
                    children: eachVoteDate,
                  ),
                ),

                const SizedBox(height: 10,),

                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xff025645)),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ));
                    },
                    child: const Text('메인화면'),
                  ),
                )
              ]);
            },
          );
        },
      ),
    );
  }
}

class VoteDateStatus extends StatefulWidget {
  final QueryDocumentSnapshot voteDatesList;
  final int? dalddongMembers;

  const VoteDateStatus({Key? key, required this.voteDatesList, required this.dalddongMembers})
      : super(key: key);

  @override
  State<VoteDateStatus> createState() => _VoteDateStatusState();
}

class _VoteDateStatusState extends State<VoteDateStatus> {
  // var votedRate;
  @override
  Widget build(BuildContext context) {
    var votedRate =
        List.from(widget.voteDatesList.get('votedMembers')).length / widget.dalddongMembers!;

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 40,
          height: 35,
          padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
          child: Row(
            children: [
              Text(
                widget.voteDatesList.id,
                style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Colors.grey
                  // color: Colors.black
                ),
              ),
              const Spacer(),
              Text(
                "${List.from(widget.voteDatesList.get('votedMembers')).length}명",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        LinearPercentIndicator(
          width: MediaQuery.of(context).size.width - 40,
          animation: true,
          lineHeight: 20.0,
          animationDuration: 2000,
          percent: votedRate,
          center: Text("${(votedRate * 100)} %"),
          linearStrokeCap: LinearStrokeCap.roundAll,
          progressColor: const Color(0xff025645),
        )
      ],
    );
  }
}
