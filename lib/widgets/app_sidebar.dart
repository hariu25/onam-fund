import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class SidebarItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const SidebarItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<SidebarItemData> destinations;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.sidebarGreen,
      child: Column(
        children: [
          // Application Logo & Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF0F5A47), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGold, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.payments_rounded,
                      color: AppColors.primaryDarkGreen,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'സംഭാവന',
                        style: GoogleFonts.notoSansMalayalam(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Text(
                        'Contribution Portal',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Menu Section Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MAIN MENU',
                style: TextStyle(
                  color: Color(0xFF8BA69E),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Navigation Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final item = destinations[index];
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => onDestinationSelected(index),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.secondaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3), width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? AppColors.primaryGold : Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer info
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'v1.0.0 • സംഭാവന',
              style: TextStyle(
                color: Color(0xFF68877E),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

