import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:math';
import 'flashcard_data.dart';
import 'package:audioplayers/audioplayers.dart';
import '../icons.dart';
import '../interactive_cards/drawing_page.dart';

Color _blue = const Color(0xff09b6f6);
Color _grey = const Color(0xff7f7f7f);

// Widget to display a single flashcard
class FlashcardWidget extends StatelessWidget {
  final FlashcardData card;
  final double width;
  final double height;

  const FlashcardWidget(
      {super.key,
      required this.card,
      required this.width,
      required this.height});

  Widget _cellWidget({required String path, required double width}) {
    String extension = path.substring(path.length - 4);

    if (card.type == FlashcardType.letterForm) width *= 0.5;

    if (extension == '.svg') {
      return SvgPicture.asset(
        path,
        width: width,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        path,
        width: width,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = (width < height / 3) ? width : height / 3;

    if (card.pic2 == null) {
      return _cellWidget(
        path: card.pic1,
        width: cardWidth,
      );
    }

    List<Widget> imgs = [
      _cellWidget(
        path: card.pic1,
        width: cardWidth,
      ),
      _cellWidget(
        path: card.pic2 as String,
        width: cardWidth,
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: imgs,
    );
  }
}

// Widget to display how far through the flashcards we are
class _ProgressWidget extends StatelessWidget {
  final int done, total;
  final double width, height;

  const _ProgressWidget(
      {super.key,
      required this.done,
      required this.total,
      required this.width,
      required this.height});

  // Get the widget for the counter
  Widget _counterWidget() {
    double textHeight = height * 0.3;
    if (width / 10 < textHeight) textHeight = width / 10;

    return Padding(
      padding: EdgeInsets.all(height * 0.1),
      child: Text(
        '$done / $total',
        style: TextStyle(fontSize: textHeight),
      ),
    );
  }

  // Get the widget for the progress bar
  Widget _barWidget() {
    Align barContents = Align(
      alignment: Alignment.centerRight,
      child: Container(
        color: _blue,
        width: width * done / total,
      ),
    );

    Border border = Border.all(
      color: _grey,
      width: height * 0.05,
    );

    return Container(
      height: height * 0.4,
      width: width,
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.circular(10),
      ),
      child: barContents,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (width < 50) return const SizedBox.shrink();

    Widget counter = _counterWidget();
    Widget bar = _barWidget();

    return Container(
      height: height,
      width: width,
      child: Column(
        children: [counter, bar],
      ),
    );
  }
}

// Class to indicate the way to display a flashcard
class _FlashcardForm {
  FlashcardData card;
  bool doDragAndDrop;

  _FlashcardForm(this.card, this.doDragAndDrop);
}

// Widget to display stream of flashcards
class FlashcardStreamWidget extends StatefulWidget {
  final Stream<FlashcardData> cards;
  final VoidCallback onReturn;
  final VoidCallback onDone;
  final bool addDragAndDrop;

  const FlashcardStreamWidget({
    super.key,
    required this.cards,
    required this.onReturn,
    required this.onDone,
    this.addDragAndDrop = true,
  });

  @override
  State<FlashcardStreamWidget> createState() =>
      _FlashcardStreamWidgetState(cards, onReturn, onDone, addDragAndDrop);
}

// State for FlashcardStreamWidget
class _FlashcardStreamWidgetState extends State<FlashcardStreamWidget> {
  final Stream<FlashcardData> _cards;
  final VoidCallback _onReturn;
  final VoidCallback _onDone;
  final bool _addDragAndDrop;
  bool streamDone = false;

  List<_FlashcardForm> _cardsList = <_FlashcardForm>[];
  int _cardIndex = 0;

  _FlashcardStreamWidgetState(
    this._cards,
    this._onReturn,
    this._onDone,
    this._addDragAndDrop,
  ) {
    _cards.listen(
      _addCard,
      onDone: () => streamDone = true,
    );
  }

  // Adds a new card to the stored list
  void _addCard(FlashcardData newCard) {
    setState(() {
      _cardsList.add(_FlashcardForm(newCard, false));
      if (_addDragAndDrop && newCard.word != null) {
        _cardsList.add(_FlashcardForm(newCard, true));
      }
    });
  }

  // Switches to the next card
  void _nextCard() {
    setState(() {
      _cardIndex = _getDispIndex() + 1;
    });

    if (streamDone && _cardIndex == _cardsList.length) _onDone();
  }

  // Switches to the previous card
  void _prevCard() {
    setState(() {
      _cardIndex = _getDispIndex() - 1;
      if (_cardIndex < 0) _cardIndex = 0;
    });
  }

  // Gets the index of the current card to display
  int _getDispIndex() {
    if (_cardIndex < _cardsList.length - 1) return _cardIndex;
    return _cardsList.length - 1;
  }

  // Gets the widget for the bottom bar of buttons
  Widget _buttons(double width, double height) {
    if (width < 10 || height < 10) return const SizedBox.shrink();

    height = (width / 5 < height) ? width / 5 : height;

    Expanded nextButton = Expanded(
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: _blue,
        ),
        iconSize: height,
        onPressed: _nextCard,
      ),
    );

    Expanded soundButton = Expanded(
      child: GestureDetector(
        // onLongPress: () async {
        //   String? soundFile = _cardsList[_cardIndex].card.soundFile;
        //   if (soundFile != null) {
        //     AudioCache player = AudioCache();
        //     player.play(_cardsList[_cardIndex].card.word!);
        //   }
        // },
        child: IconButton(
          icon: Icon(
            Icons.volume_up_rounded,
            color: _blue,
          ),
          iconSize: height,
          onPressed: () async {
            String? soundFile = _cardsList[_cardIndex].card.soundFile;
            if (soundFile != null) {
              AudioPlayer player = AudioPlayer();
              // var x = await DefaultAssetBundle.of(context).load(soundFile);
              // player.setSourceBytes(x as Uint8List);
              await player.play(AssetSource(soundFile), volume: 1);
              // AudioCache player = AudioCache();
              // player.play(_cardsList[_cardIndex].card.soundFile!);
            }
          },
        ),
      ),
    );

    Expanded prevButton = Expanded(
      child: IconButton(
        icon: Icon(
          Icons.arrow_forward_rounded,
          color: _blue,
        ),
        iconSize: height,
        onPressed: _prevCard,
      ),
    );

    return Container(
      width: width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [nextButton, soundButton, prevButton],
      ),
    );
  }

