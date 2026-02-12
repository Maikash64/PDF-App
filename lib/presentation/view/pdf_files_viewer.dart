import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:pdf_production/backend/pfd_view_backend.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;
  final String pdfName;

  const PDFViewerScreen({
    super.key,
    required this.pdfPath,
    required this.pdfName,
  });

  @override
  Widget build(BuildContext context) {
    final PDFViewerController controller = Get.find();

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(pdfName),
          backgroundColor: _getAppBarColor(controller),
          actions: [
            IconButton(
              icon: Icon(_getModeIcon(controller), color: Colors.white),
              onPressed: controller.toggleViewMode,
              tooltip: _getModeTooltip(controller),
            ),
          ],
        ),
        body: _buildPdfViewer(controller),
        bottomNavigationBar: _buildBottomToolbar(controller),
      ),
    );
  }

  Widget _buildPdfViewer(PDFViewerController controller) {
    return Stack(
      children: [
        if (!controller.isNormalMode)
          Container(
            color: controller.isDarkMode ? Colors.black : Colors.grey[900],
          ),
        _getColorFilteredViewer(controller),
        Positioned(
          left: 20,
          top: 20,
          child: Obx(
            () => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Page ${controller.currentPage}/${controller.totalPages}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getColorFilteredViewer(PDFViewerController controller) {
    final viewer = SfPdfViewer.file(
      File(pdfPath),
      key: controller.pdfViewerKey,
      controller: controller.viewerController,
      scrollDirection: controller.scrollDirection.value,
      onDocumentLoaded: controller.handleDocumentLoaded,
      onPageChanged: controller.handlePageChanged,
    );

    if (controller.isNormalMode) {
      return viewer;
    }

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(
        controller.isDarkMode
            ? const [
              -1,
              0,
              0,
              0,
              255,
              0,
              -1,
              0,
              0,
              255,
              0,
              0,
              -1,
              0,
              255,
              0,
              0,
              0,
              1,
              0,
            ]
            : const [
              0.95,
              0,
              0,
              0,
              -25,
              0,
              0.95,
              0,
              0,
              -25,
              0,
              0,
              0.95,
              0,
              -25,
              0,
              0,
              0,
              1,
              0,
            ],
      ),
      child: viewer,
    );
  }

  Widget _buildBottomToolbar(PDFViewerController controller) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: _getToolbarColor(controller),
        boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              controller.scrollDirection.value == PdfScrollDirection.horizontal
                  ? Icons.swipe
                  : Icons.swipe_down,
              color: _getIconColor(controller),
            ),
            onPressed: controller.toggleScrollDirection,
            tooltip: 'Toggle scroll direction',
          ),
          IconButton(
            onPressed: () async {
              if (pdfPath.isNotEmpty) {
                final file = XFile(pdfPath, name: basename(pdfPath));
                // ignore: deprecated_member_use
                await Share.shareXFiles([
                  file,
                ], text: 'Check out this PDF: $pdfName');
              } else {
                Get.snackbar(
                  'Error',
                  'No file found to share!',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            icon: Icon(Icons.share, color: _getIconColor(controller)),
          ),
          IconButton(
            icon: Icon(
              controller.isSpeaking.value
                  ? Icons.stop
                  : Icons.record_voice_over,
              color: _getIconColor(controller),
            ),
            onPressed: () {
              if (controller.isSpeaking.value) {
                controller.stopTts(); // stop reading
              } else {
                controller.pdfTextToRead(
                  currentPageOnly: true,
                ); // start reading
              }
            },
            tooltip:
                controller.isSpeaking.value ? 'Stop reading' : 'Read this page',
          ),
          Text(
            _getCurrentModeName(controller),
            style: TextStyle(color: _getTextColor(controller)),
          ),
        ],
      ),
    );
  }

  Color _getAppBarColor(PDFViewerController controller) {
    return controller.isDarkMode
        ? Colors.red[900]!
        : controller.isReadMode
        ? Colors.red[600]!
        : Colors.red;
  }

  IconData _getModeIcon(PDFViewerController controller) {
    return controller.isDarkMode
        ? Icons.light_mode
        : controller.isReadMode
        ? Icons.article
        : Icons.dark_mode;
  }

  String _getModeTooltip(PDFViewerController controller) {
    return controller.isDarkMode
        ? 'Switch to Normal Mode'
        : controller.isReadMode
        ? 'Switch to Dark Mode'
        : 'Switch to Read Mode';
  }

  String _getCurrentModeName(PDFViewerController controller) {
    return controller.isDarkMode
        ? 'Dark Mode'
        : controller.isReadMode
        ? 'Read Mode'
        : 'Normal Mode';
  }

  Color _getToolbarColor(PDFViewerController controller) {
    return controller.isDarkMode
        ? Colors.grey[900]!
        : controller.isReadMode
        ? Colors.blueGrey[800]!
        : Colors.white;
  }

  Color _getIconColor(PDFViewerController controller) {
    return controller.isNormalMode ? Colors.red : Colors.white;
  }

  Color _getTextColor(PDFViewerController controller) {
    return controller.isNormalMode ? Colors.black : Colors.white;
  }
}
