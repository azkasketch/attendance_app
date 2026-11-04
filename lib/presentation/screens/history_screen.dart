import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: Consumer2<AttendanceProvider, PermissionProvider>(
        builder: (context, attendanceProvider, permissionProvider, child) {
          final attendanceList = attendanceProvider.attendanceList;
          final permissionList = permissionProvider.permissionList;

          final combined = [
            ...attendanceList.map((a) => {'type': 'attendance', 'data': a}),
            ...permissionList.map((p) => {'type': 'permission', 'data': p}),
          ]..sort((a, b) {
            final dateA = (a['data'] as dynamic).createdAt;
            final dateB = (b['data'] as dynamic).createdAt;
            return dateB.compareTo(dateA);
          });

          if (combined.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Belum ada riwayat presensi", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: combined.length,
            itemBuilder: (context, index) {
              final item = combined[index];
              final type = item['type'];
              final data = item['data'];

              if (type == 'attendance') {
                return _buildAttendanceCard(context, data as AttendanceModel, attendanceProvider);
              } else {
                return _buildPermissionCard(context, data as PermissionModel);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context, AttendanceModel data, AttendanceProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getAvatarColor(data.name),
                  child: Text(data.name.isNotEmpty ? data.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(data.datetime, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.description, 'Keterangan', data.description),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Lokasi', data.address),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteDialog(context, data.id, provider), tooltip: 'Hapus'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(BuildContext context, PermissionModel data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getAvatarColor(data.name),
                  child: Text(data.name.isNotEmpty ? data.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${data.fromDate} - ${data.toDate}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.description, 'Keterangan', data.description),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.event_note, 'Tipe', 'Permission'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              Text(value, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String id, AttendanceProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      await provider.deleteAttendance(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green));
      }
    }
  }
}