  // Gets the widget for the top progress bar and return button
  Widget _topWidget(int dispIndex, double width, double height) {
    if (width < 30 || height < 30) return const SizedBox.shrink();

    TextButton returnButton = TextButton(
      onPressed: _onReturn,
      child: SvgPicture.asset(mapIcon),
    );

    if (width * 0.6 < 100) {
      return Container(
        height: height,
        width: width,
        child: returnButton,
      );
    }

    _ProgressWidget prog = _ProgressWidget(
      done: dispIndex,
      total: _cardsList.length,
      width: width * 0.6,
      height: height,
    );

    return Container(
      height: height,
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          prog,
          Expanded(child: returnButton),
        ],
      ),
    );
  }

  // Gets the widget to display the current card
  Widget _getCardWidget(_FlashcardForm card, double width, double height) {
    if (card.doDragAndDrop) {
      return Container(
        width: width * 0.5,
        height: height * 0.5,
        child: Center(
          child: DrawingPage(
            word: card.card.word!,
            width: min(width * 0.5, height * 0.5),
          ),
        ),
      );
    }

    return FlashcardWidget(
      card: card.card,
      width: width,
      height: height,
    );
  }

  // Gets the widget for the content to display
  Widget _contentWidget(double width, double height) {
    if (width < 70 || height < 70 || _cardsList.isEmpty) {
      return const SizedBox.expand();
    }

    int dispIndex = _getDispIndex();
    Widget cardWidget = _getCardWidget(_cardsList[dispIndex], width, height);

    return Container(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _topWidget(dispIndex, width, height * 0.2),
          cardWidget,
          _buttons(width, height * 0.1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double contentPadding = 16;
    double contentWidth =
        MediaQuery.of(context).size.width - 2 * contentPadding;
    double contentHeight =
        MediaQuery.of(context).size.height - 2 * contentPadding;

    Border border = Border.all(color: _blue, width: 10);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(contentPadding),
          child: _contentWidget(contentWidth, contentHeight),
        ),
      ),
    );
  }
}
