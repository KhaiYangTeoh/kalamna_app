import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:collection';
import 'package:audioplayers/audioplayers.dart';

const String _flashcardsDir = "assets/flashcards/";
const String _flashcardsCSV = _flashcardsDir + "flashcards.csv";
const String _wordsCSV = _flashcardsDir + "flashcardtxt.csv";

// Indicates the type of flashcard to store
enum FlashcardType {
  letterForm,
  pictureWord,
}

// Holds the data associated with one flashcard
class FlashcardData {
  int id, level, sublevel;
  FlashcardType type;
  String pic1;
  String? pic2;
  String? soundFile;
  String? word;

  FlashcardData(this.id, this.level, this.sublevel, this.type, this.pic1,
      this.pic2, this.soundFile);
}

// Loads flashcards from _flashcards into cards, filtered by level and sublevel
// S: Added filter for card type (makes this a little repetitive to call)
Stream<FlashcardData> loadFlashcards(
    [int? level = null,
    int? sublevel = null,
    FlashcardType? type = null]) async* {
  String cardContents = await rootBundle.loadString(_flashcardsCSV);
  List<String> lines = cardContents.split('\n');
  //added .shuffle() to give random order
  lines.shuffle();

  Map<int, String> words = await _loadWords();

  for (String line in lines) {
    if (line.isEmpty) continue;

    List<String> entries = line.split(',');

    FlashcardData card = FlashcardData(
      int.parse(entries[0]),
      int.parse(entries[1]),
      int.parse(entries[2]),
      ((int.parse(entries[3]) == 0)
          ? FlashcardType.letterForm
          : FlashcardType.pictureWord),
      _flashcardsDir + entries[4],
      (entries[5].isEmpty) ? null : _flashcardsDir + entries[5],
      (entries.length < 7 || entries[6].isEmpty)
          ? null
          : "flashcards/${entries[6]}",
    );

    if (words.containsKey(card.id)) card.word = words[card.id];

    if ((level == null || card.level == level) &&
        (sublevel == null || card.sublevel == sublevel) &&
        (type == null || card.type == type)) yield card;
  }
}

// Generates a map from flashcard ids to words
Future<Map<int, String>> _loadWords() async {
  String wordsContents = await rootBundle.loadString(_wordsCSV);
  Map<int, String> map = HashMap<int, String>();

  for (String line in wordsContents.split('\n')) {
    if (line.isEmpty) continue;

    List<String> entries = line.split(',');
    if (entries.length != 2 && entries[1].isEmpty) continue;

    int id = int.parse(entries[0]);
    map[id] = entries[1];
  }

  return map;
}
