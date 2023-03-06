import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../commonScreens/shared_app_bar.dart';
import '../../functions/utilities/Utility.dart';
import 'community_read_screen.dart';
import 'package:dalddong/functions/pushManager/push_manager.dart';


class WatchComment extends StatefulWidget {
  final QueryDocumentSnapshot eachComments;
  final String postNumber;

  const WatchComment({Key? key, required this.eachComments, required this.postNumber}) : super(key: key);

  @override
  State<WatchComment> createState() => _WatchCommentState();
}

class _WatchCommentState extends State<WatchComment> {


  final commentActionSheet = CupertinoActionSheet(
    actions: <Widget>[
      ElevatedButton(
        onPressed: () {},
        child: const Text("수정하기"),
      ),

      // const SizedBox(height: 10,),

      ElevatedButton(
        onPressed: () {},
        child: const Text("삭제하기"),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: GeneralUiConfig.backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: BaseAppBar(
        appBar: AppBar(),
        title: "댓글",
        backBtn: true,
        center: true,
      ),

      body:StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.postNumber)
              .collection('comments')
              .doc(widget.eachComments.id)
              .collection('reComments')
              .orderBy('uploadCommentTime', descending: true)
              .snapshots(),
          builder: (context, reCommentsnapshot) {
            if (reCommentsnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: const BoxDecoration(color: GeneralUiConfig.backgroundColor),
                    child: Card(
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blue,
                                  backgroundImage: NetworkImage(
                                      widget.eachComments.get('commentUserImage') ??
                                          "")
                                //ExactAssetImage('image/default_profile.png'),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: [
                                  Text(
                                    widget.eachComments.get('commentUserName') ?? "",
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  getWritingTimeToString(
                                      widget.eachComments.get('uploadCommentTime'))
                                ],
                              ),
                              const Spacer(),
                              if (widget.eachComments.get('commentUserEmail') ==
                                  FirebaseAuth.instance.currentUser?.email)
                                IconButton(
                                    onPressed: () {
                                      showCupertinoModalPopup(
                                          context: context,
                                          builder: (context) => commentActionSheet);
                                    },
                                    icon: const Icon(Icons.more_vert))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.eachComments.get('commentText') ?? "",
                                  maxLines: 100,
                                ),
                              )
                            ],
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.reply),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text("댓글달기"),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                        "${reCommentsnapshot.data?.docs.length} 개"),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(widget.postNumber)
                                      .collection('comments')
                                      .doc(widget.eachComments.id)
                                      .collection('likesComments')
                                      .snapshots(),
                                  builder: (context, likeCommentSnapshot) {
                                    if (likeCommentSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    var isAlreadyLike = likeCommentSnapshot.data?.docs
                                        .where((element) =>
                                    element.id == FirebaseAuth.instance.currentUser?.email).length;

                                    return InkWell(
                                      onTap: () async {
                                        if (isAlreadyLike == 0) {
                                          await FirebaseFirestore.instance
                                              .collection('posts')
                                              .doc(widget.postNumber)
                                              .collection('comments')
                                              .doc(widget.eachComments.id)
                                              .collection('likesComments')
                                              .doc(FirebaseAuth
                                              .instance.currentUser?.email)
                                              .set({"like": "like"});
                                        } else {
                                          await FirebaseFirestore.instance
                                              .collection('posts')
                                              .doc(widget.postNumber)
                                              .collection('comments')
                                              .doc(widget.eachComments.id)
                                              .collection('likesComments')
                                              .doc(FirebaseAuth
                                              .instance.currentUser?.email)
                                              .delete();
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if(likeCommentSnapshot.data?.docs == null)
                                              const Icon(Icons.thumb_up)
                                            else
                                              likeCommentSnapshot.data!.docs.map((doc) => doc.id).contains(FirebaseAuth.instance.currentUser?.email)
                                                  ? const Icon(Icons.thumb_up)
                                                  : const Icon(Icons.thumb_up_alt_outlined),                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                                "${likeCommentSnapshot.data?.docs.length}")
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // reComments
                if (reCommentsnapshot.data?.docs.isEmpty == true)
                  const Center(
                    child: Text("댓글이 없습니다."),
                  ),

                if (reCommentsnapshot.data?.docs.isNotEmpty == true)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: reCommentsnapshot.data?.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.grey),
                          child: Card(
                            color: Colors.grey,
                            child: InkWell(
                              onTap: () {
                                // TODO: Enter the re-comment page
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.blue,
                                          backgroundImage: NetworkImage(
                                              reCommentsnapshot.data?.docs[index]
                                              ['reCommentUserImage'] ??
                                                  "")
                                        //ExactAssetImage('image/default_profile.png'),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            reCommentsnapshot.data?.docs[index]
                                            ['reCommentUserName'] ??
                                                "",
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          getWritingTimeToString(reCommentsnapshot
                                              .data
                                              ?.docs[index]['uploadCommentTime'])
                                        ],
                                      ),
                                      const Spacer(),
                                      if (reCommentsnapshot.data?.docs[index]
                                      ['reCommentUserEmail'] ==
                                          FirebaseAuth.instance.currentUser?.email)
                                        IconButton(
                                            onPressed: () {
                                              showCupertinoModalPopup(
                                                  context: context,
                                                  builder: (context) =>
                                                  commentActionSheet);
                                            },
                                            icon: const Icon(Icons.more_vert))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          reCommentsnapshot.data?.docs[index]
                                          ['reCommentText'] ??
                                              "",
                                          maxLines: 100,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          }
      ),

      bottomSheet: WriteReComments(postNumber: widget.postNumber, commentsId: widget.eachComments.id,),

    );
  }
}


