import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'book_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

Color _blue = const Color(0xff09b6f6);
// Color _grey = const Color(0xff7f7f7f);

// widget to display one page
class PageWidget extends StatelessWidget {
  final PageData card;

  const PageWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Image.asset(
        card.pic,
      ),
    );
  }
}

// Widget to display stream of pages
class PageStreamWidget extends StatefulWidget {
  final Stream<PageData> pages;
  final VoidCallback returnToMap;
  final VoidCallback returnToLibrary;
  final VoidCallback onDone;

  const PageStreamWidget({
    super.key,
    required this.pages,
    required this.returnToMap,
    required this.returnToLibrary,
    required this.onDone,
  });

  @override
  State<PageStreamWidget> createState() =>
      _PageStreamWidgetState(pages, returnToMap, returnToLibrary, onDone);
}

// State for PageStreamWidget
class _PageStreamWidgetState extends State<PageStreamWidget> {
  final Stream<PageData> _pages;
  final VoidCallback _returnToMap;
  final VoidCallback _returnToLibrary;
  final VoidCallback _onDone;
  bool streamDone = false;
  DateTime _prev = DateTime.now();
  double startPos = 0;
  double endPos = 0;

  final List<PageData> _pagesList = <PageData>[];
  int _pageIndex = 0;

  _PageStreamWidgetState(
    this._pages,
    this._returnToMap,
    this._returnToLibrary,
    this._onDone,
  ) {
    _pages.listen(
      _addPage,
      onDone: () => streamDone = true,
    );
  }

  // Adds a new page to the stored list
  void _addPage(PageData newPage) {
    setState(() {
      _pagesList.add(newPage);
    });
  }

  // Switches to the next page
  void _nextPage() {
    setState(() {
      _pageIndex = _getDispIndex() + 1;
    });

    if (streamDone && _pageIndex == _pagesList.length) _onDone();
  }

  // Switches to the previous card
  void _prevPage() {
    setState(() {
      _pageIndex = _getDispIndex() - 1;
      if (_pageIndex < 0) _pageIndex = 0;
    });
  }

  // Gets the index of the current card to display
  int _getDispIndex() {
    if (_pageIndex < _pagesList.length - 1) return _pageIndex;
    return _pagesList.length - 1;
  }

  Widget _buttons(double width, double height) {
    if (width < 10 || height < 10) return const SizedBox.shrink();

    height = (width / 5 < height) ? width / 5 : height;

    Expanded libraryButton = Expanded(
      child: IconButton(
        icon: Icon(
          Icons.arrow_forward_rounded,
          color: _blue,
        ),
        iconSize: height,
        onPressed: _returnToLibrary,
      ),
    );

    Expanded soundButton = Expanded(
      child: IconButton(
        icon: Icon(
          Icons.volume_up_rounded,
          color: _blue,
        ),
        iconSize: height,
        onPressed: () async {
          if (_pagesList[_pageIndex].soundfile != null) {
            AudioPlayer player = AudioPlayer();
            // var x = await DefaultAssetBundle.of(context).load(soundFile);
            // player.setSourceBytes(x as Uint8List);
            await player.play(AssetSource(_pagesList[_pageIndex].soundfile!),
                volume: 1);
          }
        },
      ),
    );

    Expanded mapButton = Expanded(
      child: TextButton(
        onPressed: _returnToMap,
        child: SvgPicture.asset('assets/icons/MAP_ICON.svg'),
      ),
    );

    return Container(
      width: width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [mapButton, soundButton, libraryButton],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pagesList.isEmpty) return const SizedBox.shrink();

    int dispIndex = _getDispIndex();
    PageWidget pageWidget = PageWidget(card: _pagesList[dispIndex]);
    double contentWidth = MediaQuery.of(context).size.width - 32;
    double contentHeight = MediaQuery.of(context).size.height - 32;

    Border border = Border.all(color: _blue, width: 10);

    return GestureDetector(
      onHorizontalDragStart: (details) {
        startPos = details.localPosition.dx;
      },
      onHorizontalDragUpdate: (details) {
        endPos = details.localPosition.dx;
      },
      onHorizontalDragEnd: (details) {
        if (startPos - endPos < -75) {
          _nextPage();
        } else if (startPos - endPos > 75) {
          _prevPage();
        } else {}
      },
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: border,
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    pageWidget,
                    _buttons(contentWidth, contentHeight * 0.1)
                  ])),
        ),
      ),
    );
  }
}
