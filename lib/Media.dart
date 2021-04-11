import 'package:flutter/cupertino.dart';

class Media {
  final String imagePath, name;
  final DateTime date;
  bool favourite;
  Color color;
  List<String> tags;
  Media(this.imagePath, this.name, this.date, this.favourite, this.color, this.tags);
}

List<Media> savedFiles = [];