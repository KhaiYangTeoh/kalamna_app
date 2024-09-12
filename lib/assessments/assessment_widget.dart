import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'assessment_data.dart';
import 'package:confetti/confetti.dart';

String mapIcon = 'assets/icons/MAP_ICON.svg';

Color _blue = Color(0xff09b6f6);
Color _orange = Color(0xFFF69621);
Color _purple = Color(0xFF764F90);
Color _green = Color(0xFFCEDD47);
Color _aqua = Color(0xFF0DB3A2);
Color _grey = Color(0xff7f7f7f);

Map colours = {1: _blue, 2: _orange, 3: _aqua, 4: _green, 5: _purple};

// defining a confetti controller
ConfettiController confetti =
    ConfettiController(duration: Duration(seconds: 1));

// Widget to display one assessment screen
class AssessmentWidget extends StatelessWidget {
  final AssessmentData assessment;

  const AssessmentWidget({super.key, required this.assessment});

  // function to check correct answer for buttons - in this case the answer is always the first word

  // Widget to hold an image
  Widget _picWidget({required String path, required double width}) {
    // Getting path extension
    String extension = path.substring(path.length - 4);

    // allows us to cope with both svg files and other file formats
    if (extension == '.svg') {
      return Container(
        child: SvgPicture.asset(
          path,
          width: (assessment.type == AssessmentType.fillSentenceTwo)
              ? null
              : width,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(path,
          width: (assessment.type == AssessmentType.fillSentenceTwo)
              ? null
              : width,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium);
    }
  }

  // Gets the maximum displayable width in the current context
  double _width(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return (width < height / 2) ? width : height / 2;
  }

  @override
  Widget build(BuildContext context) {
    double width = _width(context);
    List<Widget> widgets = [];

    //Color widgetColor = getColour(assessment.level);

    if (assessment.type == AssessmentType.fillSentenceTwo ||
        assessment.type == AssessmentType.fillSentenceThree) {
      widgets.add(
        Center(
            child: Text(assessment.word1!,
                style: const TextStyle(
                    color: Colors.black, fontFamily: 'Kalamna', fontSize: 60),
                textAlign: TextAlign.center)),
      );
    } else if (assessment.type == AssessmentType.pictureWord) {
      widgets
          .add(Center(child: _picWidget(path: assessment.pic1!, width: width)));
    } else if (assessment.type == AssessmentType.pictureWordDrag) {
      //shuffling picture order
      // we can have a minimum of 3 pictures and words
      List<String> randomPic = [
        assessment.pic1!,
        assessment.pic2!,
        assessment.pic3!,
      ];

      // adding an optional fourth picture
      if (assessment.pic4 != null) {
        randomPic.add(assessment.pic4!);
      }

      //adding an optional fifth picture
      if (assessment.pic5 != null) {
        randomPic.add(assessment.pic5!);
      }

      randomPic.shuffle();

      //adding all 5 pictures
      List<Widget> dragDropPictures = [];

      for (String pic in randomPic) {
        dragDropPictures.add(_picWidget(path: pic, width: width / 5));
      }

      widgets.add(Column(
        children: dragDropPictures,
      ));
    }

    return Center(child: Column(children: widgets));
  }
}

// Widget to display stream of assessment pages
class AssessmentStreamWidget extends StatefulWidget {
  final Stream<AssessmentData> assessments;
  final VoidCallback returnToMenu;
  final VoidCallback onDone;

  const AssessmentStreamWidget({
    super.key,
    required this.assessments,
    required VoidCallback this.returnToMenu,
    required VoidCallback this.onDone,
  });

  @override
  State<AssessmentStreamWidget> createState() =>
      _AssessmentStreamWidgetState(assessments, returnToMenu, onDone);
}

class _AssessmentStreamWidgetState extends State<AssessmentStreamWidget> {
  final Stream<AssessmentData> _assessments;
  final VoidCallback _returnToMenu;
  final VoidCallback _onDone;
  bool streamDone = false;
  final Map<String, bool> matched = {};
  bool buttonPressed = false;
  bool incorrect = false;
  int seed = 0;

  List<AssessmentData> _assessmentList = <AssessmentData>[];
  int _assessmentIndex = 0;

  _AssessmentStreamWidgetState(
    this._assessments,
    this._returnToMenu,
    this._onDone,
  ) {
    _assessments.listen(
      _addAssessment,
      onDone: () => streamDone = true,
    );
  }

  // Adds a new assessment to the stored list
  void _addAssessment(AssessmentData newAssessment) {
    setState(() {
      _assessmentList.add(newAssessment);
    });
  }

  // Gets the index of the current assessment to display
  int _getDispIndex() {
    if (_assessmentIndex < _assessmentList.length - 1) return _assessmentIndex;
    return _assessmentList.length - 1;
  }

  // Switches to the next card
  void _nextAssessment() {
    setState(() {
      _assessmentIndex = _getDispIndex() + 1;
    });

    // Once assessment stream is done, would return to chest menu
    if (streamDone && _assessmentIndex == _assessmentList.length) _onDone();
  }

  // Gets the assessment data
  AssessmentData getAssessment() {
    return _assessmentList[_getDispIndex()];
  }

  Color getColor() {
    return colours[getAssessment().level];
  }

  // Function to randomise selection text order
  List<String> randomiseAns(AssessmentData currentAssessment) {
    List<String> randomWord = [
      currentAssessment.word2,
      currentAssessment.word3
    ];
    // If the assessment type is fillSentenceThree, then we add the extra button word into the list
    if (currentAssessment.type == AssessmentType.fillSentenceThree) {
      randomWord.add(currentAssessment.word4!);
    }
    // If the assessment type is pictureWordDrag:
    if (currentAssessment.type == AssessmentType.pictureWordDrag) {
      // word1 will always be an answer, so we add that regardless:
      randomWord.add(currentAssessment.word1!);

      // if word4 isn't null, we add it to the list
      if (currentAssessment.word4 != null) {
        randomWord.add(currentAssessment.word4!);
      }

      //same for word5:
      if (currentAssessment.word4 != null) {
        randomWord.add(currentAssessment.word4!);
      }
    }

    randomWord.shuffle();
    return randomWord;

    // If the assessment type is pictureWordDrag, then we add the extra two words into the list
  }

  // Checks if button selected is correct
  // function to check correct answer for buttons - in this case the answer is always the first word in the CSV
  Future<void> checkCorrectButton(String buttonText, String answer) async {
    AssessmentData currentAssessment = getAssessment();

    // How this works:
    // If correct button is selected:
    // ButtonText has to be the answer and a button cannot have been pressed in the last 5 seconds
    // incorrect is set to false
    // buttonPressed is set to true, preventing side effects if the user presses a button again
    // Confetti plays, and a 5 second timer allows time for the confetti to show
    // Set buttonPressed to false so the user can select the next button
    // Move onto next assessment
    // If incorrect button selected:
    // Incorrect set to true
    // Assessment is put back onto the stream so it is shown again

    if (buttonText == answer && buttonPressed == false) {
      incorrect = false;
      buttonPressed = true;
      confetti.play();
      await Future.delayed(const Duration(seconds: 5));
      buttonPressed = false;
      _nextAssessment();
    } else if (incorrect == false && buttonPressed == false) {
      incorrect = true;
      _addAssessment(currentAssessment);
    }
  }

  // Gets maximum displayable width
  double _widgetWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return (width < height / 2) ? width : height / 2;
  }

  // Gets current screen width
  double _width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Gets maximum displayable height
  double _height(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return (height < width / 2) ? height : width / 2;
  }

  // Widget to hold an image
  Widget _picWidget({required String path, required double width}) {
    // Getting path extension
    String extension = path.substring(path.length - 4);
    AssessmentData currentAssessment = getAssessment();

    // allows us to cope with both svg files and other file formats
    if (extension == '.svg') {
      return Container(
        child: SvgPicture.asset(
          path,
          width: (currentAssessment.type == AssessmentType.fillSentenceTwo)
              ? null
              : width,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(path,
          width: (currentAssessment.type == AssessmentType.fillSentenceTwo)
              ? null
              : width,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium);
    }
  }

  // Widget for selection buttons
  Widget _buttons() {
    AssessmentData currentAssessment = getAssessment();
    Color color = getColor();

    // create empty list to hold widgets
    List<Widget> widgets = [];

    // call randomiseAns
    List<String> randomWord = randomiseAns(currentAssessment);

    // only assessment type to have
    // may be able to remove this, since we would only run this code if there were two buttons
    if (currentAssessment.type != AssessmentType.pictureWordDrag) {
      // button 1
      SizedBox button1 = SizedBox(
        width: 175,
        height: 75,
        child: ElevatedButton(
            onPressed: () {
              checkCorrectButton(randomWord[0], currentAssessment.word2);
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: Text(randomWord[0],
                style: const TextStyle(
                    fontFamily: 'Kalamna', color: Colors.white, fontSize: 50))),
      );
      // button 2
      SizedBox button2 = SizedBox(
          width: 175,
          height: 75,
          child: ElevatedButton(
              onPressed: () {
                checkCorrectButton(randomWord[1], currentAssessment.word2);
              },
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: Text(randomWord[1],
                  style: const TextStyle(
                      fontFamily: 'Kalamna',
                      color: Colors.white,
                      fontSize: 50))));

      // add both to widget list
      widgets.addAll([
        Padding(padding: EdgeInsets.all(10), child: button1),
        Padding(padding: EdgeInsets.all(10), child: button2)
      ]);

      //if statement to decide if we need a third button
      if (currentAssessment.type == AssessmentType.fillSentenceThree) {
        // button 3
        SizedBox button3 = SizedBox(
            width: 175,
            height: 75,
            child: ElevatedButton(
                onPressed: () {
                  checkCorrectButton(randomWord[2], currentAssessment.word2);
                },
                style: ElevatedButton.styleFrom(backgroundColor: color),
                child: Text(randomWord[2],
                    style: const TextStyle(
                        fontFamily: 'Kalamna',
                        color: Colors.white,
                        fontSize: 50))));

        // add to widget list
        widgets.add(Padding(padding: EdgeInsets.all(10), child: button3));
      }
    }
    return (Center(
        child: Row(
      children: widgets,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    )));
  }

  Widget dragAndDrop(double width) {
    AssessmentData currentAssessment = getAssessment();

    // Create a map for each choice
    Map choices = {
      currentAssessment.word1!: currentAssessment.pic1!,
      currentAssessment.word2: currentAssessment.pic2!,
      currentAssessment.word3: currentAssessment.pic3!,
    };

    if (currentAssessment.word4 != '') {
      choices.addAll({currentAssessment.word4!: currentAssessment.pic4!});
    }

    if (currentAssessment.word5 != '') {
      choices.addAll({currentAssessment.word5!: currentAssessment.pic5!});
    }

    // create UI
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      // Column containing draggable words
      Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: choices.keys.map((word) {
            return Draggable<String>(
              data: word,
              feedback: (matched[word] == true
                  ? SizedBox.shrink()
                  : Text(word,
                      style: const TextStyle(
                          fontFamily: 'Kalamna',
                          color: Colors.black,
                          fontSize: 30))),
              childWhenDragging: SizedBox.shrink(),
              child: (matched[word] == true
                  ? SizedBox.shrink()
                  : Text(word,
                      style: const TextStyle(
                          fontFamily: 'Kalamna',
                          color: Colors.black,
                          fontSize: 30))),
            );
          }).toList()),

      // Column containing pictures to drag words to
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: choices.keys
            .map((word) => _buildDragTarget(word, width, choices))
            .toList()
          ..shuffle(Random(seed)),
      ),
    ]);
  }

