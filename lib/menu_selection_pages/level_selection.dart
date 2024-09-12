import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kalamna_app/menu_selection_pages/chest_open.dart';
import 'dart:math';

import 'package:kalamna_app/menu_selection_pages/settings_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kalamna_app/assessments/assessment_data.dart';
import 'package:kalamna_app/assessments/assessment_widget.dart';
import 'package:kalamna_app/main.dart';
import 'package:kalamna_app/sublevel_widget/sublevel_widget.dart';

import 'package:provider/provider.dart';

import 'main_menu.dart';

// Widget for implementing the level selection map
class LevelSelectionPage extends StatefulWidget {
  const LevelSelectionPage({super.key});

  @override
  LevelSelectionPageState createState() => LevelSelectionPageState();
}

// Widget for the level selection map state
class LevelSelectionPageState extends State<LevelSelectionPage> {
  String image = "";

  @override
  Widget build(BuildContext context) {
    // Listens to the Global App State
    var appState = context.watch<MyAppState>();

    // Obtaining screen width
    // In this case screenWidth is limited to 800 units
    double screenWidth = min(MediaQuery.of(context).size.width, 800);

    // Function to crate the button for the sublevels
    // Function takes in a double for sublevel number, Widget for the sublevel page, String of icon displayed, and doubles for x and y coordinates on screen
    Container button(
        double stage, Widget nextPage, String image, double x, double y) {
      return Container(
        height: screenWidth * 2,
        width: screenWidth,
        child: Align(
          alignment: Alignment(x, -y),
          child: RawMaterialButton(
            onPressed: () {
              debugPrint("Stage $stage button pressed");
              //if (appState.unlockedLevels >= stage) {
              navigateTo(context, nextPage);
              //}
            },
            shape: const CircleBorder(),
            constraints: BoxConstraints(
                minHeight: screenWidth * 0.135, minWidth: screenWidth * 0.135),
            child: SvgPicture.asset(
              image,
              width: screenWidth * 0.135,
            ),
          ),
        ),
      );
    }

    // List of List of chest images
    List<List<String>> chest = [
      [
        'assets/TREASURE_CHEST/CHEST_1A.svg',
        'assets/TREASURE_CHEST/CHEST_2A.svg',
        'assets/TREASURE_CHEST/CHEST_3A.svg',
        'assets/TREASURE_CHEST/CHEST_4A.svg',
      ],
      [
        'assets/TREASURE_CHEST/CHEST_1B.svg',
        'assets/TREASURE_CHEST/CHEST_2B.svg',
        'assets/TREASURE_CHEST/CHEST_3B.svg',
        'assets/TREASURE_CHEST/CHEST_4B.svg',
      ]
    ];

    // Function to crate the button for the assessment chest
    // Function takes in a double for chest number, Widget for the sublevel page, int for type of chest (0 - right, 1 - left), and doubles for x and y coordinates on screen
    Container chestButton(
        int stage, Widget nextPage, int type, double x, double y) {
      if (type != 0 && type != 1) {
        throw UnimplementedError('No such type $type for chest');
      }

      image = chest[type][0];

      return Container(
        height: screenWidth * 2,
        width: screenWidth,
        child: Align(
          alignment: Alignment(x, -y),
          child: RawMaterialButton(
            onPressed: () {
              debugPrint("Chest $stage button pressed");
              //if (appState.unlockedChest >= stage) {
              navigateTo(context, nextPage);
              //}
            },
            shape: const CircleBorder(),
            constraints: BoxConstraints(
                minHeight: screenWidth * 0.15, minWidth: screenWidth * 0.15),
            child: SvgPicture.asset(
              image,
              width: screenWidth * 0.15,
            ),
          ),
        ),
      );
    }

    // List of buttons and chestbuttons to be displayed
    final List<Container> buttons = [
      // Level 1 Buttons
      button(
          1.1,
          SublevelWidget(
              level: 1, sublevel: 1, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/1.1.svg',
          -0.48,
          -0.87),
      button(
          1.2,
          SublevelWidget(
              level: 1, sublevel: 2, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/1.2.svg',
          -0.02,
          -0.88),
      button(
          1.3,
          SublevelWidget(
              level: 1, sublevel: 3, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/1.3.svg',
          0.5,
          -0.85),
      button(
          1.4,
          SublevelWidget(
              level: 1, sublevel: 4, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/1.4.svg',
          0.88,
          -0.75),
      // Level 2 Buttons
      chestButton(
          1,
          AssessmentStreamWidget(
              assessments: loadAssessment(1),
              returnToMenu: () {
                navigateTo(context, const ChestOpenPage(chest: 1));
              },
              onDone: () {}),
          1,
          0.78,
          -0.58),
      button(
          2.1,
          SublevelWidget(
              level: 2, sublevel: 1, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/2.1.svg',
          0.4,
          -0.54),
      button(
          2.2,
          SublevelWidget(
              level: 2, sublevel: 1, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/2.2.svg',
          -0.1,
          -0.51),
      chestButton(
          2,
          AssessmentStreamWidget(
              assessments: loadAssessment(2),
              returnToMenu: () {
                navigateTo(context, const ChestOpenPage(chest: 2));
              },
              onDone: () {}),
          1,
          -0.60,
          -0.51),
      // Level 3 Button
      button(
          3.1,
          SublevelWidget(
              level: 3, sublevel: 1, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/3.1.svg',
          -0.92,
          -0.36),
      button(
          3.2,
          SublevelWidget(
              level: 3, sublevel: 2, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/3.2.svg',
          -0.50,
          -0.28),
      button(
          3.3,
          SublevelWidget(
              level: 3, sublevel: 3, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/3.3.svg',
          -0.01,
          -0.28),
      button(
          3.4,
          SublevelWidget(
              level: 3, sublevel: 4, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/3.4.svg',
          0.48,
          -0.28),
      chestButton(
          3,
          AssessmentStreamWidget(
              assessments: loadAssessment(3),
              returnToMenu: () {
                navigateTo(context, const ChestOpenPage(chest: 3));
              },
              onDone: () {}),
          0,
          0.84,
          -0.12),
      // Level 4 Button
      button(
          4.1,
          SublevelWidget(
              level: 4, sublevel: 1, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/4.1.svg',
          0.40,
          -0.10),
      button(
          4.2,
          SublevelWidget(
              level: 4, sublevel: 2, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/4.2.svg',
          -0.25,
          -0.10),
      button(
          4.3,
          SublevelWidget(
              level: 4, sublevel: 3, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/4.3.svg',
          -0.58,
          0.12),
      button(
          4.4,
          SublevelWidget(
              level: 4, sublevel: 4, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/4.4.svg',
          -0.15,
          0.17),
      chestButton(
          4,
          AssessmentStreamWidget(
              assessments: loadAssessment(4),
              returnToMenu: () {
                navigateTo(context, const ChestOpenPage(chest: 4));
              },
              onDone: () {}),
          0,
          0.3,
          0.17),
      // Level 5 Buttons
      button(
          5.1,
          SublevelWidget(
              level: 5, sublevel: 1, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/5.1.svg',
          0.55,
          0.30),
      button(
          5.2,
          SublevelWidget(
              level: 5, sublevel: 2, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/5.2.svg',
          0.40,
          0.50),
      button(
          5.3,
          SublevelWidget(
              level: 5, sublevel: 3, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/5.3.svg',
          -0.10,
          0.62),
      button(
          5.4,
          SublevelWidget(
              level: 5, sublevel: 4, onReturn: () => backButton(context)),
          'assets/MAP_ICONS/5.4.svg',
          -0.72,
          0.74),
      chestButton(
          5,
          AssessmentStreamWidget(
              assessments: loadAssessment(5),
              returnToMenu: () {
                navigateTo(context, const ChestOpenPage(chest: 5));
              },
              onDone: () {}),
          0,
          -0.32,
          0.82),
    ];

    // Renders the LevelSelectionPageState scene
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            reverse: true,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(height: screenWidth * 2),
                Positioned(
                  bottom: 0.0,
                  child: SvgPicture.asset(
                    'assets/MAP/MAP_EMPTY.svg',
                    width: screenWidth,
                  ),
                ),
                ...buttons,
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
          Align(
            alignment: const Alignment(0.6, -0.98),
            child: Container(
              height: screenWidth * 0.14,
              width: screenWidth * 0.14,
              child: Card(
                shape: const CircleBorder(),
                margin: const EdgeInsets.all(0.0),
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/menu_assets/SETTINGS.svg',
                  ),
                  color: const Color(0xff09b6f6),
                  onPressed: () {
                    debugPrint("Settings button pressed");
                    navigateTo(context, const SettingsPage());
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
