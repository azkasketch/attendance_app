import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Permission / Leave')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text("Form Pengajuan Izin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.primaryColor), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)), maxLines: 3, validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _fromDateController, decoration: InputDecoration(labelText: 'Dari Tanggal', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.calendar_today), suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () => _pickDate(_fromDateController))), readOnly: true, validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _toDateController, decoration: InputDecoration(labelText: 'Sampai Tanggal', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.calendar_today), suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () => _pickDate(_toDateController))), readOnly: true, validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                const SizedBox(height: 32),
                Consumer<PermissionProvider>(builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _submitPermission,
                    style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: provider.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Text('Submit Permission', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
