// pdf_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_production/backend/files_backend.dart';
import 'package:pdf_production/backend/like_backend.dart';
import 'package:pdf_production/core/assets/icons.dart';
import 'package:pdf_production/core/theme/app_color.dart';
import 'package:pdf_production/presentation/view/pdf_files_viewer.dart';
import 'package:pdf_production/presentation/widget/features_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

class PdfListPage extends StatelessWidget {
  final String? searchQuery;
  const PdfListPage({super.key, this.searchQuery});

  String _getFileNameFromPath(String filePath) {
    return path.basename(filePath);
  }

  @override
  Widget build(BuildContext context) {
    final PdfFilesController pdfController = Get.find();

    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            final files =
                searchQuery?.isNotEmpty ?? false
                    ? pdfController.pdfFiles
                        .where(
                          (file) => _getFileNameFromPath(
                            file[0],
                          ).toLowerCase().contains(searchQuery!.toLowerCase()),
                        )
                        .toList()
                    : pdfController.pdfFiles;

            return RefreshIndicator(
              onRefresh: pdfController.refreshFiles,
              child:
                  files.isNotEmpty
                      ? ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          final file = files[index];
                          return _buildListItem(
                            context,
                            file[0],
                            file[1],
                            file[2],
                          );
                        },
                      )
                      : const Center(
                        child: Text(
                          "No PDF files found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
            );
          }),
          Obx(() {
            return pdfController.isLoading.value
                ? Center(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const CircularProgressIndicator(
                      color: AppColor.primary,
                    ),
                  ),
                )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    String filePath,
    String date,
    String size,
  ) {
    final likeController = Get.find<LikeBackend>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.secondary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap:
                () => Get.to(
                  () => PDFViewerScreen(
                    pdfPath: filePath,
                    pdfName: _getFileNameFromPath(filePath),
                  ),
                ),
            child: Image.asset(AppIcons.pdfIcon, width: 40, height: 40),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap:
                  () => Get.to(
                    () => PDFViewerScreen(
                      pdfPath: filePath,
                      pdfName: _getFileNameFromPath(filePath),
                    ),
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFileNameFromPath(filePath),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(date, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      Text(size, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            final isFav = likeController.isFavorite(filePath);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.black,
              ),
              onPressed: () async {
                await likeController.toggleFavorite(filePath);
              },
            );
          }),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showOptionsMenu(context, filePath),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, String filePath) {
    final pdfController = Get.find<PdfFilesController>();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text("Rename"),
              onTap: () {
                Navigator.pop(context);
                FeaturesUi.confirmRenameFile(context, filePath, (
                  newName,
                ) async {
                  await pdfController.renameFile(filePath, newName);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share"),
              onTap: () {
                Navigator.pop(context);
                Share.shareXFiles([XFile(filePath)]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                FeaturesUi.confirmDelete(context, filePath, () async {
                  await pdfController.deleteFile(filePath);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
