import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kalamna_app/main.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'gender_selection.dart';
import 'level_selection.dart';
import 'home_screen.dart';

// ignore: unused_import
import 'package:kalamna_app/tutorial/tutorial.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listens to the Global App State
    var appState = context.watch<MyAppState>();

    // Obtaining screen height
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.045)),
            Image.asset('assets/logo/Kalamna_Logo.png',
                width: screenHeight * 0.375, height: screenHeight * 0.375),
            Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03)),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
              child: Text(
                'Hello!',
                textScaleFactor: screenHeight * 0.004,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenHeight * 0.0225),
                  child: RawMaterialButton(
                    onPressed: () {
                      if (appState.gender == "") {
                        debugPrint("GenderSelectionPage button pressed");
                        navigateTo(context, const GenderSelectionPage());
                      } else {
                        debugPrint("LevelSelectionPage button pressed");
                        navigateTo(context, const LevelSelectionPage());
                      }
                    },
                    fillColor: const Color(0xFF0DB3A2),
                    shape: const CircleBorder(),
                    constraints: BoxConstraints(
                        minHeight: screenHeight * 0.18,
                        minWidth: screenHeight * 0.18),
                    child: Transform(
                      alignment: const Alignment(-0.1, 0),
                      transform: Matrix4.rotationY(math.pi),
                      child: FaIcon(FontAwesomeIcons.play,
                          size: screenHeight * 0.09, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenHeight * 0.0225),
                  child: RawMaterialButton(
                    onPressed: () {
                      debugPrint("HomeScreenPage button pressed");
                      navigateTo(context, const HomeScreenPage());
                    },
                    fillColor: const Color(0xFF0DB3A2),
                    shape: const CircleBorder(),
                    constraints: BoxConstraints(
                        minHeight: screenHeight * 0.18,
                        minWidth: screenHeight * 0.18),
                    child: FaIcon(FontAwesomeIcons.gears,
                        size: screenHeight * 0.09, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
