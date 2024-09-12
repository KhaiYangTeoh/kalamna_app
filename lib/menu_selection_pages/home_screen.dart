import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kalamna_app/main.dart';
import 'package:kalamna_app/menu_selection_pages/main_menu.dart';
import 'dart:math';

import 'library_page.dart';
import 'settings_page.dart';
import 'words_page.dart';

class HomeScreenPage extends StatelessWidget {
  const HomeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtaining screen width and height
    // In this case screenWidth is limited to 800 units
    double screenWidth = min(MediaQuery.of(context).size.width, 800);
    double screenHeight = MediaQuery.of(context).size.height;

    // Function to create the button for each widget
    // Function takes in a String for type of widget, Widget for accessing the page and String for icon
    Padding button(String string, Widget page, String icon) {
      return Padding(
        padding: EdgeInsets.all(screenHeight * 0.012),
        child: Container(
          height: screenHeight * 0.285,
          width: screenHeight * 0.285,
          child: Card(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(screenHeight * 0.012),
                child: IconButton(
                  icon: SvgPicture.asset(icon,
                      height: screenHeight * 0.195,
                      width: screenHeight * 0.195),
                  onPressed: () {
                    debugPrint("$string button pressed");
                    navigateTo(context, page);
                  },
                  constraints: BoxConstraints(
                      minHeight: screenHeight * 0.225,
                      minWidth: screenHeight * 0.225),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Renders the scene for HomeScreenPage
    return Container(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                button("Library", const LibraryPage(),
                    'assets/menu_assets/BOOKS.svg'),
                button(
                    "Words", const WordsPage(), 'assets/menu_assets/WORDS.svg'),
                button("Settings", const SettingsPage(),
                    'assets/menu_assets/SETTINGS.svg'),
              ],
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
                    navigateTo(context, const MainMenuPage());
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
