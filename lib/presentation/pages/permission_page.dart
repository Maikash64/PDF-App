import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pdf_production/core/assets/icons.dart';
import 'package:pdf_production/presentation/pages/route_page.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  bool? granted;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  // ---------------- CHECK PERMISSION ----------------

  Future<void> checkPermission() async {
    bool result = await requestPermission();
    setState(() => granted = result);

    if (result) {
      Get.off(() => const RoutePage());
    }
  }

  // ---------------- REQUEST PERMISSION ----------------

  Future<bool> requestPermission() async {
    try {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;

      PermissionStatus permissionStatus;

      if (androidDeviceInfo.version.sdkInt < 30) {
        permissionStatus = await Permission.storage.request();
      } else {
        permissionStatus = await Permission.manageExternalStorage.request();
      }

      return permissionStatus.isGranted;
    } catch (e) {
      debugPrint("Permission error: $e");
      return false;
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    // loading state
    if (granted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // permission denied UI
    return Scaffold(
      body: Container(
        color: Colors.red[800],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome",
              style: TextStyle(color: Colors.white, fontSize: 40),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(AppIcons.heartIconD),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Storage Permission Required",
              style: TextStyle(color: Colors.white, fontSize: 28),
              textAlign: TextAlign.center,
            ),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'PDF Production needs storage permission to access and display PDF files stored on your device.\n\nWe do not collect or share any files. Everything stays only on your device.\n\nTap "Continue" to grant permission.',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                bool result = await requestPermission();

                if (result) {
                  Get.off(() => const RoutePage());
                } else {
                  Get.snackbar(
                    'Permission Required',
                    'Storage permission is needed to load your PDF files.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