  // Widget for drag target
  Widget _buildDragTarget(word, width, choices) {
    int choiceNum = choices.length;
    return DragTarget<String>(
      builder: (BuildContext context, List incoming, List rejected) {
        if (matched[word] == true) {
          return Container(
              alignment: Alignment.center,
              width: width / choiceNum,
              child: Icon(Icons.check, color: getColor()));
        } else {
          return _picWidget(path: choices[word], width: width / choiceNum);
        }
      },
      onWillAccept: (data) => data == word,
      onAccept: (data) async {
        setState(() {
          matched[word] = true;
        });
        if (matched.length == choices.length) {
          incorrect = false;
          buttonPressed = true;
          confetti.play();
          await Future.delayed(const Duration(seconds: 5));
          buttonPressed = false;
          setState(() {
            matched.clear();
            seed += 1;
            _nextAssessment();
          });
          // as this point we know this is correct, so I pass two strings that definitely match
          // getting this to not reset is proving to be VERY difficult
        }
      },
      onLeave: (data) {},
    );
  }

  // Map widget - currently only works for button selection assessments
  Widget _mapWidget(int dispIndex, double height) {
    if (height < 30) return SizedBox.shrink();

    Container returnButton = Container(
      height: height,
      width: height,
      child: TextButton(
        onPressed: _returnToMenu,
        child: SvgPicture.asset(mapIcon),
      ),
    );

    return Align(
      alignment: Alignment.topRight,
      child: returnButton,
    );
  }

