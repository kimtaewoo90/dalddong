import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dalddong/commonScreens/config.dart';
import 'package:dalddong/commonScreens/shared_app_bar.dart';
import 'package:flutter/material.dart';

class SearchFromPhone extends StatefulWidget {
  const SearchFromPhone({Key? key}) : super(key: key);

  @override
  State<SearchFromPhone> createState() => _SearchFromPhoneState();
}

class _SearchFromPhoneState extends State<SearchFromPhone> {

  List<Contact>? contacts;
  QuerySnapshot? users;
  List<QueryDocumentSnapshot>? dalddongContacts;
  String? user;
  List<String> phoneNumbers = [];

  @override
  void initState()  {
    super.initState();
  }

  Future<List<Contact>> _getContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    return contacts.toList();
  }


  @override
  Widget build(BuildContext context) {

    return SafeArea(
      top: false,
      bottom: false,

      child: Scaffold(
        backgroundColor: GeneralUiConfig.backgroundColor,
        appBar: BaseAppBar(
          appBar: AppBar(),
          title: '전화번호부',
          backBtn: true,
          isCreateChatRoom: false,
          center: true,
          hasIcon: false,
          hasLogout: false,
        ),
        body: FutureBuilder(
          future: _getContacts(),
          builder: (context,snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            else if (snapshot.hasData) {
              List<Contact> contacts = snapshot.data!;
              contacts.forEach((element) {
                phoneNumbers.add(element.phones!.first.value!);
              });

              print(phoneNumbers);
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('user')
                    .where('phoneNumber', whereIn: phoneNumbers)
                    .get(),
                builder: (context, phoneSnapshot){
                  print('future phone snapshot');
                  if(!phoneSnapshot.hasData){
                    return const Center(child: Text("연락처 리스트 중 달똥가입자가 없습니다."),);
                  } else{
                    return ListView.builder(
                        itemCount: phoneSnapshot.data?.docs.length,
                        itemBuilder: (context, index){
                          return ListTile(
                              title: Text(phoneSnapshot.data?.docs[index].get('userName')),
                              subtitle: Text(phoneSnapshot.data?.docs[index].get('userEmail')),
                              leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(phoneSnapshot
                                      .data?.docs[index]['userImage'])),
                              trailing: ElevatedButton(
                                child: const Text('선택'),
                                onPressed: (){},
                              )
                          );
                        });








                      // phoneSnapshot.data?.docs.forEach((element) {
                      //   dalddongContacts!.add(element);
                      //   print(element.id);
                      // });
                      //
                      // print(dalddongContacts?.length);
                      // if(dalddongContacts == null){
                      //   return const Center(child: Text("연락처 리스트 중 달똥가입자가 없습니다."),);
                      //
                      // }else{
                      //   return ListView.builder(
                      //     itemCount: dalddongContacts?.length,
                      //     itemBuilder: (BuildContext context, int index) {
                      //       return ListTile(
                      //           title: Text(dalddongContacts![index].get('userImage')),
                      //           subtitle: Text(dalddongContacts![index].get('userName')),
                      //           leading: Icon(dalddongContacts![index].get('userImage')),
                      //           trailing: ElevatedButton(
                      //           child: const Text('선택'),
                      //           onPressed: (){},
                      //       )
                      //       );
                      //     }
                      //   );
                      // }
                  }


                },
              );

            } else {
              return const Center(child: Text("Error loading contacts"));
            }
          },
        )


        // FutureBuilder<List<Contact>>(
        //   future: _getContacts(),
        //   builder: (context, snapshot){
        //     if(snapshot.hasData){
        //       snapshot.data?.forEach((contactsElement) async {
        //         print(contactsElement.phones);
        //         contactsElement.phones?.forEach((phoneNumbers) async {
        //           users = await FirebaseFirestore.instance
        //               .collection('user')
        //               .where('phoneNumber', isEqualTo: phoneNumbers.value)
        //               .get();
        //
        //           print(phoneNumbers.value);
        //           print(users?.docs.length);
        //           users?.docs.forEach((element) {
        //             dalddongContacts?.add(element);
        //           });
        //
        //         });
        //       });
        //
        //       if(dalddongContacts == null){
        //         return const Center(
        //           child: Text("없음"),
        //         );
        //
        //       } else {
        //         return ListView.separated(
        //           itemCount: dalddongContacts!.length,
        //           separatorBuilder: (BuildContext context, int index) => const Divider(),
        //           itemBuilder: (BuildContext context, int index) {
        //
        //             return ListTile(
        //               title: Text(dalddongContacts![index].get('userImage')),
        //               subtitle: Text(dalddongContacts![index].get('userName')),
        //               leading: Icon(dalddongContacts![index].get('userImage')),
        //               trailing: ElevatedButton(
        //                 child: const Text('선택'),
        //                 onPressed: (){},
        //               ),
        //               onTap: () {
        //                 // do something when the item is tapped
        //               },
        //             );
        //           },
        //         );
        //       }
        //     } else{
        //       return Container(
        //         alignment: Alignment.center,
        //         child: const CircularProgressIndicator(),
        //       );
        //     }
        //
        //   },
        // )





      ),
    );
  }
}


