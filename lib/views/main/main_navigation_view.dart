import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_sidebar.dart';
import '../contributors/contributor_list_view.dart';
import '../dashboard/dashboard_view.dart';
import '../settings/settings_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 1:
        return const ContributorListView();
      case 2:
        return const SettingsView();
      default:
        return DashboardView(
          onNavigateToContributors: () => _onTabTapped(1),
        );
    }
  }

  static const List<SidebarItemData> _destinations = [
    SidebarItemData(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    SidebarItemData(
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_alt_rounded,
      label: 'Contributors',
    ),
    SidebarItemData(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        if (isWideScreen) {
          // Responsive Custom Sidebar Navigation for Desktop/Tablet
          return Scaffold(
            backgroundColor: AppColors.bgLight,
            body: Row(
              children: [
                AppSidebar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabTapped,
                  destinations: _destinations,
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppColors.cardBorder),
                Expanded(child: _buildScreen()),
              ],
            ),
          );
        }

        // Mobile Bottom Navigation Bar
        return Scaffold(
          backgroundColor: AppColors.bgLight,
          body: _buildScreen(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.sidebarGreen,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              backgroundColor: AppColors.sidebarGreen,
              selectedItemColor: AppColors.primaryGold,
              unselectedItemColor: Colors.white60,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  activeIcon: Icon(Icons.people_alt_rounded),
                  label: 'Contributors',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

