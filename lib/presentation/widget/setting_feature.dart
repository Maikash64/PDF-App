import 'package:flutter/material.dart';

class SettingFeature extends StatelessWidget {
  final String name;
  final Widget icon;
  final Color color;
  final void Function()? onClick; // Tap action
  const SettingFeature({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    // Screen size
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizes
    final iconSize = screenWidth * 0.09; // 8% of screen width
    final fontSize = screenWidth * 0.035; // 3.5% of screen width

    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: GestureDetector(
        onTap: onClick,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: FittedBox(fit: BoxFit.contain, child: icon),
            ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize.clamp(16, 24),
                fontWeight: FontWeight.w500,
                // color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
