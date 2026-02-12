import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart'; // PdfDocument, PdfTextExtractor
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum ViewerMode { normal, read, dark }

class PDFViewerController extends GetxController {
  // Document state
  final RxInt totalPages = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxBool isDocumentLoaded = false.obs;
  final RxBool isLoading = true.obs;

  // View settings
  final Rx<PdfScrollDirection> scrollDirection =
      PdfScrollDirection.horizontal.obs;
  final Rx<ViewerMode> currentMode = ViewerMode.normal.obs;

  // Controllers
  final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
  late PdfViewerController viewerController;

  // Keep a reference to the loaded PDF to reuse later
  PdfDocument? _doc;

  // TTS
  final FlutterTts tts = FlutterTts();
  final RxBool isSpeaking = false.obs;

  @override
  void onInit() {
    super.onInit();
    viewerController = PdfViewerController();
    _setupTts();
  }

  // ---- PDF Viewer callbacks ----
  void handleDocumentLoaded(PdfDocumentLoadedDetails details) {
    try {
      _doc = details.document; // store for later (TTS, etc.)
      final pageCount = _doc!.pages.count;
      if (pageCount < 1) throw Exception("Document has no pages");

      totalPages.value = pageCount;
      isDocumentLoaded.value = true;
      isLoading.value = false;
      // clamp() returns num → cast to int
      currentPage.value =
          viewerController.pageNumber.clamp(1, pageCount).toInt();
    } catch (e, stackTrace) {
      debugPrint('Document load error: $e\n$stackTrace');
      resetState();
    }
  }

  void handlePageChanged(PdfPageChangedDetails details) {
    if (details.newPageNumber != currentPage.value) {
      currentPage.value = details.newPageNumber;
    }
  }

  // ---- Modes & scrolling ----
  void toggleViewMode() {
    currentMode.value =
        ViewerMode.values[(currentMode.value.index + 1) %
            ViewerMode.values.length];
  }

  void toggleDarkMode() {
    currentMode.value =
        currentMode.value == ViewerMode.dark
            ? ViewerMode.normal
            : ViewerMode.dark;
  }

  void toggleScrollDirection() {
    scrollDirection.value =
        scrollDirection.value == PdfScrollDirection.horizontal
            ? PdfScrollDirection.vertical
            : PdfScrollDirection.horizontal;
  }

  // Getters
  bool get isNormalMode => currentMode.value == ViewerMode.normal;
  bool get isReadMode => currentMode.value == ViewerMode.read;
  bool get isDarkMode => currentMode.value == ViewerMode.dark;

  void resetState() {
    totalPages.value = 0;
    currentPage.value = 1;
    isDocumentLoaded.value = false;
    isLoading.value = false;
    _doc = null;
  }

  // ---- TTS setup & controls ----
  void _setupTts() async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.setSpeechRate(0.5);

    tts.setCompletionHandler(() {
      isSpeaking.value = false;
    });
  }

  /// Read text aloud. If [currentPageOnly] = true, reads only current page.
  void pdfTextToRead({bool currentPageOnly = false}) async {
    try {
      if (_doc == null) {
        Get.snackbar('Error', 'PDF not loaded yet');
        return;
      }

      final extractor = PdfTextExtractor(_doc!);
      final String text =
          currentPageOnly
              ? extractor.extractText(
                startPageIndex: currentPage.value - 1,
                endPageIndex: currentPage.value - 1,
              )
              : extractor.extractText();

      if (text.trim().isEmpty) {
        Get.snackbar('No text found', 'This PDF may be scanned images.');
        return;
      }

      await tts.stop(); // stop any previous speech
      isSpeaking.value = true;
      await tts.speak(text);
    } catch (e, stackTrace) {
      debugPrint('TTS/Text extraction error: $e\n$stackTrace');
      isSpeaking.value = false;
    }
  }

  Future<void> pauseTts() async {
    await tts.pause();
    isSpeaking.value = false;
  }

  Future<void> stopTts() async {
    await tts.stop();
    isSpeaking.value = false;
  }

  @override
  void onClose() {
    tts.stop();
    viewerController.dispose();
    super.onClose();
  }
}
