import 'package:flutter/services.dart' show rootBundle;
import 'dart:core';

const String _booksDir = "assets/books/";
const String _booksCSV = "${_booksDir}books.csv";

enum PageType { special, other }

// Holds the data associated with one page
class PageData {
  int book, level, sublevel;
  PageType specialpage;
  String? soundfile;
  String pic;

  PageData(this.book, this.level, this.sublevel, this.pic, this.specialpage,
      this.soundfile);
}

// Loads pages from _flashcards into cards, filtered by level and sublevel
Stream<PageData> loadPages([int? level, int? sublevel]) async* {
  String bookContents = await rootBundle.loadString(_booksCSV);
  List<String> lines = bookContents.split('\n');
  for (String line in lines) {
    if (line.isEmpty) continue;

    List<String> entries = line.split(',');

    for (int pageNum = int.parse(entries[3]);
        pageNum <= int.parse(entries[4]);
        pageNum++) {
      PageData page = PageData(
        int.parse(entries[0]),
        int.parse(entries[1]),
        int.parse(entries[2]),
        "$_booksDir$pageNum.png",
        ((int.parse(entries[3]) == 0) ? PageType.other : PageType.special),
        entries[4].isEmpty ? null : _booksDir + entries[4],
      );

      if ((level == null || page.level == level) &&
          (sublevel == null || page.sublevel == sublevel)) yield page;
    }
  }
}
