import 'package:flutter/material.dart';
import 'package:pdf_production/core/theme/app_color.dart';

class RouteWedgetUi {
  // Bottom Navigation Bar UI
  static Widget buildBottomNavBar({
    required int selectedIndex,
    required Function(int) onTabChanged,
    required double height,
    required List<Map<String, String>> navItems,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onTabChanged(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 20 : 0,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Image.asset(
                  isSelected
                      ? (item['selected'] ?? '')
                      : (item['unselected'] ?? ''),
                  height: 24,
                  width: 24,
                  color: isSelected ? AppColor.primary : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColor.secondary : Colors.transparent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Options Menu UI
  static void showOptionsMenu(
    BuildContext context, {
    required Function() aTOz,
    required Function() zTOa,
    required Function() newest,
    required Function() oldest,
    required Function() largest,
    required Function() smallest,
  }) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.abc, color: AppColor.primary),
                title: const Text("Sort A to Z"),
                onTap: aTOz,
              ),
              ListTile(
                leading: const Icon(Icons.abc, color: AppColor.primary),
                title: const Text("Sort Z to A"),
                onTap: zTOa,
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_upward_outlined,
                  color: AppColor.primary,
                ),
                title: const Text("Sort by Newest Date"),
                onTap: newest,
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_downward_outlined,
                  color: AppColor.primary,
                ),
                title: const Text("Sort by Oldest Date"),
                onTap: oldest,
              ),
              ListTile(
                leading: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColor.primary,
                ),
                title: const Text("Sort by Largest Size"),
                onTap: largest,
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: AppColor.primary),
                title: const Text("Sort by Smallest Size"),
                onTap: smallest,
              ),
            ],
          ),
    );
  }
}
