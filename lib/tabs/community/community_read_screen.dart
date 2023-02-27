import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../commonScreens/page_route_with_animation.dart';
import '../../functions/utilities/Utility.dart';
import 'community_read_comment_screen.dart';


Text getWritingTimeToString(Timestamp uploadedTime) {
  var uploadedDate = uploadedTime.toDate();
  var diffHour = (DateTime.now()
      .difference(DateTime.fromMillisecondsSinceEpoch(
      uploadedTime.seconds * 1000))
      .inMinutes /
      60)
      .floor();
  var diffMin = (DateTime.now()
      .difference(
      DateTime.fromMillisecondsSinceEpoch(uploadedTime.seconds * 1000))
      .inMinutes %
      60);

  if (uploadedDate.day == DateTime.now().day) {
    if (diffHour == 0) {
      return Text("$diffMin분 전");
    } else {
      return Text("$diffHour시간 전");
    }
  } else {
    return Text(
        "${uploadedDate.year}.${uploadedDate.month}.${uploadedDate.day}");
  }
}

Widget commentActionSheet(){
  return CupertinoActionSheet(
  actions: <Widget>[
    ElevatedButton(
      onPressed: () {},
      child: const Text("수정하기"),
      ),

    ElevatedButton(
      onPressed: () {},
      child: const Text("삭제하기"),
      ),
      ],
      );
}

class WatchPost extends StatefulWidget {
  final String? postNumber;

  const WatchPost({Key? key, required this.postNumber}) : super(key: key);

  @override
  State<WatchPost> createState() => _WatchPostState();
}

class _WatchPostState extends State<WatchPost> {

  bool clickPlusBtn = false;

  final contentsActionSheet = CupertinoActionSheet(
    actions: <Widget>[
      ElevatedButton(
        onPressed: () {},
        child: const Text("수정하기"),
      ),

      // const SizedBox(height: 10,),

      ElevatedButton(
        onPressed: () async {
          // await FirebaseFirestore.instance.collection('posts').doc(widget.postNumber!)
        },
        child: const Text("삭제하기"),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: GeneralUiConfig.backgroundColor,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: GeneralUiConfig.backgroundColor,
          automaticallyImplyLeading: true,
          // leading: const Icon(Icons.menu_book_outlined),
          title: const Icon(Icons.menu_book_outlined),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postNumber)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  // height: MediaQuery.of(context).size.height,
                  child: Column(
                    // child: Column(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),

                      // 카테고리 Chip
                      Row(
                        children: [
                          Transform(
                            transform: Matrix4.identity()..scale(0.8),
                            child: Chip(
                                label: Text(
                                  snapshot.data?.get('category') ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )),
                          ),
                        ],
                      ),

                      // Title
                      Row(
                        children: [
                          Text(
                            snapshot.data?.get('title')! ?? "",
                            textAlign: TextAlign.left,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      // Image, Name, time
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue,
                                backgroundImage: NetworkImage(
                                    snapshot.data?.get('writerImage') ?? "")
                              //ExactAssetImage('image/default_profile.png'),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                Text(
                                  snapshot.data?.get('writerName') ?? "",
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                getWritingTimeToString(
                                    snapshot.data!.get('uploadTime')),
                              ],
                            ),
                            const Spacer(),
                            if (snapshot.data?.get('writerEmail') ==
                                FirebaseAuth.instance.currentUser?.email)
                              IconButton(
                                  onPressed: () {
                                    showCupertinoModalPopup(
                                        context: context,
                                        builder: (buildContext) {
                                          return CupertinoActionSheet(
                                            actions: <Widget>[
                                              ElevatedButton(
                                                onPressed: () {},
                                                child: const Text("수정하기"),
                                              ),

                                              // const SizedBox(height: 10,),

                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  FirebaseFirestore.instance
                                                      .collection('posts')
                                                      .doc(widget.postNumber!)
                                                      .delete();
                                                },
                                                child: const Text("삭제하기"),
                                              ),
                                            ],
                                          );
                                        });
                                    // contentsActionSheet);
                                  },
                                  icon: const Icon(Icons.more_vert))
                          ],
                        ),
                      ),
                      // const Divider(),
                      const SizedBox(
                        height: 10,
                      ),

                      // Contents
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              snapshot.data?.get('content') ?? "",
                              maxLines: 100,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      // const Divider(),

                      // likes Comments
                      Center(
                        child: Row(
                          children: [
                            Expanded(
                              child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(widget.postNumber)
                                      .collection('likes')
                                      .snapshots(),
                                  builder: (context, likeSnapshot) {
                                    var isAlreadyLike = likeSnapshot.data?.docs
                                        .where((element) =>
                                    element.id ==
                                        FirebaseAuth
                                            .instance.currentUser?.email)
                                        .length;
                                    return InkWell(
                                      onTap: () async {
                                        if (isAlreadyLike == 0) {
                                          await FirebaseFirestore.instance
                                              .collection('posts')
                                              .doc(widget.postNumber)
                                              .collection('likes')
                                              .doc(FirebaseAuth
                                              .instance.currentUser?.email)
                                              .set({"like": "like"});
                                        } else {
                                          await FirebaseFirestore.instance
                                              .collection('posts')
                                              .doc(widget.postNumber)
                                              .collection('likes')
                                              .doc(FirebaseAuth
                                              .instance.currentUser?.email)
                                              .delete();
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          if(likeSnapshot.data?.docs == null)
                                            const Icon(Icons.thumb_up)
                                          else
                                            likeSnapshot.data!.docs.map((doc) => doc.id).contains(FirebaseAuth.instance.currentUser?.email)
                                                ? const Icon(Icons.thumb_up)
                                                : const Icon(Icons.thumb_up_alt_outlined),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                              "${likeSnapshot.data?.docs.length}")
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                            Expanded(
                              child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(widget.postNumber)
                                      .collection('comments')
                                      .snapshots(),
                                  builder: (context, commentSnapshot) {
                                    return Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.comment),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            "${commentSnapshot.data?.docs.length}"),
                                      ],
                                    );
                                  }),
                            ),
                            Expanded(
                              child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(widget.postNumber)
                                      .collection('likes')
                                      .snapshots(),
                                  builder: (context, likeSnapshot) {
                                    return Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.star_border_outlined),
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 2,),
                      const SizedBox(height: 15,),

                      // Content of Comments
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(widget.postNumber)
                              .collection('comments')
                              .orderBy('uploadCommentTime', descending: true)
                              .snapshots(),
                          builder: (context, commentSnapshot) {
                            if (commentSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (commentSnapshot.data?.docs.isEmpty == true) {
                              return const Center(
                                child: Text("댓글이 없습니다."),
                              );
                            } else {
                              List<CommentsData> commentsCard = [];
                              commentSnapshot.data?.docs.forEach((comment) {
                                CommentsData commentsData = CommentsData(
                                    eachComments: comment,
                                    postNumber: widget.postNumber!);
                                commentsCard.add(commentsData);
                              });
                              return Column(
                                // shrinkWrap: true,
                                children: commentsCard,
                              );
                            }
                          }),
                    ],
                  ),
                ),
              );
            }),
        bottomSheet: WriteComments(postNumber: widget.postNumber!,),
      ),
    );
  }
}

