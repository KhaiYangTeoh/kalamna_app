//
// Left Unused due to time constraints
//

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kalamna_app/main.dart';
import 'package:kalamna_app/menu_selection_pages/level_selection.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'home_screen.dart';

class WordsPage extends StatelessWidget {
  const WordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listens to the Global App State
    var appState = context.watch<MyAppState>();

    // Obtaining screen width
    // In this case screenWidth is limited to 800 units
    double screenWidth = min(MediaQuery.of(context).size.width, 800);

    Card button(
        String debug, Widget nextPage, IconData icon, double restriction) {
      return Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RawMaterialButton(
              onPressed: () {
                debugPrint("$debug button pressed");
                if (restriction <= appState.unlockedLevels) {
                  navigateTo(context, nextPage);
                }
              },
              fillColor: const Color(0xFF0DB3A2),
              shape: const RoundedRectangleBorder(),
              constraints: const BoxConstraints(minHeight: 100, minWidth: 100),
              child: FaIcon(icon, size: 50, color: Colors.white),
            ),
          ),
        ),
      );
    }

    GridView gridBuilder(List<Card> words) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: words.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 100.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (context, i) => words[i],
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

    final List<Card> words = [
      button("word", const Placeholder(), FontAwesomeIcons.a, 1.1),
      button("word", const Placeholder(), FontAwesomeIcons.b, 1.1),
      button("word", const Placeholder(), FontAwesomeIcons.c, 1.1),
      button("word", const Placeholder(), FontAwesomeIcons.d, 1.1),
      button("word", const Placeholder(), FontAwesomeIcons.e, 1.1),
      button("word", const Placeholder(), FontAwesomeIcons.f, 1.1),
      button("word", const Placeholder(), FontAwesomeIcons.g, 1.1),
      button("word", const Placeholder(), FontAwesomeIcons.h, 1.1),
      button("word", const Placeholder(), FontAwesomeIcons.i, 1.1),
      button("word", const Placeholder(), FontAwesomeIcons.j, 1.1),
      button("word", const Placeholder(), FontAwesomeIcons.k, 1.1),
    ];

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
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0)),
                    namePadding("Words"),
                    gridBuilder(words),
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
