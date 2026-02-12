import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class PdfFilesController extends GetxController {
  var pdfFiles = <List<String>>[].obs;
  var isLoading = false.obs;
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () async {
      await fetchPdfFiles();
    });
  }

  // ==================== FILE FETCHING ====================
  Future<void> fetchPdfFiles() async {
    try {
      isLoading(true);
      var permissionStatus = await _requestPermissions();

      if (permissionStatus.isGranted) {
        var directories = await ExternalPath.getExternalStorageDirectories();

        if (directories != null && directories.isNotEmpty) {
          pdfFiles.clear();
          for (var directory in directories) {
            if (!_isRestrictedDirectory(directory)) {
              await _scanDirectory(directory);
            }
          }
          if (pdfFiles.isEmpty) {
            _showSnackbar('Info', 'No PDF files found.');
          }
        } else {
          _showSnackbar('Error', 'No accessible storage directories found.');
        }
      } else {
        _showSnackbar(
          'Permission Denied',
          'Storage permission is required to display PDFs.',
        );
      }
    } catch (e) {
      debugPrint("Error fetching PDF files: $e");
      _showSnackbar('Error', 'An error occurred while fetching files.');
    } finally {
      isLoading(false);
    }
  }

  // ==================== SORTING METHODS ====================
  void sortByNameAZ() {
    pdfFiles.sort((a, b) {
      final nameA = path.basename(a[0]).toLowerCase();
      final nameB = path.basename(b[0]).toLowerCase();
      return nameA.compareTo(nameB);
    });
    update();
  }

  void sortByNameZA() {
    pdfFiles.sort((a, b) {
      final nameA = path.basename(a[0]).toLowerCase();
      final nameB = path.basename(b[0]).toLowerCase();
      return nameB.compareTo(nameA);
    });
    update();
  }

  void sortByNewest() {
    try {
      pdfFiles.sort((a, b) {
        final dateA = _dateFormat.parse(a[1]);
        final dateB = _dateFormat.parse(b[1]);
        return dateB.compareTo(dateA); // Newest first
      });
      update();
    } catch (e) {
      debugPrint("Error sorting by newest: $e");
      _showSnackbar('Error', 'Failed to sort by date');
    }
  }

  void sortByOldest() {
    try {
      pdfFiles.sort((a, b) {
        final dateA = _dateFormat.parse(a[1]);
        final dateB = _dateFormat.parse(b[1]);
        return dateA.compareTo(dateB); // Oldest first
      });
      update();
    } catch (e) {
      debugPrint("Error sorting by oldest: $e");
      _showSnackbar('Error', 'Failed to sort by date');
    }
  }

  void sortByLargest() {
    try {
      pdfFiles.sort((a, b) {
        final sizeA = _parseFileSizeToBytes(a[2]);
        final sizeB = _parseFileSizeToBytes(b[2]);
        return sizeB.compareTo(sizeA); // Largest first
      });
      update();
    } catch (e) {
      debugPrint("Error sorting by size: $e");
      _showSnackbar('Error', 'Failed to sort by size');
    }
  }

  void sortBySmallest() {
    try {
      pdfFiles.sort((a, b) {
        final sizeA = _parseFileSizeToBytes(a[2]);
        final sizeB = _parseFileSizeToBytes(b[2]);
        return sizeA.compareTo(sizeB); // Smallest first
      });
      update();
    } catch (e) {
      debugPrint("Error sorting by size: $e");
      _showSnackbar('Error', 'Failed to sort by size');
    }
  }

  // ==================== SIZE PARSING ====================
  double _parseFileSizeToBytes(String sizeString) {
    try {
      final parts = sizeString.split(' ');
      if (parts.length != 2) return 0;

      final value = double.tryParse(parts[0]) ?? 0;
      final unit = parts[1].toUpperCase();

      switch (unit) {
        case 'GB':
          return value * 1073741824; // 1024^3
        case 'MB':
          return value * 1048576; // 1024^2
        case 'KB':
          return value * 1024;
        case 'B':
          return value;
        default:
          return 0;
      }
    } catch (e) {
      debugPrint("Error parsing file size: $e");
      return 0;
    }
  }

  // ==================== PERMISSION HANDLING ====================
  Future<PermissionStatus> _requestPermissions() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

    if (androidInfo.version.sdkInt < 30) {
      return await Permission.storage.request();
    } else {
      return await Permission.manageExternalStorage.request();
    }
  }

  bool _isRestrictedDirectory(String path) {
    const restrictedPaths = ['/Android/data', '/Android/obb'];
    return restrictedPaths.any(path.contains);
  }

  // ==================== FILE SCANNING ====================
  Future<void> _scanDirectory(String dirPath) async {
    try {
      var directory = Directory(dirPath);
      if (!await directory.exists()) return;

      await for (var entity in directory.list(recursive: false)) {
        if (entity is File && entity.path.toLowerCase().endsWith(".pdf")) {
          final filePath = entity.path;
          final modifiedDate = await _getFileDate(entity);
          final fileSize = await _getFileSize(entity);

          if (!pdfFiles.any((file) => file[0] == filePath)) {
            pdfFiles.add([filePath, modifiedDate, fileSize]);
          }
        } else if (entity is Directory &&
            !_isRestrictedDirectory(entity.path)) {
          await _scanDirectory(entity.path);
        }
      }
    } catch (e) {
      debugPrint("Error scanning directory: $e");
    }
  }

  // ==================== FILE METADATA ====================
  Future<String> _getFileDate(File file) async {
    try {
      final stat = await file.stat();
      final modified = stat.modified;
      return _dateFormat.format(modified);
    } catch (e) {
      debugPrint("Error getting file date: $e");
      return "01-01-1970"; // Default date if error occurs
    }
  }

  Future<String> _getFileSize(File file) async {
    try {
      final sizeInBytes = await file.length();
      return _formatFileSize(sizeInBytes);
    } catch (e) {
      debugPrint("Error getting file size: $e");
      return "0 B";
    }
  }

  String _formatFileSize(int bytes) {
    const suffixes = ["B", "KB", "MB", "GB"];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(2)} ${suffixes[i]}";
  }

  // ==================== FILE OPERATIONS ====================
  Future<void> deleteFile(String filePath) async {
    try {
      var file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        pdfFiles.removeWhere((fileInfo) => fileInfo[0] == filePath);
        update();
        _showSnackbar('Success', 'File deleted successfully');
      } else {
        _showSnackbar('Error', 'File not found');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to delete file: $e');
      debugPrint("Error deleting file: $e");
    }
  }

  Future<void> renameFile(String oldPath, String newName) async {
    try {
      if (!newName.toLowerCase().endsWith('.pdf')) {
        newName += '.pdf';
      }

      final oldFile = File(oldPath);
      if (!await oldFile.exists()) {
        _showSnackbar('Error', 'File not found');
        return;
      }

      final directory = path.dirname(oldPath);
      final newPath = path.join(directory, newName);

      if (await File(newPath).exists()) {
        _showSnackbar('Error', 'A file with this name already exists');
        return;
      }

      await oldFile.rename(newPath);

      final index = pdfFiles.indexWhere((file) => file[0] == oldPath);
      if (index != -1) {
        final modifiedDate = await _getFileDate(File(newPath));
        final fileSize = await _getFileSize(File(newPath));
        pdfFiles[index] = [newPath, modifiedDate, fileSize];
        update();
        _showSnackbar('Success', 'File renamed successfully');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to rename file: $e');
      debugPrint("Error renaming file: $e");
    }
  }

  // ==================== UTILITIES ====================
  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 1),
    );
  }

  Future<void> refreshFiles() async {
    pdfFiles.clear();
    await fetchPdfFiles();
    update();
  }

  Future<void> loadPdfFiles() async {}
}
