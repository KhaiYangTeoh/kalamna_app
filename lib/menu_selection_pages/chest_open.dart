import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kalamna_app/end_of_level/book_data.dart';
import 'package:kalamna_app/end_of_level/book_widget.dart';
import 'package:kalamna_app/main.dart';
import 'package:kalamna_app/menu_selection_pages/level_selection.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'library_page.dart';

// Widget for implementing the chest with the final assessment
class ChestOpenPage extends StatefulWidget {
  final int chest;

  const ChestOpenPage({super.key, required this.chest});

  @override
  State<ChestOpenPage> createState() => _ChestOpenPageState(chest);
}

// State for the Chest Widget
class _ChestOpenPageState extends State<ChestOpenPage> {
  int level;

  _ChestOpenPageState(this.level);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // Obtaining screen width and height
    // In this case screenWidth is limited to 800 units
    double screenWidth = min(MediaQuery.of(context).size.width, 800);
    double screenHeight = MediaQuery.of(context).size.height;

    // Function for the books that is displayed after each assessment is completed
    // Function takes in a String for debug message, Widget for the next page, String for the icon of the book cover and a double for the level of restriction of the book
    Padding button(
        String debug, Widget nextPage, String bookCover, double restriction) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: screenWidth * 0.25,
          width: screenWidth * 0.25,
          child: Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RawMaterialButton(
                  onPressed: () {
                    debugPrint("$debug button pressed");
                    //if (restriction <= appState.unlockedBooks) {
                    navigateTo(context, nextPage);
                    //}
                  },
                  fillColor: const Color(0xFF0DB3A2),
                  shape: const RoundedRectangleBorder(),
                  constraints: BoxConstraints(
                      minHeight: screenWidth * 0.25,
                      minWidth: screenWidth * 0.25),
                  child: Image.asset(bookCover),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Function for returning to LevelSelectionPage
    void returnToMap() {
      navigateTo(context, const LevelSelectionPage());
    }

    //  Function for returning to ChestOpenPage
    void returnToChest() {
      navigateTo(context, ChestOpenPage(chest: level));
    }

    // Function to call when done with the book
    void onDone() {}

    // Function to create a book to be displayed
    // Function takes in an argument of the level of the book and the cover icon of the book
    Padding createBook(double lev, String bookCover) {
      int level = lev.toInt();
      int sublevel = ((lev - level) * 10).toInt();
      return button(
          "word",
          PageStreamWidget(
              pages: loadPages(level, sublevel),
              returnToMap: returnToMap,
              returnToLibrary: returnToChest,
              onDone: onDone),
          bookCover,
          lev);
    }

    // List of List of Books seperated by level
    final List<List<Padding>> buttons = [
      [
        createBook(1.1, 'assets/books/1100.png'),
        createBook(1.2, 'assets/books/1200.png'),
      ],
      [
        createBook(2.1, 'assets/books/2100.png'),
        createBook(2.2, 'assets/books/2200.png'),
      ],
      [
        createBook(3.1, 'assets/books/3100.png'),
        createBook(3.2, 'assets/books/3200.png'),
        createBook(3.3, 'assets/books/3300.png'),
      ],
      [
        createBook(4.1, 'assets/books/4100.png'),
        createBook(4.2, 'assets/books/4200.png'),
      ],
      [
        createBook(5.1, 'assets/books/5100.png'),
      ],
    ];

    // Renders the scene for ChestOpenPage
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: const Alignment(0, 0.35),
            child: SvgPicture.asset('assets/TREASURE_CHEST/CHEST_3A.svg',
                height: screenHeight * 0.5),
          ),
          Align(
            alignment: const Alignment(0, -0.55),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...buttons[level - 1],
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.98, -0.98),
            child: Container(
              height: screenWidth * 0.14,
              width: screenWidth * 0.14,
              child: Card(
                shape: const CircleBorder(),
                margin: const EdgeInsets.all(0.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  color: const Color(0xff09b6f6),
                  iconSize: screenWidth * 0.1,
                  onPressed: () {
                    debugPrint("Back button pressed");
                    navigateTo(context, const LevelSelectionPage());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