class WriteComments extends StatefulWidget {
  final String postNumber;
  const WriteComments({Key? key, required this.postNumber}) : super(key: key);

  @override
  State<WriteComments> createState() => _WriteCommentsState();
}

class _WriteCommentsState extends State<WriteComments> {

  final _controller = TextEditingController();
  var _userEnterMessage = '';

  void _sendComment() async {
    FocusScope.of(context).unfocus();

    // SharedPreferences prefs = await utils.getSharedPreferences();

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postNumber)
        .collection('comments')
        .add({
      'commentUserName': await getMyName(),
      'commentUserEmail': await getMyEmail(),
      'commentUserImage': await getMyImage(),
      'commentText': _userEnterMessage.trim(),
      'uploadCommentTime': DateTime.now(),
    });

    setState(() {
      _controller.clear();
      _userEnterMessage = "";
    });

  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 1.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              maxLines: null,
              controller: _controller,
              decoration: const InputDecoration(labelText: '댓글을 입력해주세요'),
              // onSubmitted: (value){
              //   setState(() {
              //
              //   });
              // },
              onChanged: (value) {
                setState(() {
                  _userEnterMessage = value;
                });
              },

            ),
          ),
          IconButton(
            onPressed: _userEnterMessage.trim().isEmpty ? null : _sendComment,

            icon: const Icon(Icons.send),
            color: Colors.blue,
          )
        ],
      ),
    );
  }
}



class CommentsData extends StatefulWidget {
  final QueryDocumentSnapshot eachComments;
  final String postNumber;

  const CommentsData(
      {Key? key, required this.eachComments, required this.postNumber})
      : super(key: key);

  @override
  State<CommentsData> createState() => _CommentsDataState();
}

