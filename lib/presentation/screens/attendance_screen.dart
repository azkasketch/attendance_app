import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/location_helper.dart';
import '../../core/utils/face_detection_helper.dart';
import '../../data/models/attendance_model.dart';
import '../providers/attendance_provider.dart';
import 'home_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  CameraController? controller;
  bool isCameraReady = false;
  XFile? capturedImage;
  final _nameController = TextEditingController();
  final _statusController = TextEditingController();
  Position? currentPosition;
  String currentAddress = '';
  bool isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    _nameController.dispose();
    _statusController.dispose();
    FaceDetectionHelper.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => isCameraReady = false);
        return;
      }
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller!.initialize();
      if (mounted) setState(() => isCameraReady = true);
    } catch (e) {
      setState(() => isCameraReady = false);
    }
  }

  Future<void> _takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return;
    try {
      final image = await controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await FaceDetectionHelper.detectFaces(inputImage);
      if (faces.isNotEmpty) {
        setState(() => capturedImage = image);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wajah tidak terdeteksi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  Future<void> _getLocation() async {
    setState(() => isFetchingLocation = true);
    final position = await LocationHelper.getCurrentPosition();
    if (position != null) {
      final address = await LocationHelper.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        currentPosition = position;
        currentAddress = address;
      });
    }
    setState(() => isFetchingLocation = false);
  }

  Future<void> _submitAttendance() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }
    final attendance = AttendanceModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      address: currentAddress,
      description: _statusController.text.trim(),
      datetime: DateFormatter.formatDateTime(DateTime.now()),
      latitude: currentPosition?.latitude,
      longitude: currentPosition?.longitude,
      createdAt: DateTime.now(),
    );
    final provider = context.read<AttendanceProvider>();
    await provider.addAttendance(attendance);
    if (provider.errorMessage == null && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Record')),
      body: capturedImage == null ? _buildCameraView() : _buildFormView(),
    );
  }

  Widget _buildCameraView() {
    if (!isCameraReady) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Kamera tidak tersedia', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              const Text('Gunakan Android/iOS device', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => capturedImage = null),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A008F), foregroundColor: Colors.white),
                child: const Text('Lanjut Tanpa Foto'),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        Expanded(child: CameraPreview(controller!)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _takePicture,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Selfie'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A008F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          if (capturedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(capturedImage!.path), height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _statusController,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder(), prefixIcon: Icon(Icons.check_circle)),
          ),
          const SizedBox(height: 16),
          Text('Lokasi: $currentAddress'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isFetchingLocation ? null : _getLocation,
            icon: isFetchingLocation ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.location_on),
            label: const Text('Ambil Lokasi'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitAttendance,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A008F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
