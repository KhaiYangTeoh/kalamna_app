import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:kalamna_app/interactive_cards/arabic_parser.dart';
import 'package:collection/collection.dart';
import 'dart:developer' as dev;

class DrawingPage extends StatefulWidget {
  final String word;
  final double width;
  const DrawingPage({super.key, required this.word, required this.width});

  @override
  State<StatefulWidget> createState() => _DrawingPageState(width);
}

class _DrawingPageState extends State<DrawingPage> {
  // All of these maps have corresponding indicies
  // they are the position of the letter in the word

  /// The untransformed paths representing raw letters
  final Map<int, Path> defaultPaths = <int, Path>{};

  /// The paths that are being dragged around
  final Map<int, Path> dragPaths = <int, Path>{};

  /// The 'destinations' - where the letters need to be dragged to
  final Map<int, Path> destPaths = <int, Path>{};

  /// Holds translation matrices for the drag paths
  final Map<int, Float64List> dragOffsetMap = <int, Float64List>{};

  /// Holds the translations matrices for the destination paths
  final Map<int, Float64List> destOffsetMap = <int, Float64List>{};

  /// Holds the indices of paths that have been dragged correctly and are now locked
  final Set<int> correctPath = <int>{};
  final double width;

  bool ready = false;
  bool changed = false;

  /// Part of an uncompleted feature used for tracing
  var panPoints = List<bool>.empty(growable: true);

  /// The path currently being dragged
  int pathIndex = -1;

  /// Stack so that the path being dragged is displayed above the others
  var pathIndices = Queue<int>();

  /// List of SVGLetters that represent the widget's word
  List<SVGLetter> letters = List.empty(growable: true);

  _DrawingPageState(this.width);

