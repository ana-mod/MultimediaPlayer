import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'HomeView.dart';
import 'Media.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final CameraDescription camera;
  const DisplayPictureScreen({Key key, this.imagePath, this.camera})
      : super(key: key);

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final myNameController = TextEditingController();
  final myTagsController = TextEditingController();

  String path;
  AudioPlayer audioPlayer = AudioPlayer();
  FlutterSoundRecorder fsr = new FlutterSoundRecorder();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myNameController.dispose();
    myTagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    icon: Icon(CupertinoIcons.crop),
                    onPressed: () => {print("okejka")}),
                IconButton(
                    icon: Icon(CupertinoIcons.color_filter),
                    onPressed: () => {print("okejka")}),
                CupertinoButton.filled(
                    child: Text('SAVE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, )
                         ),
                    onPressed: () => {this.savePhoto()})
              ],
            ),
            Expanded(child: Image.file(File(widget.imagePath))),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        decoration: InputDecoration(
                          hintText: "Name",
                          border: OutlineInputBorder(),
                        ),
                        controller: myNameController)),
                Expanded(
                    child: TextField(
                        decoration: InputDecoration(
                            hintText: "Tags (max 3)",
                            border: OutlineInputBorder()),
                        controller: myTagsController)),
              ],
            ),
          ],
        ));
  }

  void savePhoto() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final byteData = bytes.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(byteData, quality: 60);
      Media media = new Media(widget.imagePath, myNameController.text, DateTime.now(),
          false, Colors.blue, myTagsController.text.split(' '));

      savedFiles.add(media);

      _toastInfo("Saved as " + media.name);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeView(camera: widget.camera)));
    } catch (e) {
      _toastInfo("Some error during saving occurred");
    }
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }

  Future<String> getPath() async {
    final dir = await getApplicationDocumentsDirectory();
    path = dir.path +
        '/' +
        DateTime.now().millisecondsSinceEpoch.toString() +
        '.m4a';

    return path;
  }

  playLocal() async {
    int result = await audioPlayer.play(path, isLocal: true);
  }
}
