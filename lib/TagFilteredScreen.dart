import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Media.dart';
import 'PhotoDetails.dart';

class TagFilteredScreen extends StatefulWidget {
  final String tag;

  const TagFilteredScreen({Key key, this.tag}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TagFilteredScreenState();
}

class TagFilteredScreenState extends State<TagFilteredScreen> {
  @override
  Widget build(BuildContext context) {
    final filteredMedia = this.filter(widget.tag);

    return Scaffold(
      appBar: AppBar(title: Text(widget.tag)),
      body: filteredMedia.length > 0
          ? ListView.separated(
              itemCount: filteredMedia.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                    onLongPress: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PhotoDetails(
                                      imagePath:
                                          filteredMedia[index].imagePath)))
                        },
                    child: Container(
                      height: 100,
                      color: Colors.blue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image(
                              image: Image.file(
                                      File(filteredMedia[index].imagePath))
                                  .image),
                          Text(filteredMedia[index].name),
                          formatDate(filteredMedia[index].date),
                          Icon(filteredMedia[index].favourite
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
    );
  }

  List<Media> filter(String tag) {
    return savedFiles.where((value) => (value.tags.contains(tag) || value.name.contains(tag))).toList();
  }

  Text formatDate(DateTime date) {
    String data = date.day.toString() +
        '.' +
        date.month.toString() +
        '.' +
        date.year.toString();

    return Text('$data');
  }
}
