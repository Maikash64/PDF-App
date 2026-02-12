// favorites_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_production/backend/like_backend.dart';
import 'package:pdf_production/backend/files_backend.dart';
import 'package:pdf_production/core/assets/icons.dart';
import 'package:pdf_production/core/theme/app_color.dart';
import 'package:pdf_production/presentation/view/pdf_files_viewer.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  String _getFileNameFromPath(String path) {
    return path.split(RegExp(r'[\\/]+')).last;
  }

  @override
  Widget build(BuildContext context) {
    final likeController = Get.find<LikeBackend>();
    final pdfController = Get.find<PdfFilesController>();

    return Obx(() {
      final favoritePaths = likeController.likePdf;

      final favoriteFiles =
          pdfController.pdfFiles
              .where((file) => favoritePaths.contains(file[0]))
              .toList();

      if (favoriteFiles.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 60, color: AppColor.primary),
              const SizedBox(height: 20),
              const Text(
                "Your Favorite PDFs",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "No favorites yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: favoriteFiles.length,
        itemBuilder: (context, index) {
          final file = favoriteFiles[index];
          return _buildFavoriteListItem(
            context,
            file[0],
            file[1],
            file[2],
            likeController,
          );
        },
      );
    });
  }

  Widget _buildFavoriteListItem(
    BuildContext context,
    String filePath,
    String date,
    String size,
    LikeBackend likeController,
  ) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed from favorites')),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
