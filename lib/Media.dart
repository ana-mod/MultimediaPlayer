class Media {
  final String imagePath, name;
  final DateTime date;
  bool favourite;

  Media(this.imagePath, this.name, this.date, this.favourite);
}

List<Media> savedFiles = [];