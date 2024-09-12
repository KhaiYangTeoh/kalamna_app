import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

/// Encodes the position of the letter in the word, and what form it must take
enum LetterPosition { beginning, middle, end, isolated }

extension ParseToString on LetterPosition {
  /// a call of lp.getForm() on a LetterPosition lp, returns the following. Helper for the XML search
  String? getForm() {
    switch (this) {
      case LetterPosition.beginning:
        return 'initial';
      case LetterPosition.middle:
        return 'medial';
      case LetterPosition.end:
        return 'final';
      case LetterPosition.isolated:
      default:
        return null;
    }
  }
}

/// Parses Arabic text into Paths or SVG as required
class ArabicParser extends ChangeNotifier {
  /// The root of the XML document, from which the SVG values can be searched
  late Iterable<XmlElement> fontRoot;
  bool ready = false;

  /// This constructor takes in an existing XmlDocument
  ArabicParser.fromDoc(XmlDocument doc)
      : fontRoot = doc.children
            .elementAt(4)
            .children
            .elementAt(3)
            .children
            .elementAt(1)
            .findAllElements('glyph') {
    ready = true;
    notifyListeners();
  }

  /// This constructor takes in a BuildContext, and from there loads the font XML asset
  ArabicParser.fromContext(BuildContext context) {
    DefaultAssetBundle.of(context)
        .loadString("assets/font/Kalamna.svg")
        .then((str) {
      fontRoot = XmlDocument.parse(str)
          .children
          .elementAt(4)
          .children
          .elementAt(3)
          .children
          .elementAt(1)
          .findAllElements('glyph');
      ready = true;
      notifyListeners();
      // log("re instantiate <3");
    });
  }

  /// Takes in a LetterForm and returns a nullable SVGLetter corresponding to that form
  SVGLetter? getSVGDataFromLetterForm(LetterForm lf) {
    String? s;
    String? h;
    try {
      // log(lf.letter.codeUnitAt(0).toRadixString(16));
      var xs = fontRoot
          .where((element) => element.getAttribute('unicode') == lf.letter);
      var x = xs.firstWhereOrNull((element) =>
          element.getAttribute('arabic-form') == lf.position.getForm());
      if (x == null) {
        x = xs.first;
        s = x.getAttribute('d');
        h = x.getAttribute('horiz-adv-x') ?? '0';
      } else {
        s = x.getAttribute('d');
        h = x.getAttribute('horiz-adv-x');
      }
    } catch (e) {
      log('failed to find ${lf.letter.codeUnitAt(0).toRadixString(16)}');
    }
    if (s == null || h == null) return null;
    return SVGLetter(s, double.parse(h));
  }

  SVGLetter? getSVGDataFromLetterPosition(String letter, LetterPosition pos) =>
      getSVGDataFromLetterForm(LetterForm(letter, pos));

  List<LetterForm> parseWord(String word) {
    final letters = List<LetterForm>.empty(growable: true);
    if (word.length == 1) {
      letters.add(LetterForm(word, LetterPosition.isolated));
      return letters;
    }

    /// these letters only have isolated and ending forms
    const isoLetters = [
      0x627,
      0x62F,
      0x630,
      0x631,
      0x632,
      0x648,
      0x622,
      0x629,
      0x649
    ];

    // FSM to figure out the forms according to the word
    var state = LetterPosition.beginning;
    for (int i = 0; i < word.length; i++) {
      switch (state) {
        case LetterPosition.beginning:
          if (isoLetters.contains(word.codeUnitAt(i)) || i == word.length - 1) {
            letters.add(LetterForm(word[i], LetterPosition.isolated));
            state = LetterPosition.beginning;
          } else {
            letters.add(LetterForm(word[i], LetterPosition.beginning));
            state = LetterPosition.middle;
          }
          break;
        case LetterPosition.middle:
          if (isoLetters.contains(word.codeUnitAt(i)) || i == word.length - 1) {
            letters.add(LetterForm(word[i], LetterPosition.end));
            state = LetterPosition.beginning;
          } else {
            letters.add(LetterForm(word[i], LetterPosition.middle));
            state = LetterPosition.middle;
          }
          break;
        default:
          break;
      }
    }
    return letters;
  }

  List<SVGLetter> parseWordToSVGs(String word) {
    final letters = parseWord(word);
    final List<SVGLetter> svgletters = List.empty(growable: true);
    for (var i = 0; i < word.length; i++) {
      var l = letters[i];
      var s = getSVGDataFromLetterForm(l);
      if (s == null) continue;
      if (s.horizAdv == 0) {
        log('doing this for ${s.svg}');
        var prev = svgletters.last;
        svgletters.last = SVGLetter('${s.svg} ${prev.svg}', prev.horizAdv);
      } else {
        svgletters.add(s);
      }
    }
    return svgletters;
  }
}

/// A class encoding a letter and its LetterPosition
class LetterForm {
  final String letter;
  final LetterPosition position;

  /// Constructor, taking in a letter and position
  LetterForm(this.letter, this.position);

  /// Deprecated
  static LetterForm forLetter(int letterCode, LetterPosition pos) {
    int code = letterCode;
    final isoLetters = [
      0x627,
      0x62F,
      0x630,
      0x631,
      0x632,
      0x648,
      0x622,
      0x629,
      0x649
    ];
    if (isoLetters.contains(code)) {
      if (pos == LetterPosition.end) {
        return LetterForm(String.fromCharCode(letterCode), pos);
      } else {
        return LetterForm(
            String.fromCharCode(letterCode), LetterPosition.isolated);
      }
    } else {
      return LetterForm(String.fromCharCode(letterCode), pos);
    }
  }

  @override
  String toString() {
    return ('(${letter.codeUnitAt(0).toRadixString(16)}, ${position.getForm()})');
  }
}

/// Class encoding the two important values of the SVGLetter.
/// The SVG value in a string
/// and the double encoding how far the paintershould advance after painting a letter.
class SVGLetter {
  final String svg;
  final double horizAdv;

  SVGLetter(this.svg, this.horizAdv);

  @override
  String toString() {
    return svg;
  }
}
