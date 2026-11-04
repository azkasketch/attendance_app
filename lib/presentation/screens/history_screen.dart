import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/permission_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/permission_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AttendanceProvider>().loadAttendance();
        context.read<PermissionProvider>().loadPermissions();
      }
    });
  }

  Color _getAvatarColor(String name) {
    if (name.trim().isEmpty) return Colors.blueGrey;
    final int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    return Colors.primaries[hash % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppConstants.darkBackground : AppConstants.lightBackground;
    final accentColor = isDark
        ? AppConstants.darkAccent
        : AppConstants.lightAccent;
    final textColor = isDark ? AppConstants.darkText : AppConstants.lightText;
    final textSecondaryColor =
        isDark ? AppConstants.darkTextSecondary : AppConstants.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Attendance History',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                  accentColor: accentColor,
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Attendance',
                  isSelected: _filter == 'attendance',
                  onTap: () => setState(() => _filter = 'attendance'),
                  accentColor: accentColor,
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Permission',
                  isSelected: _filter == 'permission',
                  onTap: () => setState(() => _filter = 'permission'),
                  accentColor: accentColor,
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: Consumer2<AttendanceProvider, PermissionProvider>(
              builder: (context, attendanceProvider, permissionProvider, child) {
                final attendanceList = attendanceProvider.attendanceList;
                final permissionList = permissionProvider.permissionList;

                List<Map<String, dynamic>> combined = [
                  ...attendanceList.map((a) => {'type': 'attendance', 'data': a}),
                  ...permissionList.map((p) => {'type': 'permission', 'data': p}),
                ];

                // Apply filter
                if (_filter == 'attendance') {
                  combined = combined.where((item) => item['type'] == 'attendance').toList();
                } else if (_filter == 'permission') {
                  combined = combined.where((item) => item['type'] == 'permission').toList();
                }

                combined.sort((a, b) {
                  final dateA = (a['data'] as dynamic).createdAt;
                  final dateB = (b['data'] as dynamic).createdAt;
                  return dateB.compareTo(dateA);
                });

                if (combined.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: textSecondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada riwayat presensi",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: combined.length,
                  itemBuilder: (context, index) {
                    final item = combined[index];
                    final type = item['type'];
                    final data = item['data'];

                    if (type == 'attendance') {
                      return _buildAttendanceCard(
                        context,
                        data as AttendanceModel,
                        attendanceProvider,
                        isDark,
                        textColor,
                        textSecondaryColor,
                      );
                    } else {
                      return _buildPermissionCard(
                        context,
                        data as PermissionModel,
                        isDark,
                        textColor,
                        textSecondaryColor,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(
    BuildContext context,
    AttendanceModel data,
    AttendanceProvider provider,
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
  ) {
    final surfaceColor =
        isDark ? AppConstants.darkSurface : AppConstants.lightSurface;
    final accentColor = isDark
        ? AppConstants.darkAccent
        : AppConstants.lightAccent;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getAvatarColor(data.name),
                        _getAvatarColor(data.name).withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      data.name.isNotEmpty ? data.name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.datetime,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Attendance',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.description,
              'Keterangan',
              data.description,
              textSecondaryColor,
              textColor,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.location_on,
              'Lokasi',
              data.address,
              textSecondaryColor,
              textColor,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, data.id, provider),
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context,
    PermissionModel data,
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
  ) {
    final surfaceColor =
        isDark ? AppConstants.darkSurface : AppConstants.lightSurface;
    final secondaryAccent = isDark
        ? AppConstants.darkSecondaryAccent
        : AppConstants.lightSecondaryAccent;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getAvatarColor(data.name),
                        _getAvatarColor(data.name).withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      data.name.isNotEmpty ? data.name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.fromDate} - ${data.toDate}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: secondaryAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Permission',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: secondaryAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.description,
              'Keterangan',
              data.description,
              textSecondaryColor,
              textColor,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.event_note,
              'Tipe',
              'Permission',
              textSecondaryColor,
              textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color textSecondaryColor,
    Color textColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: textSecondaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 13, color: textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, String id, AttendanceProvider provider) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondaryColor =
        isDark ? AppConstants.darkTextSecondary : AppConstants.lightTextSecondary;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Data',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data ini?',
          style: GoogleFonts.poppins(color: textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.deleteAttendance(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data berhasil dihapus',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppConstants.darkText : AppConstants.lightText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }
}
