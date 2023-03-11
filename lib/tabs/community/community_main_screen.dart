import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timer_builder/timer_builder.dart';

import '../../commonScreens/page_route_with_animation.dart';
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/providers/community_provider.dart';
import '../../functions/utilities/Utility.dart';
import 'community_read_screen.dart';
import 'community_upload_screen.dart';


class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _postItems = [];
  late DateTime latestUpdatedPost;

  @override
  void initState() {
    super.initState();

    // Future.microtask(() {
    //   Provider.of<CommunityProvider>(context, listen: false).fetchItems(0);
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().resetAllProviderParameters();
    });
    _onRefresh();
  }

  // final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    _postItems = [];
    FirebaseFirestore.instance
        .collection('posts')
        .orderBy('uploadTime', descending: true).get().then((value){
      value.docs.forEach((element) {
        _postItems.add(element);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityProvider>(context);

    final List<String> categoryList = ['전체', '일상', '맛집추천', '취미', '회사생활', '기타'];

    final List<String> valueList = ['최신순', '인기순(좋아요순)'];
    String? selectedValue = '최신순';

    List<CategoryChip> categoryChips = [];
    for (var category in categoryList) {
      CategoryChip chip = CategoryChip(category: category);
      categoryChips.add(chip);
    };

    return WillPopScope(
      onWillPop: () async{
        final value = await yesNoDialog(context, "앱을 종료하십니까?");
        return value == true;
      },
      child: Scaffold(
        backgroundColor: GeneralUiConfig.backgroundColor,
        appBar: BaseAppBar(
          appBar: AppBar(),
          title: "커뮤니티",
          backBtn: false,
          center: false,
        ),

        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 10,),

              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: categoryChips,
                  ),
                ),
              ),

              // const Divider(),

              const SizedBox(height: 10,),
              // Expanded(
              //   flex: 1,
              //   child: Padding(
              //     padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              //     child: Row(
              //       children: [
              //
              //         // DropdownButton(
              //         //   value: selectedValue,
              //         //   items: valueList.map((value) {
              //         //     return DropdownMenuItem(
              //         //       value: value,
              //         //       child: Text(value),
              //         //     );
              //         //   }).toList(),
              //         //   onChanged: (value) {
              //         //     setState(() {
              //         //       selectedValue = value;
              //         //     });
              //         //   },
              //         // ),
              //
              //         // const Spacer(),
              //         // const Text("내 관심사만 보기"),
              //         // const SizedBox(width: 10,),
              //         // Switch(
              //         //   value: provider.isMyFavorite,
              //         //   onChanged: (value) {
              //         //     provider.changeMyFavorite(value);
              //         //   },
              //         //   activeColor: GeneralUiConfig.floatingBtnColor,
              //         // ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 10,),

              const Divider(),

              FutureBuilder(
                  future: context.read<CommunityProvider>().isSelectedCategory == "전체"
                      ? FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('uploadTime', descending: true).get()
                      : FirebaseFirestore.instance
                      .collection('posts')
                      .where('category', isEqualTo: context.read<CommunityProvider>().isSelectedCategory)
                      .orderBy('uploadTime', descending: true).get(),

                  builder: (context, snapshot){
                    if (!snapshot.hasData){
                      return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.60,
                          child: const Center(child: Text("게시물이 없습니다 ㅠㅠ"))
                      );
                    }

                    return Expanded(
                      flex: 12,
                      child: RefreshIndicator(
                        onRefresh: () async{
                          await Future.delayed(const Duration(milliseconds: 1000));
                          setState(() {});
                        },
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {

                            return GestureDetector(
                              onTap: (){
                                PageRouteWithAnimation pageRoute = PageRouteWithAnimation(WatchPost(postNumber : snapshot.data?.docs[index].id));
                                Navigator.push(context, pageRoute.slideRitghtToLeft());
                              },
                              child: Card(
                                elevation: 0,
                                // color: GeneralUiConfig.backgroundColor,
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Chip(
                                            label: Text(snapshot.data!.docs[index]['category']),
                                            // elevation: 6.0,
                                            // shadowColor: Colors.grey,
                                            visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4),
                                            autofocus: true,
                                          ),
                                        ),
                                        // Title for this article.
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                snapshot.data?.docs[index].get('title'),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 16
                                                ),
                                              ),
                                              // const Spacer(),
                                            ],
                                          ),
                                        ),
                                        // Contents for this article

                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  snapshot.data?.docs[index].get('content'),
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13
                                                  ),
                                                ),
                                              ),
                                              // const Spacer(),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 5,),
                                        const Divider(),
                                        const SizedBox(height: 5,),

                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                                          child: Row(
                                            children: [
                                              // 만약 내 글이면, "나" Clip 추가
                                              if(snapshot.data?.docs[index].get('writerEmail') == FirebaseAuth.instance.currentUser!.email)
                                                Transform(
                                                  transform : Matrix4.identity()..scale(1.0),
                                                  child: const Chip(
                                                      visualDensity: VisualDensity(horizontal: 0.0, vertical: -4),
                                                      label: Text("나")
                                                  ),
                                                ),
                                              const SizedBox(width: 5,),
                                              // 글쓴이 이름
                                              Text(
                                                  "${snapshot.data?.docs[index].get('writerName')}"
                                              ),
                                              const SizedBox(width: 5,),
                                              const Text("|"),
                                              const SizedBox(width: 5,),
                                              // 글쓴 시간
                                              TimerBuilder.periodic(
                                                  const Duration(minutes: 1),
                                                  builder: (context){
                                                    Timestamp uploadedTime = snapshot.data?.docs[index].get('uploadTime');
                                                    var uploadedDate = uploadedTime.toDate();
                                                    var diffHour = (DateTime.now()
                                                        .difference(DateTime.fromMillisecondsSinceEpoch(
                                                        uploadedTime.seconds * 1000))
                                                        .inMinutes / 60).floor();
                                                    var diffMin = (DateTime.now()
                                                        .difference(DateTime.fromMillisecondsSinceEpoch(
                                                        uploadedTime.seconds * 1000))
                                                        .inMinutes % 60);

                                                    if (uploadedDate.day == DateTime.now().day){
                                                      if (diffHour == 0){
                                                        return Text("$diffMin분 전");
                                                      }
                                                      else{
                                                        return Text("$diffHour시간 전");
                                                      }
                                                    }
                                                    else{
                                                      return Text("${uploadedDate.year}.${uploadedDate.month}.${uploadedDate.day}");
                                                    }
                                                  }),

                                              const Spacer(),

                                              const Icon(Icons.thumb_up),
                                              const SizedBox(width: 5,),
                                              // 좋아요 갯수
                                              StreamBuilder(
                                                  stream: FirebaseFirestore.instance
                                                      .collection('posts')
                                                      .doc(snapshot.data?.docs[index].id)
                                                      .collection('likes').snapshots(),
                                                  builder: (context, likeSnapshot){
                                                    if(!likeSnapshot.hasData){
                                                      return const Text('0');
                                                    }
                                                    return Text("${likeSnapshot.data?.docs.length}");
                                                  }),

                                              const SizedBox(width: 20,),
                                              const Icon(Icons.comment),
                                              const SizedBox(width: 5,),
                                              // 댓글 갯수
                                              StreamBuilder(
                                                  stream: FirebaseFirestore.instance.collection('posts').doc(snapshot.data?.docs[index].id).collection('comments').snapshots(),
                                                  builder: (context, commentsSnapshot){
                                                    if(!commentsSnapshot.hasData){
                                                      return const Text('0');
                                                    }
                                                    return Text("${commentsSnapshot.data?.docs.length}");
                                                  }),
                                              const SizedBox(width: 10,)
                                            ],
                                          ),
                                        ),
                                        // const SizedBox(height: 10,),
                                      ]),
                                ),
                              ),
                            );

                          },
                          separatorBuilder: (context, index) =>
                          const Divider(
                            thickness: 1,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  })
            ],
          ),


        floatingActionButton: FloatingActionButton(
          backgroundColor: GeneralUiConfig.floatingBtnColor,
          child: const Icon(
            Icons.edit,
            color: Colors.black,
          ),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadPost()),
            );
          },
        ),
      ),
    );
  }
}

class CategoryChip extends StatefulWidget {
  final String? category;
  const CategoryChip({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: ActionChip(
        visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4),
        label: Text(
          widget.category!,
          style: TextStyle(
            color: context.read<CommunityProvider>().isSelectedCategory
                == widget.category!
                ? Colors.white
                : Colors.black,
          ),
        ),
        onPressed: (){
          context.read<CommunityProvider>().changeSelectedCategory(widget.category!);
        },
        backgroundColor: context.read<CommunityProvider>().isSelectedCategory
            == widget.category!
            ? Colors.black
            : Colors.white,
      ),
    );
  }
}


