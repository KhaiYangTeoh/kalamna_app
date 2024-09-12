// NOT USED CURRENTLY!!
// THIS IS ALL A MESS

/*
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

Map<int, String> bookFiles = {
  1: 'assets/books/level1/book1.pdf',
  2: 'assets/books/level1/book2.pdf',
  3: 'assets/books/level2/book3.pdf',
  4: 'assets/books/level2/book4.pdf',
  5: 'assets/books/level3/book5.pdf',
  6: 'assets/books/level3/book6.pdf',
  7: 'assets/books/level3/book7.pdf',
  8: 'assets/books/level4/book8.pdf',
  9: 'assets/books/level4/book9.pdf',
  10: 'assets/books/level5/book10.pdf'
};

class BookReaderWidget extends StatefulWidget {
  final int number;

  const BookReaderWidget({
    super.key,
    required this.number,
  });

  @override
  State<BookReaderWidget> createState() => _BookReaderWidgetState();
}

class _BookReaderWidgetState extends State<BookReaderWidget> {
  // late final PDFViewController _controller;
  // final PdfViewerController _pdfViewerController = PdfViewerController();

  _BookReaderWidgetState();

  @override
  Widget build(BuildContext context) {
    final PdfViewerController controller = PdfViewerController();
    int page = 1;
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.direction > 0) {
          if (page < controller.pageCount) page++;
        } else {
          if (page > 1) page--;
        }
        controller.goToPage(pageNumber: page);
      },
      child: PdfViewer.openAsset(
        bookFiles[bookFiles.containsKey(widget.number) ? widget.number : 1]!,
        viewerController: controller,
      ),
    );
  }
  /*
    print('work pls');
    return GestureDetector(
      child: PDFView(
        filePath: 'assets/books/level1/book1.pdf',
        onRender: (_pages) {
          setState(() {
            print(_pages);
          });
        },
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          _controller = pdfViewController;
        },
        onPageChanged: (int? page, int? total) {
          print('page change: $page/$total');
        },
      ),
    );
    }
    */

  /*
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.direction > 0) {
          _pdfViewerController.nextPage();
        } else {
          _pdfViewerController.lastPage();
        }
      },
      child: SfPdfViewer.asset(
        'books/level1/book1.pdf',
        controller: _pdfViewerController,
      ),
    ); 
    }*/
}

// bookFiles[bookFiles.containsKey(widget.number) ? _number : 1]!,

*/