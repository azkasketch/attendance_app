import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/location_helper.dart';
import '../../core/utils/face_detection_helper.dart';
import '../../data/models/attendance_model.dart';
import '../providers/attendance_provider.dart';

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
        if (mounted) setState(() => isCameraReady = false);
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
      // Don't call setState if widget is already disposed
      if (mounted) {
        setState(() => isCameraReady = false);
      }
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
            SnackBar(
              content: Text(
                'Wajah tidak terdeteksi',
                style: GoogleFonts.poppins(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal: $e',
              style: GoogleFonts.poppins(),
            ),
          ),
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
        SnackBar(
          content: Text(
            'Nama tidak boleh kosong',
            style: GoogleFonts.poppins(),
          ),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppConstants.darkBackground : AppConstants.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Attendance Record',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: capturedImage == null ? _buildCameraView() : _buildFormView(),
    );
  }

  Widget _buildCameraView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppConstants.darkPrimary
        : AppConstants.lightPrimary;
    final accentColor = isDark
        ? AppConstants.darkAccent
        : AppConstants.lightAccent;
    final textSecondaryColor =
        isDark ? AppConstants.darkTextSecondary : AppConstants.lightTextSecondary;

    if (!isCameraReady) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined,
                  size: 64, color: textSecondaryColor),
              const SizedBox(height: 16),
              Text(
                'Kamera tidak tersedia',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gunakan Android/iOS device',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => capturedImage = null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lanjut Tanpa Foto',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CameraPreview(controller!),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
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
            child: ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: Text(
                'Take Selfie',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppConstants.darkPrimary
        : AppConstants.lightPrimary;
    final accentColor = isDark
        ? AppConstants.darkAccent
        : AppConstants.lightAccent;
    final textColor = isDark ? AppConstants.darkText : AppConstants.lightText;
    final textSecondaryColor =
        isDark ? AppConstants.darkTextSecondary : AppConstants.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          if (capturedImage != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(capturedImage!.path),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            style: GoogleFonts.poppins(color: textColor),
            decoration: InputDecoration(
              labelText: 'Nama',
              labelStyle: GoogleFonts.poppins(color: textSecondaryColor),
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _statusController,
            style: GoogleFonts.poppins(color: textColor),
            decoration: InputDecoration(
              labelText: 'Status',
              labelStyle: GoogleFonts.poppins(color: textSecondaryColor),
              prefixIcon: const Icon(Icons.check_circle),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppConstants.darkSurface
                  : AppConstants.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currentAddress.isEmpty ? 'Lokasi belum diambil' : currentAddress,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isFetchingLocation ? null : _getLocation,
            icon: isFetchingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.location_on),
            label: Text(
              'Ambil Lokasi',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
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
              onPressed: _submitAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Submit',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