  //Confetti widget
  Widget _confetti(width) {
    return Positioned(
        top: 0,
        right: (width / 2) - 15,
        child: ConfettiWidget(
          confettiController: confetti,
          blastDirectionality: BlastDirectionality.directional,
          blastDirection: 80,
          maxBlastForce: 4,
          minBlastForce: 1,
          shouldLoop: false,
          emissionFrequency: 0.1,
          colors: const [Colors.blue, Colors.pink, Colors.green],
          gravity: 0.01,
        ));
  }

  // Main UI
  @override
  Widget build(BuildContext context) {
    if (_assessmentList.length == 0) return SizedBox.shrink();
    AssessmentData currentAssessment = getAssessment();
    double widgetWidth = _widgetWidth(context);
    double width = _width(context);
    double height = _height(context);

    int dispIndex = _getDispIndex();
    AssessmentWidget assessmentWidget =
        AssessmentWidget(assessment: _assessmentList[dispIndex]);

    Column assessmentContents = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        assessmentWidget,
        _buttons(),
      ],
    );

    Border border = Border.all(color: getColor(), width: 10);

    if (currentAssessment.type != AssessmentType.pictureWordDrag) {
      return SafeArea(
          child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            _confetti(width),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _mapWidget(dispIndex, height * 0.4),
                  assessmentContents,
                  Container(height: height * 0.4),
                ])
          ],
        ),
      ));
    } else {
      return SafeArea(
          child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(children: [
          _confetti(width),
          _mapWidget(dispIndex, height * 0.4),
          dragAndDrop(widgetWidth)
        ]),
      ));
    }
  }
}
