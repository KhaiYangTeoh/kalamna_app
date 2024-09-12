import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kalamna_app/main.dart';
import 'package:provider/provider.dart';

import 'level_selection.dart';

class GenderSelectionPage extends StatelessWidget {
  const GenderSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listens to the Global App State
    var appState = context.watch<MyAppState>();

    // Function to create the button for each gender
    // Function takes in a String argument for type of gender and String for icon
    Padding button(String gender, String icon) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: SvgPicture.asset(icon, height: 90, width: 90),
                onPressed: () {
                  appState.toggleGender(gender);
                  debugPrint("Level Selection Page button pressed");
                  navigateTo(context, const LevelSelectionPage());
                },
                constraints: const BoxConstraints(minHeight: 80, minWidth: 110),
              ),
            ),
          ),
        ),
      );
    }

    // List of Buttons for each gender
    final List<Padding> genderButtons = [
      button("boy", 'assets/menu_assets/BOY.svg'),
      button("girl", 'assets/menu_assets/GIRL.svg'),
      button("brothers", 'assets/menu_assets/SIBLINGS.svg'),
      button("sisters", 'assets/menu_assets/SIBLINGS.svg'),
      button("siblings", 'assets/menu_assets/SIBLINGS.svg'),
    ];

    // Renders the scene for GenderSelectionPage
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Are you:',
              textScaleFactor: 4,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                genderButtons[0],
                genderButtons[1],
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                genderButtons[2],
                genderButtons[3],
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                genderButtons[4],
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