  @override
  Widget build(BuildContext context) {
    /// Singleton ArabicParser
    ArabicParser arabicParser =
        Provider.of<ArabicParser>(context, listen: true);
    ready = arabicParser.ready;
    double scale = 150 / sqrt(width) - log(width) / 3;
    double translateScale = scale / 2.8325;

    final scaleM = Float64List.fromList([
      1,
      0,
      0,
      0,
      0,
      -1,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      scale
    ]); // column major  - scale

    final translateM = Float64List.fromList([
      1,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      1,
      0,
      50 / translateScale,
      700 / translateScale,
      0,
      1
    ]);

    var dragOffsetMat =
        Float64List.fromList([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);

    var destOffsetMat = Float64List.fromList(
        [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -600 / translateScale, 0, 1]);

    if (ready) {
      if (defaultPaths.isEmpty) {
        letters = arabicParser.parseWordToSVGs(widget.word);
        letters = letters.whereNot((element) => element.horizAdv == 0).toList();
        for (int i = letters.length - 1; i >= 0; i--) {
          var l = letters[i];
          Path p =
              parseSvgPathData(l.svg).transform(scaleM).transform(translateM);
          if (l.horizAdv == 0) {
            p = Path.combine(PathOperation.union, p, defaultPaths[i - 1]!);
            p = defaultPaths[i - 1]!;
          }
          defaultPaths[i] = p;
          var mat = Float64List.fromList(destOffsetMat);
          destOffsetMap[i] = mat;
          destPaths[i] = p.transform(mat);
          destOffsetMat[12] += l.horizAdv / scale;
        }

        var xs = defaultPaths.keys.toList();
        while (listEquals(xs, defaultPaths.keys.toList())) {
          shuffle(xs);
        }
        for (var i in xs) {
          dragOffsetMap[i] = Float64List.fromList(dragOffsetMat);
          Path p = defaultPaths[i]!.transform(dragOffsetMap[i]!);

          dragOffsetMat[12] += letters[i].horizAdv / scale +
              (width * 1.5) / (letters.length * scale);

          dragPaths[i] = p;
        }
      } else {
        for (int i = letters.length - 1; i >= 0; i--) {
          // SVGLetter l = letters[i];
          dragPaths[i] = defaultPaths[i]!.transform(dragOffsetMap[i]!);
        }
      }
      if (pathIndices.isEmpty) {
        pathIndices.addAll(defaultPaths.keys);
      }
      // reverse(paths);
    }

    TextPainter painter;

    // print(MediaQuery.of(context).size);
    return SizedBox(
      height: width,
      width: width,
      child: ready
          ? CustomPaint(
              painter: painter = TextPainter(
                  dragPaths, destPaths, pathIndices, correctPath, changed),
              child: GestureDetector(
                onTapDown: (details) => pathIndex =
                    painter.pathHitTestForDrag(details.localPosition),
                onPanStart: (details) {
                  // print('start ${details.localPosition}');
                  setState(() {
                    panPoints.clear();
                    // pathIndex = painter.pathHitTest(details.localPosition);
                    // print(pathIndex);
                  });
                },
                // Updates the
                onPanUpdate: (details) {
                  // print(offsetMap);
                  bool hit = painter.hitTest(details.localPosition) ?? false;
                  panPoints.add(hit);
                  setState(() {
                    if (pathIndex != -1 && !correctPath.contains(pathIndex)) {
                      pathIndices.remove(pathIndex);
                      pathIndices.addLast(pathIndex);

                      changed = true;

                      dragOffsetMap.update(pathIndex, (value) {
                        value[12] += details.delta.dx;
                        value[13] += details.delta.dy;
                        return value;
                      });
                      if (destPaths.containsKey(pathIndex) &&
                          dragPaths.containsKey(pathIndex)) {
                        var bounds = dragPaths[pathIndex]!.getBounds();
                        var intersect =
                            bounds.intersect(destPaths[pathIndex]!.getBounds());
                        const dragAccuracy = 0.85;
                        if (intersect.size > const Size(0, 0) &&
                            (intersect.width * intersect.height) /
                                    (bounds.width * bounds.height) >=
                                dragAccuracy) {
                          correctPath.add(pathIndex);
                          dragOffsetMap[pathIndex] =
                              (destOffsetMap[pathIndex] ??
                                  dragOffsetMap[pathIndex])!;
                        }
                      }
                    }
                  });
                },
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}

class TextPainter extends CustomPainter {
  late Map<int, Path> dragPaths;
  late Map<int, Path> destPaths;
  late Queue<int> indices;
  late Set<int> correctPath;
  late bool changed;

  TextPainter(this.dragPaths, this.destPaths, this.indices, this.correctPath,
      this.changed);

  final Paint _paint = Paint()
    ..strokeWidth = 1.0
    ..style = PaintingStyle.fill
    ..strokeJoin = StrokeJoin.round;

  final Paint _destPaint = Paint()
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..color = Colors.blueGrey;

  @override
  void paint(Canvas canvas, Size size) {
    for (Path path in destPaths.values) {
      canvas.drawPath(path, _destPaint);
    }
    for (int key in indices) {
      if (correctPath.contains(key)) {
        canvas.drawPath(dragPaths[key]!,
            _paint..color = key % 2 == 0 ? Colors.black : Colors.red);
      } else {
        const Color transparentRed = Color.fromARGB(100, 244, 67, 54);
        const Color transparentBlack = Color.fromARGB(100, 0, 0, 0);
        canvas.drawPath(dragPaths[key]!,
            _paint..color = key % 2 == 0 ? transparentBlack : transparentRed);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool? hitTest(Offset position) {
    Rect r = Rect.fromCenter(center: position, width: 5, height: 5);
    bool b = dragPaths.values.any((element) => r.overlaps(element.getBounds()));
    return b;
  }

  int pathHitTestForDrag(Offset position) {
    return dragPaths.entries
        .firstWhere((element) => element.value.getBounds().contains(position),
            orElse: () => MapEntry(-1, Path()))
        .key;
  }

  bool pathHitTestForDrop(Offset position, int index) {
    return destPaths[index]?.contains(position) ?? false;
  }
}
