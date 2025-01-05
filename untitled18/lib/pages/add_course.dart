import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:untitled18/service/database.dart';

class AddCourse extends StatefulWidget {
  const AddCourse({super.key});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  TextEditingController courseController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  uploadItem() async {
    if (selectedImage != null && courseController.text.isNotEmpty) {
      String addID = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('blogImage').child(addID);
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      var downloadUrl = await (await task).ref.getDownloadURL();

      Map<String, dynamic> userInfoMap = {
        'Image': downloadUrl,
        'Course': courseController.text,
        'Count': '0',
        'Id': addID,
      };
      await DatabaseMethods().addCourse(userInfoMap, addID).then((value) {
        Fluttertoast.showToast(
          msg: 'Course has been uploaded successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }).catchError((e) {
        print(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Course',
          style: TextStyle(fontSize: 30, color: Colors.black),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 30, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload the Course banner Picture',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(
              height: 20.0,
            ),
            selectedImage == null
                ? GestureDetector(
              onTap: getImage,
              child: Center(
                child: Material(
                  elevation: 4.0,
                  child: Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            )
                : Center(
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Course Name',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              width: double.infinity, // Make the TextField take full width
              decoration: BoxDecoration(
                color: Color(0xffececf8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: courseController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Course Name',
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            GestureDetector(
              onTap: uploadItem,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.0), // Increased height for the button
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(10), // Rounded corners for the button
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
