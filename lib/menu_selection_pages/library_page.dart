import 'package:flutter/material.dart';
import 'package:kalamna_app/end_of_level/book_data.dart';
import 'package:kalamna_app/end_of_level/book_widget.dart';
import 'package:kalamna_app/main.dart';
import 'package:kalamna_app/menu_selection_pages/home_screen.dart';
import 'package:kalamna_app/menu_selection_pages/level_selection.dart';
import 'dart:math';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtaining screen width
    // In this case screenWidth is limited to 800 units
    double screenWidth = min(MediaQuery.of(context).size.width, 800);

    // Function for the display button for the book
    Card button(
        String debug, Widget nextPage, String book, double restriction) {
      return Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RawMaterialButton(
              onPressed: () {
                debugPrint("$debug button pressed");
                // appState.unlockedBooks
                if (restriction <= 100) {
                  navigateTo(context, nextPage);
                }
              },
              fillColor: const Color(0xFF0DB3A2),
              shape: const RoundedRectangleBorder(),
              constraints: const BoxConstraints(minHeight: 150, minWidth: 150),
              child: Image.asset(book),
            ),
          ),
        ),
      );
    }

    GridView gridBuilder(List<Card> stage) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stage.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
        ),
        itemBuilder: (context, i) => stage[i],
      );
    }

    Padding namePadding(String string) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            color: Colors.white,
            child: Text(
              "$string  ",
              textScaleFactor: 2.5,
            ),
          ),
        ),
      );
    }

    // Function for returning to LevelSelectionPage
    void returnToMap() {
      navigateTo(context, const LevelSelectionPage());
    }

    // Function for returning to ChestOpenPage
    void returnToLibrary() {
      navigateTo(context, const LibraryPage());
    }

    // Function to call when done with the book
    void onDone() {}

    // Function to create a book to be displayed
    // Function takes in an argument of the level of the book and the cover icon of the book
    Card createBook(double lev, String book) {
      int level = lev.toInt();
      int sublevel = ((lev - level) * 10).toInt();
      int fileNum = level * 1000 + sublevel * 100;
      return button(
          "word",
          PageStreamWidget(
              pages: loadPages(level, sublevel),
              returnToMap: returnToMap,
              returnToLibrary: returnToLibrary,
              onDone: onDone),
          book,
          lev);
    }

    // Lists of Books seperated by level
    final List<Card> stageOneButtons = [
      createBook(1.1, 'assets/books/1100.png'),
      createBook(1.2, 'assets/books/1200.png'),
    ];
    final List<Card> stageTwoButtons = [
      createBook(2.1, 'assets/books/2100.png'),
      createBook(2.2, 'assets/books/2200.png'),
    ];
    final List<Card> stageThreeButtons = [
      createBook(3.1, 'assets/books/3100.png'),
      createBook(3.2, 'assets/books/3200.png'),
      createBook(3.3, 'assets/books/3300.png'),
    ];
    final List<Card> stageFourButtons = [
      createBook(4.1, 'assets/books/4100.png'),
      createBook(4.2, 'assets/books/4200.png'),
    ];
    final List<Card> stageFiveButtons = [
      createBook(5.1, 'assets/books/5100.png'),
    ];

    // Renders the LibraryPage Scene
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.symmetric(vertical: 45)),
                    namePadding("Stage 1"),
                    gridBuilder(stageOneButtons),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0)),
                    namePadding("Stage 2"),
                    gridBuilder(stageTwoButtons),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0)),
                    namePadding("Stage 3"),
                    gridBuilder(stageThreeButtons),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0)),
                    namePadding("Stage 4"),
                    gridBuilder(stageFourButtons),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0)),
                    namePadding("Stage 5"),
                    gridBuilder(stageFiveButtons),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0)),
                  ],
                ),
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
                    navigateTo(context, const HomeScreenPage());
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
