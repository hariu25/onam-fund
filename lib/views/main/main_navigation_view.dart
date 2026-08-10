import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        if (isWideScreen) {
          // Responsive NavigationRail for Tablet / Desktop
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabTapped,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: AppColors.primaryDarkGreen,
                  selectedIconTheme: const IconThemeData(color: AppColors.primaryGold, size: 28),
                  unselectedIconTheme: const IconThemeData(color: Colors.white70, size: 24),
                  selectedLabelTextStyle: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                  unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.park_rounded, color: AppColors.primaryDarkGreen, size: 28),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Contributors'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppColors.cardBorder),
                Expanded(child: _buildScreen()),
              ],
            ),
          );
        }

        // Mobile Bottom Navigation Bar
        return Scaffold(
          body: _buildScreen(),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              backgroundColor: AppColors.primaryDarkGreen,
              selectedItemColor: AppColors.primaryGold,
              unselectedItemColor: Colors.white60,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Contributors',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
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
