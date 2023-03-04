// SmartRefresher(
// enablePullDown: true,	// 아래로 당겨서 새로고침 할 수 있게 할건지의 유무를 결정
// enablePullUp: true,	    // 위로 당겨서 새로운 데이터를 불러올수 있게 할건지의 유무를 결정
// // 이 부분은 'header' 즉 머리뿐으로써, 새로고침시 로딩결과에 따라 어떠한 글자를 띄워 줄지 정의 할 수 있다.
// header: CustomHeader(
// builder: (BuildContext context, RefreshStatus? mode) {
// Widget body;
// if (mode == RefreshStatus.idle) {
// body = const Text('');
// } else if (mode == RefreshStatus.refreshing) {
// body = const CupertinoActivityIndicator();
// } else {
// body = const Text('');
// }
// return SizedBox(
// height: 55.0,
// child: Center(child: body),
// );
// },
// ),
// // 이 부분은 'footer' 번역하면 바닥글이란 의미인데 무한스크롤시 로딩결과에 따라 어떠한 글자를 띄워 줄지를 정의할수있다.
// // footer: CustomFooter(
// //   builder: (BuildContext context,LoadStatus mode){
// //     Widget body ;
// //     if(mode==LoadStatus.idle){
// //       body =  Text("pull up load");
// //     }
// //     else if(mode==LoadStatus.loading){
// //       body =  CupertinoActivityIndicator();
// //     }
// //     else if(mode == LoadStatus.failed){
// //       body = Text("Load Failed!Click retry!");
// //     }
// //     else if(mode == LoadStatus.canLoading){
// //       body = Text("release to load more");
// //     }
// //     else{
// //       body = Text("No more Data");
// //     }
// //     return Container(
// //       height: 55.0,
// //       child: Center(child:body),
// //     );
// //   },
// // ),
// controller: _refreshController,
// onRefresh: _onRefresh,	// 새로고침을 구현한 함수
// onLoading: _onLoading,	// 무한스크롤을 구현한 함수
// child: ListView.builder// 리스트뷰
// itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
// itemExtent: 100.0,
// itemCount: items.length,
// ),
//
//
// StreamBuilder(
// stream: context.read<CommunityProvider>().isSelectedCategory == "전체"
// ? FirebaseFirestore.instance
//     .collection('posts')
// .orderBy('uploadTime', descending: true).snapshots()
//     : FirebaseFirestore.instance
//     .collection('posts')
// .where('category', isEqualTo: context.read<CommunityProvider>().isSelectedCategory)
// .orderBy('uploadTime', descending: true).snapshots(),
//
// builder: (context, snapshot){
// if (!snapshot.hasData){
// return SizedBox(
// height: MediaQuery.of(context).size.height * 0.60,
// child: const Center(child: Text("게시물이 없습니다 ㅠㅠ"))
// );
// }
//
// return Expanded(
// flex: 12,
// child: ListView.separated(
// shrinkWrap: true,
// scrollDirection: Axis.vertical,
// itemCount: snapshot.data!.docs.length,
// itemBuilder: (context, index) {
//
// return GestureDetector(
// onTap: (){
// // print("tapped");
// PageRouteWithAnimation pageRoute = PageRouteWithAnimation(WatchPost(postNumber : snapshot.data?.docs[index].id));
// Navigator.push(context, pageRoute.slideRitghtToLeft());
// },
// child: Card(
// elevation: 0,
// // color: GeneralUiConfig.backgroundColor,
// color: Colors.transparent,
// child: Padding(
// padding: const EdgeInsets.all(3.0),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
//
// children: [
// Padding(
// padding: const EdgeInsets.all(8.0),
// child: Chip(
// label: Text(snapshot.data!.docs[index]['category']),
// // elevation: 6.0,
// // shadowColor: Colors.grey,
// visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4),
// autofocus: true,
// ),
// ),
// // Title for this article.
// Padding(
// padding: const EdgeInsets.all(8.0),
// child: Row(
// children: [
// Text(
// snapshot.data?.docs[index].get('title'),
// textAlign: TextAlign.center,
// maxLines: 2,
// overflow: TextOverflow.ellipsis,
// style: const TextStyle(
// fontWeight: FontWeight.bold, fontSize: 16
// ),
// ),
// // const Spacer(),
// ],
// ),
// ),
// // Contents for this article
//
// Padding(
// padding: const EdgeInsets.all(8.0),
// child: Row(
// children: [
// Expanded(
// child: Text(
// snapshot.data?.docs[index].get('content'),
// textAlign: TextAlign.start,
// maxLines: 1,
// overflow: TextOverflow.ellipsis,
// style: const TextStyle(
// color: Colors.grey,
// fontSize: 13
// ),
// ),
// ),
// // const Spacer(),
// ],
// ),
// ),
//
// const SizedBox(height: 5,),
// const Divider(),
// const SizedBox(height: 5,),
//
// Padding(
// padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
// child: Row(
// children: [
// // 만약 내 글이면, "나" Clip 추가
// if(snapshot.data?.docs[index].get('writerEmail') == FirebaseAuth.instance.currentUser!.email)
// Transform(
// transform : Matrix4.identity()..scale(1.0),
// child: const Chip(
// visualDensity: VisualDensity(horizontal: 0.0, vertical: -4),
// label: Text("나")
// ),
// ),
// const SizedBox(width: 5,),
// // 글쓴이 이름
// Text(
// "${snapshot.data?.docs[index].get('writerName')}"
// ),
// const SizedBox(width: 5,),
// const Text("|"),
// const SizedBox(width: 5,),
// // 글쓴 시간
// TimerBuilder.periodic(
// const Duration(minutes: 1),
// builder: (context){
// Timestamp uploadedTime = snapshot.data?.docs[index].get('uploadTime');
// var uploadedDate = uploadedTime.toDate();
// var diffHour = (DateTime.now()
//     .difference(DateTime.fromMillisecondsSinceEpoch(
// uploadedTime.seconds * 1000))
//     .inMinutes / 60).floor();
// var diffMin = (DateTime.now()
//     .difference(DateTime.fromMillisecondsSinceEpoch(
// uploadedTime.seconds * 1000))
//     .inMinutes % 60);
//
// if (uploadedDate.day == DateTime.now().day){
// if (diffHour == 0){
// return Text("$diffMin분 전");
// }
// else{
// return Text("$diffHour시간 전");
// }
// }
// else{
// return Text("${uploadedDate.year}.${uploadedDate.month}.${uploadedDate.day}");
// }
// }),
//
// const Spacer(),
//
// const Icon(Icons.thumb_up),
// const SizedBox(width: 5,),
// // 좋아요 갯수
// StreamBuilder(
// stream: FirebaseFirestore.instance
//     .collection('posts')
//     .doc(snapshot.data?.docs[index].id)
//     .collection('likes').snapshots(),
// builder: (context, likeSnapshot){
// if(!likeSnapshot.hasData){
// return const Text('0');
// }
// return Text("${likeSnapshot.data?.docs.length}");
// }),
//
// const SizedBox(width: 20,),
// const Icon(Icons.comment),
// const SizedBox(width: 5,),
// // 댓글 갯수
// StreamBuilder(
// stream: FirebaseFirestore.instance.collection('posts').doc(snapshot.data?.docs[index].id).collection('comments').snapshots(),
// builder: (context, commentsSnapshot){
// if(!commentsSnapshot.hasData){
// return const Text('0');
// }
// return Text("${commentsSnapshot.data?.docs.length}");
// }),
// const SizedBox(width: 10,)
// ],
// ),
// ),
// // const SizedBox(height: 10,),
// ]),
// ),
// ),
// );
//
// },
// separatorBuilder: (context, index) =>
// const Divider(
// thickness: 1,
// color: Colors.black,
// ),
// ),
// );
// })