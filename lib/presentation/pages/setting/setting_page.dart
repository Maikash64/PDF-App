// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_production/backend/setting_features_backend.dart';
import 'package:pdf_production/presentation/pages/setting/file_pick_page.dart';
import 'package:pdf_production/presentation/widget/setting_feature.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // === Functions (moved outside build for performance) ===

  final settingFeatureController = Get.find<SettingFeaturesBackend>();
  void one() => print("Function fucc Called");
  void two() => print("Function Two Called");
  void three() => print("Function Three Called");
  void four() => print("Function Four Called");
  void five() => print("Function Five Called");
  void six() => print("Function Six Called");
  void seven() => print("Function Seven Called");
  void eight() => print("Function Eight Called");
  void nine() => print("Function Nine Called");
  void ten() => print("Function Ten Called");
  void eleven() => print("Function Eleven Called");

  late final List<VoidCallback> functionsCall;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> features = [
      {
        "name": "Compress File",
        "icon": Icon(Icons.compress, color: Colors.white),
        "color": Colors.blueAccent,
        "function": two,
      },
      {
        "name": "Split File",
        "icon": Icon(Icons.call_split, color: Colors.white),
        "color": Colors.purpleAccent,
        "function": three,
      },
      {
        "name": "Merge File",
        "icon": Icon(Icons.merge, color: Colors.white),
        "color": Colors.greenAccent.shade700,
        "function": four,
      },
      {
        "name": "Password File",
        "icon": Icon(Icons.lock, color: Colors.white),
        "color": Colors.redAccent.shade200,
        "function": () => Get.to(FilePickPage()),
      },
      {
        "name": "Create PDF with Images",
        "icon": Icon(Icons.image, color: Colors.white),
        "color": Colors.tealAccent.shade700,
        "function": six,
      },
      {
        "name": "Scan to PDFs",
        "icon": Icon(Icons.camera_alt, color: Colors.white),
        "color": Colors.indigoAccent,
        "function": seven,
      },
      {
        "name": "Rate Us",
        "icon": Icon(Icons.star_rate, color: Colors.white),
        "color": Colors.amber.shade700,
        "function": eight,
      },
      {
        "name": "Help",
        "icon": Icon(Icons.help_outline, color: Colors.white),
        "color": Colors.lightBlueAccent,
        "function": nine,
      },
      {
        "name": "Terms & C",
        "icon": Icon(Icons.description, color: Colors.white),
        "color": Colors.deepPurple.shade400,
        "function": ten,
      },
      {
        "name": "Digital Signature",
        "icon": Icon(Icons.edit, color: Colors.white),
        "color": Colors.pinkAccent.shade400,
        "function": eleven,
      },
    ];

    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 per row
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1.0,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return SettingFeature(
            name: features[index]["name"],
            icon: features[index]["icon"],
            color: features[index]["color"],
            // onClick: functionsCall[index], // Pass function reference directly
            onClick: features[index]["function"],
          );
        },
      ),
    );
  }
}
