import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled18/service/database.dart';

class Allvideos extends StatefulWidget {
  final String image, name, id, count;

  Allvideos(
      {super.key,
        required this.name,
        required this.image,
        required this.count,
        required this.id});

  @override
  State<Allvideos> createState() => _AllvideosState();
}

class _AllvideosState extends State<Allvideos> {
  Stream? videoStream;

  getonheload () async {
    videoStream = await DatabaseMethods().getAllVideos(widget.id);
    setState(() {

    });

  }

  @override
  void initState() {
    getonheload();
    super.initState();
  }


  Widget allVideos() {
    return StreamBuilder(
      stream: videoStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return const Center(child: Text("No courses available"));
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot course = snapshot.data.docs[index];
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Allvideos(
                        count: course['Count'],
                        id: course['Id'],
                        name: course['Course'],
                        image: course['Image'],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(
                    course['Image'],
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ));
          },
        );
      },
    );
  }

  final TextEditingController youtubeVideoController = TextEditingController();
  String? getYoutubeThumbnail(String videoUrl) {
    final Uri? uri = Uri.tryParse(videoUrl);
    if (uri == null) {
      return null;
    }
    return 'https://img.youtube.com/vi/${uri.queryParameters['v']}/0.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialog();
        },
        child: Icon(Icons.add),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 60.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        widget.image,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              Material(
                elevation: 5.0,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
        
                  ),
                  child: Expanded(child: Column(
                    children: [
                      allVideos(),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Open dialog function for adding YouTube link
  Future openDialog() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.cancel),
          ),
          SizedBox(width: 10),
          Text('Add Video'),
        ],
      ),
      content: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.0),
            Text('Add YouTube Link'),
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: youtubeVideoController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter Link',
                ),
              ),
            ),
            SizedBox(height: 30.0),
            GestureDetector(
              onTap: () {
                // Handle the save functionality here
                if (youtubeVideoController.text.isNotEmpty) {
                  // Save the video link or process further
                  print('YouTube Link: ${youtubeVideoController.text}');
                  Navigator.pop(context);
                }
              },
              child: GestureDetector(
                onTap: () async {
                  String? thumbnail = await getYoutubeThumbnail(
                      youtubeVideoController.text);

                  int total = int.parse(widget.count);
                  total = total + 1;
                  Map<String, dynamic> addVideo = {
                    'Image': thumbnail,
                    'Link': youtubeVideoController.text,
                  };

                  await DatabaseMethods()
                      .updateCount(widget.id, total.toString());
                  await DatabaseMethods().addVideo(addVideo, widget.id);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}