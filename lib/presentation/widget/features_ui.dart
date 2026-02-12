import 'package:flutter/material.dart';

class FeaturesUi {
  static void confirmDelete(
    BuildContext context,
    String filePath,
    VoidCallback onTap,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete File"),
            content: Text(
              "Are you sure you want to delete ${_getFileNameFromPath(filePath)}?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  onTap(); // Execute the provided onTap logic
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  static void confirmRenameFile(
    BuildContext context,
    String filePath,
    ValueChanged<String> onRename,
  ) {
    final TextEditingController controller = TextEditingController(
      text: _getFileNameFromPath(filePath).replaceAll('.pdf', ''),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Rename File"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                //labelText: "New File Name",
                hintText: "Enter new file name",
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a file name")),
                    );
                    return;
                  }
                  Navigator.pop(context); // Close the dialog
                  onRename(controller.text.trim()); // Pass the new name back
                },
                child: const Text(
                  "Rename",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
    );
  }

  static String _getFileNameFromPath(String filePath) {
    return filePath.split('/').last; // Simple file name extraction
  }
}
