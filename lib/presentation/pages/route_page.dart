import 'package:flutter/material.dart';
import 'package:pdf_production/core/assets/icons.dart';
import 'package:pdf_production/core/theme/app_color.dart';
import 'package:pdf_production/presentation/pages/favorites_page.dart';
import 'package:pdf_production/presentation/pages/pdf_listpage.dart';
import 'package:pdf_production/presentation/pages/setting/setting_page.dart';
import 'package:pdf_production/presentation/widget/route_wedget.dart';
import 'package:get/get.dart';
import 'package:pdf_production/backend/files_backend.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  int _selectedIndex = 0;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier('');
  final PdfFilesController _pdfController = Get.put(PdfFilesController());

  static const List<Map<String, String>> _navItems = [
    {
      'unselected': AppIcons.homeIconD,
      'selected': AppIcons.homeIconS,
      'label': 'Home',
    },
    {
      'unselected': AppIcons.heartIconD,
      'selected': AppIcons.heartIconS,
      'label': 'Favorite',
    },
    {
      'unselected': AppIcons.settingIconD,
      'selected': AppIcons.settingIconS,
      'label': 'Settings',
    },
  ];

  final List<Widget> _pages = [
    PdfListPage(key: ValueKey('pdfListPage')),
    const FavoritesPage(),
    const SettingPage(),
  ];

  void _changeTab(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        _searchQueryNotifier.value = '';
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(screenSize.width, screenSize.height),
          Expanded(
            child:
                _selectedIndex ==
                        0 // edit
                    ? ValueListenableBuilder<String>(
                      valueListenable: _searchQueryNotifier,
                      builder: (context, query, _) {
                        return PdfListPage(
                          key: const ValueKey('pdfListPage'),
                          searchQuery: query,
                        );
                      },
                    )
                    : _pages[_selectedIndex], // edit
            ///Edited currently
          ),
        ],
      ),
      bottomNavigationBar: RouteWedgetUi.buildBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChanged: _changeTab,
        height: 70,
        navItems: _navItems,
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.03,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Row(
          key: ValueKey(_showSearchBar),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _toggleSearch,
              child: Material(
                color: AppColor.secondary,
                borderRadius: BorderRadius.circular(50),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child:
                          _showSearchBar
                              ? Image.asset(
                                AppIcons.closeIcon,
                                width: screenWidth * 0.06,
                              )
                              : Image.asset(
                                AppIcons.searchIcon,
                                width: screenWidth * 0.06,
                              ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      _showSearchBar
                          ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Search",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.grey,
                              ),
                            ),
                            style: TextStyle(fontSize: screenWidth * 0.05),
                            onChanged:
                                (value) => _searchQueryNotifier.value = value,
                          )
                          : Text(
                            "PDF Viewer",
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: AppColor.secondary,
                size: screenWidth * 0.08,
              ),
              onPressed:
                  () => RouteWedgetUi.showOptionsMenu(
                    context,
                    aTOz: () => _pdfController.sortByNameAZ(),
                    zTOa: () => _pdfController.sortByNameZA(),
                    newest: () => _pdfController.sortByNewest(),
                    oldest: () => _pdfController.sortByOldest(),
                    largest: () => _pdfController.sortByLargest(),
                    smallest: () => _pdfController.sortBySmallest(),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
