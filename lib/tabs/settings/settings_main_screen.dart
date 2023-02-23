import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../commonScreens/page_route_with_animation.dart';
import '../../commonScreens/shared_app_bar.dart';
import '../../functions/utilities/Utility.dart';
import 'lowScreens/dalddong_list_screen.dart';




class SettingsScreen extends StatefulWidget {
  const SettingsScreen( {Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  File? _imageFile;

  final String? myUid = FirebaseAuth.instance.currentUser?.uid;

  void _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxHeight: 150,
    );

    setState(() {
      if(pickedImageFile != null){
        _imageFile = File(pickedImageFile.path);

        // TODO change to url and save it to Firebase user-> picked_image
        // _imageFile = profile_image;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        final value = await yesNoDialog(context, "앱을 종료하십니까?");
        return value == true;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          appBar: BaseAppBar(
            appBar: AppBar(),
            title: "",
            backBtn: false,
            center: true,
            hasLogout: true,
          ),


          resizeToAvoidBottomInset: true,

          body: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.email).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasData){
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),

                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [
                                const SizedBox(height: 100,),
                                imageProfile(snapshot),

                                const SizedBox(width: 20,),

                                Text(
                                  "${snapshot.data?.get('userName')}",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(height: 20,),
                            const Divider(thickness: 2, color: Colors.black,),

                            Row(
                              children: [
                                Image.asset('images/dalddongPoint_1.png'),

                                const SizedBox(width: 20,),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "나의 달力",
                                      style: TextStyle(
                                        color: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(height: 5,),

                                    Text(
                                      "귀여운 초승달",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      // "${snapshot.data?.get('point') ?? "18"}점"
                                      "18.3점",
                                      style: TextStyle(
                                          color: Colors.grey
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),

                            const SizedBox(height: 20,),

                            TextButton(
                              onPressed: (){},
                              child: const Text(
                                "나의 달똥",
                                style: TextStyle(
                                  color: Color(0xff025645),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),

                            // const SizedBox(height: 10,),

                            TextButton(
                              onPressed: (){
                                PageRouteWithAnimation pageRoute = PageRouteWithAnimation(const DalddongList());
                                Navigator.push(context, pageRoute.slideBottonToTop());
                              },
                              child: const Text(
                                "달똥리스트",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: (){},
                              child: const Text(
                                "나의 점심/저녁 시간설정",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: (){},
                              child: const Text(
                                "달똥일지",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: (){},
                              child: const Text(
                                "나의 커뮤니티",
                                style: TextStyle(
                                  color: Color(0xff025645),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: (){},
                              child: const Text(
                                "커뮤니티용 프로필 설정",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: (){},
                              child: const Text(
                                "내가 작성한 글 / 관심 글",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: (){},
                              child: const Text(
                                "친구초대",
                                style: TextStyle(
                                  color: Color(0xff025645),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: (){},
                              child: const Text(
                                "초대 및 코드등록" ,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const CircularProgressIndicator();
              }
          ),
        ),
      ),
    );
  }

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>> getUserData () async {
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance.collection('user')
        .doc(user!.email).snapshots();
    return userData;
  }

  Widget imageProfile(AsyncSnapshot<DocumentSnapshot> snapshot)  {
    return Center(
      child: Stack(
        children: <Widget> [
          CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              backgroundImage: NetworkImage(snapshot.data?.get('userImage'))
            //ExactAssetImage('image/default_profile.png'),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                _pickImage();
              },
              child: const Icon(
                Icons.camera_alt,
                color: Colors.grey,
                size: 24,
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget nameTextField(AsyncSnapshot snapshot){
    return Column(
      children: [

        // Name
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2,
              ),
            ),
            prefixIcon: Icon(
              Icons.person,
              color: Colors.grey,
            ),
            labelText: 'Name',
            hintText: 'Input your name',
          ),
        ),

        const SizedBox(height: 10,),

        // Email
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2,
              ),
            ),
            prefixIcon: Icon(
              Icons.email,
              color: Colors.grey,
            ),
            labelText: 'Name',
            hintText: 'Input your name',
          ),
        ),

        const SizedBox(height: 10,),

        // 한마디
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2,
              ),
            ),
            prefixIcon: Icon(
              Icons.add_alert,
              color: Colors.grey,
            ),
            labelText: '한마디',
            hintText: 'Input your name',
          ),
        ),


      ],


    );
  }
//
// Widget bottomSheet(){
//
// }
// @override
// void debugFillProperties(DiagnosticPropertiesBuilder properties) {
//   super.debugFillProperties(properties);
//   properties.add(DiagnosticsProperty<PickedFile>('_imageFile', _imageFile));
// }
}
