import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'HomeView.dart';


Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: HomeView(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}



enum MediaType { image, video, voice }

/*// A widget to edit taken photo
class EditPhoto extends StatefulWidget {
  final String imagePath;

  const EditPhoto({Key key, this.imagePath}) : super(key: key);

  @override
  EditPhotoState createState() => EditPhotoState();
}

class EditPhotoState extends State<EditPhoto> {
  File imageFile;
  String fileName;
  List<Filter> filters = presetFiltersList;
File croppedFile;

  Future<Null> cropImage() async {
    croppedFile = await ImageCropper.cropImage(
        sourcePath: widget.imagePath,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
  }

  Future getImage(context) async {

    imageFile = File(widget.imagePath);

    Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new PhotoFilterSelector(
          title: Text("Photo Filter Example"),
          image: Image.file(imageFile),
          filters: presetFiltersList,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
      });
      print(imageFile.path);
    }

  }

  @override
  void initState() {
    super.initState();
    //cropImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit your pic')),
      body: Image.file(croppedFile),
      floatingActionButton:
          new FloatingActionButton(onPressed: () => getImage(context)),
    );
  }
}*/


//change this camera passing all the way cause sheeesh
