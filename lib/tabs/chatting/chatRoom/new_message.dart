
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dalddong/functions/pushManager/push_manager.dart';

class NewMessage extends StatefulWidget {


  const NewMessage({Key? key, this.roomId}) : super(key: key);
  final String? roomId;

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {

  final _controller = TextEditingController();
  var _userEnterMessage = '';
  final _pushManager = PushManager();

  void _sendMessage() async{

    final latestText = _userEnterMessage;
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance.collection('user')
        .doc(user!.email).get();

    final opponentData = await FirebaseFirestore.instance.collection('user')
        .doc(user.email).collection("chatRoomList").doc(widget.roomId).get();

    var AMorPM = DateTime.now().hour ~/ 12 == 0 ? "오전" : "오후";

    var hour = AMorPM == "오전" ? DateTime.now().hour.toString().padLeft(2,'0')
        : (DateTime.now().hour-12) == 0 ? DateTime.now().hour.toString().padLeft(2, '0')
        : (DateTime.now().hour-12).toString().padLeft(2, '0');
    var timeStamp = "$AMorPM $hour : ${DateTime.now().minute.toString().padLeft(2, '0')}";



    await FirebaseFirestore.instance.collection('chatrooms')
        .doc(widget.roomId)
        .collection('conversations')
        .add({
      'text' : _userEnterMessage,
      'time' : Timestamp.now(),
      'userID' : user.email,
      'userName' : userData.data()!['userName'],
      'userImage': userData['userImage'],
      'sentTime' : timeStamp,
    });


    // Update New messages for participants
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.roomId)
        .collection('participants')
        .get()
        .then((QuerySnapshot qs) {
      qs.docs.forEach((element) async {
        // Set Latest Text in Opponent DB
        FirebaseFirestore.instance
            .collection('user')
            .doc(element.get('userEmail'))
            .collection('chatRoomList')
            .doc(widget.roomId).update({
          'latestText' : latestText,
          'latestTimeString' : timeStamp,
          'latestTime' : Timestamp.now(),
        });

        bool isActive = await FirebaseFirestore.instance
            .collection('user')
            .doc(element.get('userEmail'))
            .get().then((value){
          return value.get('isActive');
        });

        String? activeChatRoom = await FirebaseFirestore.instance
            .collection('user')
            .doc(element.get('userEmail'))
            .get().then((value){
          return value.get('activeChatRoom');
        });

        print("$latestText------ ${element.get('userName')}의 isActive : $isActive");


        // TODO: background 일때만 푸쉬알람
        if(isActive == false || activeChatRoom != widget.roomId){
          FirebaseFirestore.instance
              .collection('user')
              .doc(element.get('userEmail'))
              .get().then((value) {

            var userToken = value.get('pushToken');
            var title = "${userData.data()!['userName']}님의 메시지";
            var body = latestText;
            var details = {
              'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
              'id' : "",
              'eventId' : widget.roomId,
              'alarmType' : "MSG"
            };
            _pushManager.sendPushMsg(userToken: userToken, title: title, body: body, details: details);
          });
        }
      });
    });

    setState(() {
      _controller.clear();
    });
    _userEnterMessage = '';

  }

  bool clickPlusBtn = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            onPressed: (){
              FocusScope.of(context).unfocus();
              // MediaQuery.of(context).viewInsets.bottom

              clickPlusBtn = !clickPlusBtn;
            },
            icon: clickPlusBtn == false ? const Icon(Icons.add) : const Icon(Icons.cancel),

          ),

          Expanded(
            child: TextField(
              maxLines: null,
              controller: _controller,
              decoration: const InputDecoration(
                  labelText: 'Send a message...'
              ),
              onChanged: (value){
                setState(() {
                  _userEnterMessage = value;
                });
              },
            ),
          ),
          IconButton(
            onPressed: _userEnterMessage.trim() == '' ? null : _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.blue,
          )
        ],
      ),
    );
  }
}
