import 'dart:io';

import 'package:camera/camera.dart';
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
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
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
                        setState(() {
                          savedFiles.removeAt(index);
                        });
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
        child: Icon(CupertinoIcons.add_circled),
        onPressed: () => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TakePictureScreen(camera: widget.camera)))
        },
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Choose sorting key')),
            TextField(controller: myController),
            IconButton(
              //if myController.text is null make Toast Dummy
              //else search in tags, display,
                icon: Icon(Icons.search),
                onPressed: () => {print(myController.text)}),
            ListTile(
              title: Text('sort by name'),
              onTap: () {
                setState(() {
                  savedFiles.sort((a, b) => a.name.compareTo(b.name));
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('sort by date'),
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
