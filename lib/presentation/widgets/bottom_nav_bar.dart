import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppConstants.darkSurface : AppConstants.lightSurface;
    final activeColor = isDark
        ? AppConstants.darkAccent
        : AppConstants.lightAccent;
    final inactiveColor = isDark
        ? AppConstants.darkTextSecondary
        : AppConstants.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                isActive: currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: onTap,
              ),
              _buildNavItem(
                icon: Icons.camera_alt_rounded,
                label: 'Attendance',
                index: 1,
                isActive: currentIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: onTap,
              ),
              _buildNavItem(
                icon: Icons.event_note_rounded,
                label: 'Permission',
                index: 2,
                isActive: currentIndex == 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: onTap,
              ),
              _buildNavItem(
                icon: Icons.history_rounded,
                label: 'History',
                index: 3,
                isActive: currentIndex == 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required Function(int) onTap,
  }) {
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