class WriteReComments extends StatefulWidget {
  final postNumber;
  final commentsId;
  const WriteReComments({Key? key, required this.postNumber, required this.commentsId}) : super(key: key);

  @override
  State<WriteReComments> createState() => _WriteReCommentsState();
}

class _WriteReCommentsState extends State<WriteReComments> {

  final _controller = TextEditingController();
  var _userEnterMessage = "";
  final _pushManager = PushManager();


  void _registerComment() async {
    FocusScope.of(context).unfocus();
    var reComment = _userEnterMessage.trim();
    setState(() {
      _controller.clear();
      _userEnterMessage = "";
    });
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postNumber)
        .collection('comments')
        .doc(widget.commentsId)
        .collection('reComments')
        .add({
      'reCommentUserName': await getMyName(),
      'reCommentUserEmail': await getMyEmail(),
      'reCommentUserImage': await getMyImage(),
      'reCommentText': reComment,
      'uploadCommentTime': DateTime.now(),
    });

    var commentUser = await FirebaseFirestore.instance.collection('posts').doc(widget.postNumber).collection('comments')
        .doc(widget.commentsId).get().then((value) => value.get('commentUserEmail'));
    var comment = await FirebaseFirestore.instance.collection('posts').doc(widget.postNumber).collection('comments')
        .doc(widget.commentsId).get().then((value) => value.get('commentText'));
    var userToken = await FirebaseFirestore.instance.collection('user').doc(commentUser).get().then((value) => value.get('pushToken'));
    var title = "$comment 에 댓글이 달렸습니다";
    var body = "$comment 에 대한 ${await getMyName()}님의 댓글 : $reComment";
    var details = {
      'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
      'id' : widget.commentsId,
      'eventId' : widget.commentsId,
      'alarmType' : "POST"
    };
    _pushManager.sendPushMsg(userToken: userToken, title: title, body: body, details: details);



  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 1.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: null,
              controller: _controller,
              decoration: const InputDecoration(labelText: '댓글을 입력해주세요'),
              onChanged: (value) {
                setState(() {
                  _userEnterMessage = value;
                });
              },
            ),
          ),
          IconButton(
            onPressed: _userEnterMessage.trim().isEmpty ? null : _registerComment,
            icon: const Icon(Icons.send),
            color: Colors.blue,
          )
        ],
      ),
    );
  }
}




