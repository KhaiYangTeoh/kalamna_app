import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kalamna_app/assessments/assessment_data.dart';
import 'package:kalamna_app/assessments/assessment_widget.dart';
import 'package:provider/provider.dart';
import 'interactive_cards/arabic_parser.dart';
import 'package:kalamna_app/end_of_level/book_data.dart';
import 'end_of_level/book_widget.dart';
import 'package:provider/provider.dart';
import 'sublevel_widget/sublevel_widget.dart';
import 'dart:math';

import 'menu_selection_pages/main_menu.dart';
import 'tutorial/tutorial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Builds the app
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // ChangeNotifierProvider: allows any widget in app to get whole of the state
          create: (context) => MyAppState(),
        ),
        ChangeNotifierProvider<ArabicParser>(
          create: (context) => ArabicParser.fromContext(context),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Kalamna App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const Scaffold(body: MainMenuPage()),
      ),
    );
  }
}

// Function to do nothing
void doNothing() {}

// Widget created for testing pages
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  final int level = 2;
  final int subLevel = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   body: AssessmentStreamWidget(
      //       assessments: loadAssessment(), returnToMenu: () {}, onDone: () {}));
      appBar: AppBar(title: Text("Level $level - Book $subLevel")),
      body: PageStreamWidget(
        // level, sublevel as params
        pages: loadPages(level, subLevel),
        returnToMap: doNothing,
        returnToLibrary: doNothing,
        onDone: doNothing,
      ),
      //  body:
      //  SublevelWidget(level: 1, sublevel: 3, onDone: () {}, onReturn: () {}),
      //  body: AssessmentStreamWidget(
      //      assessments: loadAssessment(), returnToMenu: () {}, onDone: () {})
      //  appBar: AppBar(title: Text("Level $level - Book $subLevel")),
      //  body: PageStreamWidget(
      //  // level, sublevel as params
      //  pages: loadPages(level, subLevel),
      //  returnToMap: doNothing,
      //  returnToLibrary: doNothing,
      //  onDone: doNothing,
      //  ),
    );
  }
}

// Class that stores the state of global variables
class MyAppState extends ChangeNotifier {
  // Gender Selection Code
  // List of Accepted Genders
  final List<String> genders = [
    "boy",
    "girl",
    "brothers",
    "sisters",
    "siblings",
  ];

  // Current selected gender
  String gender = "";

  // Change gender
  void toggleGender(String gender) {
    if (genders.contains(gender)) {
      this.gender = gender;
    } else {
      throw UnimplementedError("No such gender for $gender");
    }
  }

  // Level Selection Code
  // List of Accepted Stages
  final List<double> levelsList = [
    // Stage 1
    1.1,
    1.2,
    1.3,
    1.4,
    // Stage 2
    2.1,
    2.2,
    // Stage 3
    3.1,
    3.2,
    3.3,
    3.4,
    // Stage 4
    4.1,
    4.2,
    4.3,
    4.4,
    // Stage 5
    5.1,
    5.2,
    5.3,
    5.4,
  ];

  // Current unlocked level
  double unlockedLevels = 0.0;

  // Change unlocked level
  void unlockLevel(double level) {
    if (levelsList.contains(level)) {
      unlockedLevels = min(unlockedLevels, level);
    } else {
      throw UnimplementedError("No such level for $level");
    }
  }

  // Book Selection Code
  // List of accepted books
  final List<double> booksList = [
    // Book 1
    1.1,
    1.2,
    // Book 2
    2.1,
    2.2,
    // Book 3
    3.1,
    3.2,
    3.3,
    // Book 4
    4.1,
    4.2,
    // Book 5
    5.1,
  ];

  // Current unlocked book
  double unlockedBooks = 0;

  // Change unlocked book
  void unlockBook(double book) {
    if (booksList.contains(book)) {
      unlockedBooks = min(unlockedBooks, book);
    } else {
      throw UnimplementedError("No such book for $book");
    }
  }

  // Current unlocked chest
  int unlockedChest = 0;

  // Change unlocked chest
  void unlockChest(int chest) {
    if (chest > 0 && chest <= 5) {
      unlockedChest = min(unlockedChest, chest);
    } else {
      throw UnimplementedError("No such chest for $chest");
    }
  }

  // First time launch
  bool firstTime = true;

  // Function for indicating tutorial was completed
  void completedTutorial() {
    firstTime = false;
  }
}

// Function to navigate to the next page
void navigateTo(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(body: page),
    ),
  );
}

// Function to navigate back from a page
void backButton(BuildContext context) {
  Navigator.pop(context);
}
