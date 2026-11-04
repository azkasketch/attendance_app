import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/permission_model.dart';
import '../providers/permission_provider.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormatter.formatDate(pickedDate);
      });
    }
  }

  Future<void> _submitPermission() async {
    if (!_formKey.currentState!.validate()) return;
    final permission = PermissionModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      fromDate: _fromDateController.text,
      toDate: _toDateController.text,
      createdAt: DateTime.now(),
    );
    final provider = context.read<PermissionProvider>();
    await provider.addPermission(permission);
    if (provider.errorMessage == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission berhasil disimpan'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
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
    final textColor = isDark ? AppConstants.darkText : AppConstants.lightText;
    final textSecondaryColor =
        isDark ? AppConstants.darkTextSecondary : AppConstants.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Permission / Leave',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, accentColor],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_note_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Form Pengajuan Izin",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.poppins(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    labelStyle: GoogleFonts.poppins(color: textSecondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: GoogleFonts.poppins(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    labelStyle: GoogleFonts.poppins(color: textSecondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fromDateController,
                  style: GoogleFonts.poppins(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Dari Tanggal',
                    labelStyle: GoogleFonts.poppins(color: textSecondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () => _pickDate(_fromDateController),
                    ),
                  ),
                  readOnly: true,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _toDateController,
                  style: GoogleFonts.poppins(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Sampai Tanggal',
                    labelStyle: GoogleFonts.poppins(color: textSecondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () => _pickDate(_toDateController),
                    ),
                  ),
                  readOnly: true,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                Consumer<PermissionProvider>(
                  builder: (context, provider, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, accentColor],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed:
                            provider.isLoading ? null : _submitPermission,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Submit Permission',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
