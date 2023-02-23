import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

import '../../friends/friends_profile_screen.dart';


class ChatBubbles extends StatelessWidget {
  const ChatBubbles(this.message,
      this.isMe,
      this.userName,
      this.userEmail,
      this.userImage,
      this.sentTime,
      this.myEmail,
      {Key? key}) : super(key: key);

  final String message;
  final String userName;
  final bool isMe;
  final String userEmail;
  final String userImage;
  final String sentTime;
  final String myEmail;

  @override
  Widget build(BuildContext context) {



    return Stack(
        children:[
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start ,
            children: [
              if (isMe)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,15,0),
                  child: Row(
                    children: [
                      Text(
                        sentTime,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                        ),
                      ),

                      const SizedBox(width: 5,),

                      ChatBubble(
                        clipper: ChatBubbleClipper8(type: BubbleType.sendBubble),
                        alignment: Alignment.topRight,
                        margin: const EdgeInsets.only(top: 20),
                        backGroundColor: Colors.blue,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.fromLTRB(45,10,0,0),
                  child: Row(
                    children: [
                      ChatBubble(
                        clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
                        backGroundColor: const Color(0xffE7E7ED),
                        margin: const EdgeInsets.only(top: 20),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          child: Column(
                            crossAxisAlignment: isMe? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                ),
                              ),
                              Text(
                                message,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 5,),

                      Text(
                        sentTime,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                )
            ],
          ),
          if(!isMe)
            Positioned(
              top: 0,
              right: isMe ? null : null,
              left: isMe ? null: 5,
              child:
              GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          showProfile(userName: userName,
                            userEmail: userEmail,
                            userImage: userImage, myEmail: myEmail,),
                      ));
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userImage),
                ),
              ),
            )
        ]
    );
  }
}
