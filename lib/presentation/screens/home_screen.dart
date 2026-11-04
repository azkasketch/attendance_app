import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/bottom_nav_bar.dart';
import 'attendance_screen.dart';
import 'permission_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const AttendanceScreen(),
    const PermissionScreen(),
    const HistoryScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppConstants.darkBackground : AppConstants.lightBackground;
    final primaryColor = isDark
        ? AppConstants.darkPrimary
        : AppConstants.lightPrimary;
    final accentColor = isDark
        ? AppConstants.darkAccent
        : AppConstants.lightAccent;
    final secondaryAccent = isDark
        ? AppConstants.darkSecondaryAccent
        : AppConstants.lightSecondaryAccent;
    final textColor = isDark ? AppConstants.darkText : AppConstants.lightText;
    final textSecondaryColor =
        isDark ? AppConstants.darkTextSecondary : AppConstants.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome to ${AppConstants.appName}',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      label: 'Present',
                      value: '12',
                      color: accentColor,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.event_busy,
                      label: 'Absent',
                      value: '2',
                      color: secondaryAccent,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Menu Section
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _MenuCard(
                      title: "Attendance Record",
                      subtitle: "Take selfie and record attendance",
                      icon: Icons.camera_alt_rounded,
                      gradient: LinearGradient(
                        colors: [primaryColor, accentColor],
                      ),
                      onTap: () {
                        // Navigate via bottom nav - handled by parent
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuCard(
                      title: "Permission / Leave",
                      subtitle: "Submit leave request",
                      icon: Icons.event_note_rounded,
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryAccent],
                      ),
                      onTap: () {
                        // Navigate via bottom nav - handled by parent
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuCard(
                      title: "Attendance History",
                      subtitle: "View all records",
                      icon: Icons.history_rounded,
                      gradient: LinearGradient(
                        colors: [accentColor, secondaryAccent],
                      ),
                      onTap: () {
                        // Navigate via bottom nav - handled by parent
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        isDark ? AppConstants.darkSurface : AppConstants.lightSurface;
    final textColor = isDark ? AppConstants.darkText : AppConstants.lightText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppConstants.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppConstants.darkSurface : AppConstants.lightSurface;
    final textColor = isDark ? AppConstants.darkText : AppConstants.lightText;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppConstants.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: AppConstants.darkTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
