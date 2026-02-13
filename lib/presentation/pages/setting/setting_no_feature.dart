import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SettingNoFeature extends StatefulWidget {
  const SettingNoFeature({super.key});

  @override
  State<SettingNoFeature> createState() => _SettingNoFeatureState();
}

class _SettingNoFeatureState extends State<SettingNoFeature> {
  final String appVersion = "1.0.0";

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("App will be available on Play Store soon 🚀"),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          title: const Center(
            child: Text(
              "About",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf,
                size: 65,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),

              const Text(
                "PDF Reader",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                "Version $appVersion",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),

              const SizedBox(height: 14),

              const Text(
                "A simple and powerful PDF management app designed for productivity.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),

          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _launchURL("https://www.linkedin.com/in/maikash-pp/");
              },
              child: const Text(
                "LinkedIn",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                _launchURL("https://www.instagram.com/maikash36/");
              },
              child: Text(
                "Instagram",
                style: TextStyle(color: Colors.red[800]),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        children: [
          // 🔹 Rate App
          ListTile(
            leading: const Icon(Icons.star_rate_rounded, color: Colors.amber),
            title: const Text("Rate App"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _comingSoon(context),
          ),

          const Divider(),

          // 🔹 Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.blue),
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _launchURL("https://pdf-reader-privacy-policy.vercel.app/");
            },
          ),

          const Divider(),

          // 🔹 Share App
          ListTile(
            leading: const Icon(Icons.share, color: Colors.green),
            title: const Text("Share App"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Share.share(
                "Check out my PDF Reader app! 🚀\nComing soon on Play Store.",
              );
            },
          ),

          const Divider(),

          // 🔹 Contact Support
          ListTile(
            leading: const Icon(Icons.email, color: Colors.redAccent),
            title: const Text("Contact Support"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _launchURL("mailto:maikashmaikash8@gmail.com");
            },
          ),

          const Divider(),

          // 🔹 About
          ListTile(
            leading: const Icon(Icons.info, color: Colors.purple),
            title: const Text("About"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showAboutDialog(context),
          ),

          const Divider(),

          // 🔹 Version
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                "Version $appVersion",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
