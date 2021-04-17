// A screen that allows users to take a picture using a given camera.
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TakeVideoScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakeVideoScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakeVideoScreenState createState() => TakeVideoScreenState();
}

class TakeVideoScreenState extends State<TakeVideoScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  Future<void> startVideoRecording() async {
    final CameraController cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return;
    }
  }

  Future<XFile> stopVideoRecording() async {
    final CameraController cameraController = _controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(CupertinoIcons.camera),
        onPressed: () async {
          if (!_controller.value.isInitialized) {

            return null;

          }

          if (_controller.value.isRecordingVideo) {

            return null;

          }
          final Directory appDirectory = await getApplicationDocumentsDirectory();

          final String videoDirectory = '${appDirectory.path}/Videos';

          await Directory(videoDirectory).create(recursive: true);

          final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

          final String filePath = '$videoDirectory/${currentTime}.mp4';

          try {
            startVideoRecording();
             sleep(Duration(seconds: 4));

              XFile videoFile = await stopVideoRecording();
              print(videoFile.path);//and there is more in this XFile object


          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
