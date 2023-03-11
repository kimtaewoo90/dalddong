import 'package:dalddong/commonScreens/config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../functions/providers/community_provider.dart';
import '../../functions/utilities/utilities_community.dart';
import 'community_main_screen.dart';


class UploadPost extends StatefulWidget {
  const UploadPost({Key? key}) : super(key: key);

  @override
  State<UploadPost> createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {

  String category = "전체";

  final _titleController = TextEditingController();
  var _enteredTitle = "";
  final _contentController = TextEditingController();
  var _enteredContent = "";

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().resetAllProviderParameters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityProvider>(context);
    final List<String> categoryList = ['전체', '일상', '맛집추천', '취미', '회사생활', '기타'];

    List<CategoryChip> categoryChips = [];
    for (var category in categoryList) {
      CategoryChip chip = CategoryChip(category: category);
      categoryChips.add(chip);
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: GeneralUiConfig.backgroundColor,
        appBar: AppBar(
          title: const Text("글쓰기", style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w700),),
          centerTitle: true,
          backgroundColor:  GeneralUiConfig.backgroundColor,
        ),

        body: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 0.0),
          child: Column(
            children: [

              if (provider.isSelectedCategory == "전체")
                const Text("카테고리를 골라주세요."),

              const SizedBox(height: 5,),

              Row(
                  children: [
                    const Text("분류", style: TextStyle(fontWeight: FontWeight.bold),),
                    const SizedBox(width: 15,),
                    // 카테고리 선택 안햇으면 나오는 UI
                    if (provider.isSelectedCategory == "전체")

                      Flexible(
                        fit: FlexFit.loose,
                        child: SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: categoryChips,
                          ),
                        ),
                      ),


                    if (provider.isSelectedCategory != "전체")
                      TextButton(
                          onPressed: () {
                            provider.changeSelectedCategory("전체");
                          },
                          child: Text(
                            provider.isSelectedCategory,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          )
                      ),
                  ]
              ),

              const Divider(),

              const SizedBox(height: 5,),
              Row(
                children: [
                  const Text("제목", style: TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(width: 15,),
                  Expanded(
                      child: TextField(
                        maxLength: 50,
                        maxLines: 1,
                        controller: _titleController,
                        decoration: const InputDecoration(
                            labelText: "제목을 입력하세요."
                        ),
                        onChanged: (value){
                          setState(() {
                            _enteredTitle = value;
                          });
                        },
                      ))
                ],
              ),

              Expanded(
                  child: TextField(
                    maxLength: 500,
                    maxLines: 100,
                    controller: _contentController,
                    decoration: const InputDecoration(
                        labelText: "본문내용"
                    ),
                    onChanged: (value){
                      setState(() {
                        _enteredContent = value;
                      });
                    },
                  )),

              const SizedBox(height: 10,),

              Row(
                children: [
                  Material(
                    color: Colors.grey,
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: const SizedBox(
                        height: kToolbarHeight,
                        width: 100,
                        child: Center(
                          child: Text(
                            '취소',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10,),

                  Expanded(
                      child: Material(
                        color: Colors.black,
                        child: InkWell(
                          onTap: () async {
                            if(_enteredContent.trim().isEmpty || _enteredTitle.trim().isEmpty){
                              Fluttertoast.showToast(
                                msg: '내용을 채워주세요!',
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                fontSize: 20,
                                textColor: Colors.white,
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            }
                            else{
                              SharedPreferences.getInstance().then((value){
                                SharedPreferences prefs = value;

                                var title = _enteredTitle;
                                var category = provider.isSelectedCategory;
                                var content = _enteredContent;
                                var uploadTime = DateTime.now();
                                var myName = prefs.getString('userName');
                                var myImage = prefs.getString('userImage');
                                var myEmail = prefs.getString('userEmail');

                                savePostInformation(
                                    title,
                                    category,
                                    content,
                                    uploadTime,
                                    myName,
                                    myImage,
                                    myEmail
                                );
                              });

                              Navigator.pop(context);

                            }

                          },
                          child: const SizedBox(
                            height: kToolbarHeight,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                '작성 완료',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 5,)
            ],
          ),
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
        label: Text(
          widget.category!,
          style: TextStyle(
            color: context.read<CommunityProvider>().isSelectedCategory == widget.category! ? Colors.white : Colors.black,
          ),
        ),
        onPressed: (){
          context.read<CommunityProvider>().changeSelectedCategory(widget.category!);
        },
        backgroundColor: context.read<CommunityProvider>().isSelectedCategory == widget.category! ? Colors.black : Colors.white,
      ),
    );
  }
}
