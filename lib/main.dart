import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf_production/backend/files_backend.dart';
import 'package:pdf_production/backend/like_backend.dart';
import 'package:pdf_production/backend/pfd_view_backend.dart';
import 'package:pdf_production/backend/setting_features_backend.dart';
import 'package:pdf_production/presentation/pages/permission_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open the liked files box once
  final likedBox = await Hive.openBox<String>('likedFilesBox');

  // Inject controllers
  final pdfController = Get.put(PdfFilesController());
  Get.put(LikeBackend(likedBox)); // Pass box here
  Get.put(PDFViewerController());
  Get.put(SettingFeaturesBackend());
  // Load PDFs before running app
  await pdfController.loadPdfFiles();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Reader',
      home: const PermissionRequestScreen(),
    );
  }
}
