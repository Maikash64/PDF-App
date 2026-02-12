import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:pdf_production/backend/files_backend.dart';

class FilePickPage extends StatelessWidget {
  const FilePickPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filesController = Get.find<PdfFilesController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Picked PDF File")),
      body: Obx(() {
        final files = filesController.pdfFiles;

        if (files.isEmpty) {
          return const Center(child: Text("No files picked"));
        }

        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final filePath = files[index][0]; // full path
            final fileDate = files[index][1]; // modified date
            final fileSize = files[index][2]; // size string

            return ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(p.basename(filePath)), // only filename
              subtitle: Text("Date: $fileDate | Size: $fileSize"),
              onTap: () {
                // Navigate with GetX
                Get.to(() => FileDetailPage(filePath: filePath));
              },
            );
          },
        );
      }),
    );
  }
}

// Example detail page (replace later with PDF viewer)
class FileDetailPage extends StatelessWidget {
  final String filePath;
  const FileDetailPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(p.basename(filePath))),
      body: Center(child: Text("Selected File Path:\n$filePath")),
    );
  }
}
