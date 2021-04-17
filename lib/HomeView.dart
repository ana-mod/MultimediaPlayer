import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dumb_flutter_app/TagFilteredScreen.dart';
import 'package:dumb_flutter_app/TakeVideoScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Media.dart';
import 'PhotoDetails.dart';
import 'TakePictureScreen.dart';

class HomeView extends StatefulWidget {
  final CameraDescription camera;

  const HomeView({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final myController = TextEditingController();

  Text formatDate(DateTime date) {
    String data = date.day.toString() +
        '.' +
        date.month.toString() +
        '.' +
        date.year.toString();

    return Text('$data');
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Widget popup() => PopupMenuButton<MediaType>(
        onSelected: (MediaType choice) {
          setState(() {
            route(choice);
          });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MediaType>>[
          const PopupMenuItem<MediaType>(
              value: MediaType.photo, child: Text('Take a photo')),
          const PopupMenuItem<MediaType>(
              value: MediaType.video, child: Text('Take a video')),
          const PopupMenuItem<MediaType>(
              value: MediaType.recording, child: Text('Take a voice record'))
        ],
        icon: Icon(CupertinoIcons.add_circled),
      );

  route(MediaType choice) {
    switch (choice) {
      case MediaType.photo:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TakePictureScreen(camera: widget.camera)));
        break;
      case MediaType.video:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TakeVideoScreen(camera: widget.camera)));
        break;
      case MediaType.recording:
        print("rec");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multimedia Player')),
      body: savedFiles.length > 0
          ? ListView.separated(
              itemCount: savedFiles.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        savedFiles[index].favourite =
                            !savedFiles[index].favourite;
                      });
                    },
                    onPanUpdate: (details) {
                      if (details.delta.dx < 0) {
                        savedFiles.removeAt(index);
                        setState(() {});
                      }
                    },
                    onLongPress: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PhotoDetails(
                                      imagePath: savedFiles[index].imagePath)))
                        },
                    child: Container(
                      height: 100,
                      color: Colors.blue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image(
                              image:
                                  Image.file(File(savedFiles[index].imagePath))
                                      .image),
                          Text(savedFiles[index].name),
                          formatDate(savedFiles[index].date),
                          Icon(savedFiles[index].favourite
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart)
                        ],
                      ),
                    ));
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            )
          : Center(child: const Text('No items')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[200],
        child: popup(),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Choose sorting key')),
            CupertinoSearchTextField(
              style: TextStyle(color: Colors.white),
              controller: myController,
              onSubmitted: (value) {
                print("Submitted text: " + value);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TagFilteredScreen(tag: value),
                  ),
                );
                savedFiles.where((x) => x.tags.contains(x)).toList();
              },
            ),
            ListTile(
              title: Text('Sort by name'),
              onTap: () {
                setState(() {
                  savedFiles.sort((a, b) => a.name.compareTo(b.name));
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('Sort by date'),
              onTap: () {
                setState(() {
                  savedFiles.sort((a, b) => a.date.compareTo(b.date));
                  Navigator.pop(context);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
