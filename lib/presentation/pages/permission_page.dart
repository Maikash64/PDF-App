import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pdf_production/core/assets/icons.dart';
import 'package:pdf_production/presentation/pages/route_page.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PermissionRequestScreenState createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
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
      debugPrint("Error requesting permission: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: requestPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          return const RoutePage();
        } else {
          return Scaffold(
            body: Container(
              color: Colors.red[800],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
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
                    "Permission Required",
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'This app requires storage permissions to list and access your PDF files. Click "Continue" to grant permission.After give the permissions close the app and open.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      bool granted = await requestPermission();
                      if (granted) {
                        Get.off(() => const RoutePage());
                      } else {
                        Get.snackbar(
                          'Permission Denied',
                          'Storage permission is required to display PDFs.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
