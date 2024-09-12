import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kalamna_app/main.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // Obtaining screen width
    // In this case screenWidth is limited to 800 units
    double screenWidth = min(MediaQuery.of(context).size.width, 800);

    Card button(String gender, String icon) {
      return Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: SvgPicture.asset(icon, height: 90, width: 90),
              onPressed: () {
                appState.toggleGender(gender);
              },
              constraints: const BoxConstraints(minHeight: 100, minWidth: 100),
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
          maxCrossAxisExtent: 120.0,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
        ),
        itemBuilder: (context, i) => stage[i],
      );
    }

    Padding namePadding(String string) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            color: Colors.white,
            child: Text(
              "$string  ",
              textScaleFactor: 2.0,
            ),
          ),
        ),
      );
    }

    final List<Card> genderButtons = [
      button("boy", 'assets/menu_assets/BOY.svg'),
      button("girl", 'assets/menu_assets/GIRL.svg'),
      button("brothers", 'assets/menu_assets/SIBLINGS.svg'),
      button("sisters", 'assets/menu_assets/SIBLINGS.svg'),
      button("siblings", 'assets/menu_assets/SIBLINGS.svg'),
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
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                    namePadding("Gender Selection"),
                    gridBuilder(genderButtons),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                    ),
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
                    backButton(context);
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
