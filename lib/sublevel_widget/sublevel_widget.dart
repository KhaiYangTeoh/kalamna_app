import 'package:flutter/material.dart';
import '../flashcard/flashcard_widget.dart';
import '../flashcard/flashcard_data.dart';
import '../assessments/assessment_widget.dart';
import '../assessments/assessment_data.dart';

// Widget to perform a sublevel and save
class SublevelWidget extends StatefulWidget {
  final int level, sublevel;
  final VoidCallback onReturn;
  final VoidCallback? onDone;

  SublevelWidget({
    super.key,
    required this.level,
    required this.sublevel,
    required this.onReturn,
    this.onDone,
  }) {}

  @override
  State<SublevelWidget> createState() => _SublevelWidgetState(
      level, sublevel, onReturn, onDone ?? onReturn);
}

// State for SublevelWidget
class _SublevelWidgetState extends State<SublevelWidget> {
  final int level, sublevel;
  final VoidCallback onReturn, onDone;
  AssessmentStreamWidget? assessments;
  FlashcardStreamWidget? cards;
  bool showCards = true;

  _SublevelWidgetState(
      this.level, this.sublevel, this.onReturn, this.onDone) {
    cards = FlashcardStreamWidget(
      cards: _getFlashcards(),
      onReturn: onReturn,
      onDone: () => _onCardsDone(),
      addDragAndDrop: true,
    );

    assessments = AssessmentStreamWidget(
        assessments: loadAssessment(level, sublevel),
        returnToMenu: onReturn,
        onDone: onDone);
  
  }

  // Gets flashcards for the current sublevel
  Stream<FlashcardData> _getFlashcards() async* {
    Stream<FlashcardData> letterCards = loadFlashcards(level, sublevel, FlashcardType.letterForm);
    await for (FlashcardData card in letterCards) {
        yield card;
    }

    Stream<FlashcardData> wordCards = loadFlashcards(level, sublevel, FlashcardType.pictureWord);

    await for (FlashcardData card in wordCards) {
        yield card;
    }
  }

  // Manages transition from flashcards to assessments
  void _onCardsDone() {
    setState(() {
      showCards = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showCards ? cards! : assessments!;
  }
}
