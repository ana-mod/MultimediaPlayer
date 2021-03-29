import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';

import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'Media.dart';

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
  Text formatDate(DateTime date) {
    String data = date.day.toString() +
        '.' +
        date.month.toString() +
        '.' +
        date.year.toString();

    return Text('$data');
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

class PhotoDetails extends StatefulWidget {
  final String imagePath;
  PhotoDetails({Key key, this.imagePath});

  @override
  State<StatefulWidget> createState() => PhotoDetailsState();
}

class PhotoDetailsState extends State<PhotoDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo details')),
      body: Container(
        child: PhotoView(
          imageProvider: FileImage(File(widget.imagePath)),
        ),
      ),
    );
  }
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(CupertinoIcons.camera),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image?.path,
                  camera: widget.camera,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
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

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final CameraDescription camera;
  const DisplayPictureScreen({Key key, this.imagePath, this.camera})
      : super(key: key);

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.file(File(widget.imagePath)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: Icon(CupertinoIcons.camera_fill),
                    onPressed: () => {print("okejka")}),
                IconButton(
                    icon: Icon(CupertinoIcons.bubble_middle_bottom_fill),
                    onPressed: () => {print("okejka")}),
                TextButton(
                    child: Text('ok'), onPressed: () => {this.savePhoto()})
              ],
            )
          ],
        ));
  }

  void savePhoto() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final byteData = bytes.buffer.asUint8List();

      final result = await ImageGallerySaver.saveImage(byteData, quality: 60);
      Media media =
          new Media(widget.imagePath, 'APhoto #', DateTime.now(), false);
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
}

//change this camera passing all the way cause sheeesh
