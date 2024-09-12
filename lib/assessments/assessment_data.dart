import 'package:flutter/services.dart';

// may need to import flashcard directories
const String _assessmentsDir = "assets/assessments/";
const String _assessmentsCSV = _assessmentsDir + "assessments.csv";
const String _flashcardsDir = "assets/flashcards/";

/* 4 kinds of assessement:
  1) pictureWord: choose the word that matches the image
  2) pictureWordDrag: drag the imge to the correct word
  3) fillSentenceTwo: choose the correct  word out of two
  4) fillSentenceThree: choose the correct word out of three */
enum AssessmentType {
  pictureWord,
  pictureWordDrag,
  fillSentenceTwo,
  fillSentenceThree
}

// Class that holds data about assesment
// EXPLANATION ABOUT WORDS:
// word2 and word3 are first to contain answers
// word2 is always the answer (except in type pictureWordDrag)
// word1 contains the answer for assessments of type fillSentenceThree
// for fillSentence3, word4 is also an answer option
// all words are answer options if type is pictureWordDrag
class AssessmentData {
  int id, level, sublevel;
  AssessmentType type;
  String word2, word3;
  String? word1, word4, word5, pic1, pic2, pic3, pic4, pic5;

  AssessmentData(
      this.id,
      this.level,
      this.sublevel,
      this.type,
      this.word1,
      this.word2,
      this.word3,
      this.word4,
      this.word5,
      this.pic1,
      this.pic2,
      this.pic3,
      this.pic4,
      this.pic5);
}

//function to create a stream of assessment data
//we can filter by level and assessment type
Stream<AssessmentData> loadAssessment(
    [int? level, int? sublevel, AssessmentType? type]) async* {
  String activities = await rootBundle.loadString(_assessmentsCSV);

  // Splitting the CSV into its seperate assessment activities and shuffling them
  List<String> lines = activities.split('\n');
  lines.shuffle();

  for (String line in lines) {
    if (line.isEmpty) break;

    List<String> entries = line.split(',');

    // this switch case is used to determine the type of assessment
    AssessmentType typeParser = AssessmentType.pictureWord;

    switch (entries[3]) {
      case '1':
        {
          typeParser = AssessmentType.pictureWordDrag;
        }
        break;

      case '2':
        {
          typeParser = AssessmentType.fillSentenceTwo;
        }
        break;

      case '3':
        {
          typeParser = AssessmentType.fillSentenceThree;
        }
        break;

      default:
        break;
    }

    // null values represented as ,, in the csv file
    // in all of these need to create link to directory!
    AssessmentData assessment = AssessmentData(
        int.parse(entries[0]),
        int.parse(entries[1]),
        int.parse(entries[2]),
        typeParser,
        entries[4],
        entries[5],
        entries[6],
        entries[7],
        entries[8],
        (entries[9].isEmpty) ? null : _flashcardsDir + entries[9],
        (entries[10].isEmpty) ? null : _flashcardsDir + entries[10],
        (entries[11].isEmpty) ? null : _flashcardsDir + entries[11],
        (entries[12].isEmpty) ? null : _flashcardsDir + entries[12],
        (entries[13].isEmpty) ? null : _flashcardsDir + entries[13]);

    if ((level == null || assessment.level == level) &&
        (sublevel == null || assessment.sublevel == sublevel) &&
        (type == null || assessment.type == type)) yield assessment;
  }
}
