import 'package:cloud_firestore/cloud_firestore.dart';

import 'Utility.dart' as util;


void savePostInformation(
    var title,
    var category,
    var content,
    var uploadTime,
    var myName,
    var myImage,
    var myEmail) {

  var contentId = util.generateRandomString(20);

  FirebaseFirestore.instance.collection('posts').doc(contentId).set({
    "title" : title,
    "category" : category,
    "content" : content,
    "uploadTime" : uploadTime,
    "writerName" : myName,
    "writerEmail" : myEmail,
    "writerImage" : myImage
  });
}