class _CommentsDataState extends State<CommentsData> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postNumber)
            .collection('comments')
            .doc(widget.eachComments.id)
            .collection('reComments')
            .orderBy('uploadCommentTime', descending: true)
            .snapshots(),
        builder: (context, reCommentsnapshot) {
          if (reCommentsnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<ReCommentDatas> reCommentDatas = [];
          reCommentsnapshot.data?.docs.forEach((reComment) {
            ReCommentDatas reCommentsData = ReCommentDatas(
                targetComments: widget.eachComments,
                eachReComments: reComment,
                postNumber: widget.postNumber
            );
            reCommentDatas.add(reCommentsData);
          });
          return GestureDetector(
            onTap: (){
              PageRouteWithAnimation pageRoute =
              PageRouteWithAnimation(WatchComment(
                eachComments: widget.eachComments,
                postNumber: widget.postNumber,
              ));
              Navigator.push(
                  context, pageRoute.slideRitghtToLeft());
            },
            child: Column(
              children: [
                // Comments Part
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white54),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue,
                                backgroundImage: NetworkImage(widget.eachComments
                                    .get('commentUserImage') ?? "")
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
                                getWritingTimeToString(widget.eachComments.get('uploadCommentTime'))
                              ],
                            ),
                            const Spacer(),
                            if (widget.eachComments.get('commentUserEmail') ==
                                FirebaseAuth.instance.currentUser?.email)
                              IconButton(
                                  onPressed: () {
                                    showCupertinoModalPopup(
                                        context: context,
                                        builder: (context) =>
                                        commentActionSheet());
                                  },
                                  icon: const Icon(Icons.more_vert))
                          ],
                        ),
                        const SizedBox(height: 10,),
                        // const Divider(),
                        const SizedBox(height: 10,),
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
                        // const Divider(),
                        const SizedBox(height: 10,),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // todo WatchComment Screen
                                PageRouteWithAnimation pageRoute =
                                PageRouteWithAnimation(WatchComment(
                                  eachComments: widget.eachComments,
                                  postNumber: widget.postNumber,
                                ));
                                Navigator.push(
                                    context, pageRoute.slideRitghtToLeft());
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
                                  var isAlreadyLike = likeCommentSnapshot
                                      .data?.docs
                                      .where((element) => element.id ==
                                      FirebaseAuth.instance.currentUser?.email).length;

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
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        if(likeCommentSnapshot.data?.docs == null)
                                          const Icon(Icons.thumb_up)
                                        else
                                          likeCommentSnapshot.data!.docs.map((doc) => doc.id).contains(FirebaseAuth.instance.currentUser?.email)
                                              ? const Icon(Icons.thumb_up)
                                              : const Icon(Icons.thumb_up_alt_outlined),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            "${likeCommentSnapshot.data?.docs.length}")
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                        const Divider(thickness: 2,),
                      ],
                    )
                  ),
                ),

                // reComments
                // if (reCommentsnapshot.data?.docs.isEmpty == true) const Divider(),

                if (reCommentsnapshot.data?.docs.isNotEmpty == true)
                  // const Divider(),

                  const SizedBox(height: 5,),
                  Column(
                    children: reCommentDatas,
                  ),
              ],
            ),
          );
        });
  }
}


class ReCommentDatas extends StatefulWidget {
  final QueryDocumentSnapshot targetComments;
  final QueryDocumentSnapshot eachReComments;
  final String postNumber;
  const ReCommentDatas({Key? key,
    required this.targetComments,
    required this.eachReComments,
    required this.postNumber}) : super(key: key);

  @override
  State<ReCommentDatas> createState() => _ReCommentDatasState();
}

class _ReCommentDatasState extends State<ReCommentDatas> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 2.0, 2.0),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: InkWell(
          onTap: () {
            // TODO: Enter the re-comment page
            PageRouteWithAnimation pageRoute =
            PageRouteWithAnimation(WatchComment(
              eachComments: widget.targetComments,
              postNumber: widget.postNumber,
            ));
            Navigator.push(
                context, pageRoute.slideRitghtToLeft());
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
                          widget.eachReComments
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
                        widget.eachReComments
                        ['reCommentUserName'] ??
                            "",
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      getWritingTimeToString(
                          widget.eachReComments
                          ['uploadCommentTime'])
                    ],
                  ),
                  const Spacer(),
                  if (widget.eachReComments
                  ['reCommentUserEmail'] ==
                      FirebaseAuth
                          .instance.currentUser?.email)
                    IconButton(
                        onPressed: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) =>
                              commentActionSheet());
                        },
                        icon: const Icon(Icons.more_vert))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // const Divider(),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.eachReComments
                      ['reCommentText'] ??
                          "",
                      maxLines: 100,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5,),
              const Divider(),
              const SizedBox(height: 5,),
            ],
          ),
        ),
      ),
    );
  }
}


