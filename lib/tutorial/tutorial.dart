//
// Left unimplemented due to time constraints
//

import 'package:flutter/material.dart';
import 'package:kalamna_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spotlight_plus/flutter_spotlight_plus.dart';

import '../menu_selection_pages/main_menu.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  final Offset _center =
      const Offset(250.0, 10.0); // Center position of Spotlight
  final double _radius = 100.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                debugPrint("Search button pressed");
                navigateTo(context, const MainMenuPage());
              },
            ),
            //body: SafeArea(
            //  child: Container(),
            //),
            FloatingActionButton(
              child: const Icon(Icons.favorite_border),
              onPressed: () {
                debugPrint("Spotlight button pressed");
                navigateTo(context, const MainMenuPage());
              },
            ),
          ],
        ),
        Spotlight(
          center: _center,
          radius: _radius,
          enabled: true,
          animation: true,
          child: Container(),
        ),
      ],
    );
  }
}
