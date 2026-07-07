import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _goBranch,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariantFull,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            shadows: [
              Shadow(
                color: AppColors.primary,
                blurRadius: 10.0,
              ),
            ],
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: [
            _buildNavItem(
              icon: Icons.home_filled,
              label: 'Home',
              isSelected: navigationShell.currentIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.calendar_today_outlined,
              label: 'Book',
              isSelected: navigationShell.currentIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.list_alt,
              label: 'Live Queue',
              isSelected: navigationShell.currentIndex == 2,
            ),
            _buildNavItem(
              icon: Icons.hourglass_empty,
              label: 'My Queue',
              isSelected: navigationShell.currentIndex == 3,
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isSelected: navigationShell.currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Icon(
          icon,
          size: 26,
          shadows: isSelected
              ? [
                  const Shadow(
                    color: AppColors.primary,
                    blurRadius: 12.0,
                  )
                ]
              : null,
        ),
      ),
      label: label,
    );
  }
}
