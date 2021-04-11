import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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