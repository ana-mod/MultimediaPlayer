import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'HomeView.dart';
import 'Media.dart';
import 'package:path/path.dart';

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
  List<Filter> filters = presetFiltersList;
  File imageFile;
  AudioPlayer audioPlayer = AudioPlayer();
  FlutterSoundRecorder fsr = new FlutterSoundRecorder();

  @override
  void dispose() {
    myNameController.dispose();
    myTagsController.dispose();
    //imageFile.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Display the Picture')),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    icon: Icon(CupertinoIcons.crop),
                    onPressed: () => {print("crop")}),
                IconButton(
                  icon: Icon(CupertinoIcons.color_filter),
                  onPressed: () async {
                    Map imagefile = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => new PhotoFilterSelector(
                          title: Text("Apply Filters"),
                          image: imageLib.decodeImage(
                              File(widget.imagePath).readAsBytesSync()),
                          filters: presetFiltersList,
                          filename: basename(widget.imagePath),
                          loader: Center(child: CircularProgressIndicator()),
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                    if (imagefile != null &&
                        imagefile.containsKey('image_filtered')) {
                      setState(() {
                        imageFile = imagefile['image_filtered'];
                      });

                    }
                  },
                ),
                CupertinoButton.filled(
                    child: Text('SAVE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    onPressed: () => {this.savePhoto()})
              ],
            ),
            Expanded(
                child: imageFile == null
                    ? Image.file(File(widget.imagePath))
                    : RotatedBox(quarterTurns: 1, child: Image.file(imageFile),)),
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

      var path = imageFile==null ? widget.imagePath : imageFile.path;

      final bytes = await File(path).readAsBytes();
      final byteData = bytes.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(byteData, quality: 60);

      Media media = new Media(path, myNameController.text,
          DateTime.now(), false, Colors.blue, myTagsController.text.split(' '));

      savedFiles.add(media);

      _toastInfo("Saved as " + media.name);

      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => HomeView(camera: widget.camera)));
    } catch (e) {
      _toastInfo("Some error during saving occurred");
    }
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }

 /* Future<String> getPath() async {
    final dir = await getApplicationDocumentsDirectory();
    path = dir.path +
        '/' +
        DateTime.now().millisecondsSinceEpoch.toString() +
        '.m4a';

    return path;
  }

  playLocal() async {
    int result = await audioPlayer.play(path, isLocal: true);
  }*/
}
