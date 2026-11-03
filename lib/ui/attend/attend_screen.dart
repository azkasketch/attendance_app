import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:attendance_app/utils/face_detection/google_ml_kit.dart';
import 'package:attendance_app/ui/home_screen.dart';

class AttendScreen extends StatefulWidget {
  final XFile? image;
  
  const AttendScreen({super.key, this.image});

  @override
  State<AttendScreen> createState() => _AttendScreenState();
}

class _AttendScreenState extends State<AttendScreen> {
  CameraController? controller;
  bool isCameraReady = false;
  bool isBusy = false;
  bool isLoading = false;
  
  final CollectionReference _dataCollection = 
      FirebaseFirestore.instance.collection('attendance');
  
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector();
  
  final _nameController = TextEditingController();
  final _statusController = TextEditingController();
  
  double dLat = 0.0;
  double dLong = 0.0;
  String strAlamat = '';
  String strDateTime = '';
  
  @override
  void initState() {
    super.initState();
    strDateTime = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    if (widget.image == null) {
      initializeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _faceDetector.close();
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
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

    try {
      await controller!.initialize();
      if (mounted) setState(() => isCameraReady = true);
    } catch (e) {
      debugPrint("Failed to initialize camera: $e");
    }
  }

  Future<void> _takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    try {
      final image = await controller!.takePicture();
      _showLoaderDialog();
      
      final inputImage = InputImage.fromFilePath(image.path);
      await processImage(inputImage, image);
    } catch (e) {
      debugPrint("Error taking picture: $e");
      _showSnackBar("Gagal mengambil foto: $e", Icons.error_outline);
    }
  }

  Future<void> processImage(InputImage inputImage, XFile imageFile) async {
    if (isBusy) return;
    isBusy = true;

    try {
      final faces = await _faceDetector.processImage(inputImage);
      isBusy = false;

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (faces.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AttendScreen(image: imageFile),
          ),
        );
      } else {
        _showSnackBar("Wajah tidak terdeteksi! Pastikan wajah terlihat jelas di bingkai.", Icons.warning_amber_rounded);
      }
    } catch (e) {
      isBusy = false;
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showSnackBar("Gagal memproses deteksi wajah: $e", Icons.error_outline);
      }
    }
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("Layanan GPS tidak aktif. Silakan aktifkan GPS perangkat Anda.", Icons.location_off);
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("Izin akses lokasi ditolak.", Icons.warning_amber_rounded);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar("Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengizinkan.", Icons.error_outline);
      return false;
    }

    return true;
  }

  Future<void> getGeoLocationPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;

    setState(() => isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      dLat = position.latitude;
      dLong = position.longitude;
      await getAddressFromLongLat(position);
    } catch (e) {
      debugPrint("Error GPS: $e");
      if (mounted) {
        setState(() {
          strAlamat = "Koordinat: Lat $dLat, Long $dLong";
          isLoading = false;
        });
      }
    }
  }

  Future<void> getAddressFromLongLat(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks[0];
        setState(() {
          strAlamat = "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}"
              .replaceAll(RegExp(r'^[,s]+|[,s]+$'), '')
              .replaceAll(RegExp(r',s*,+'), ',');
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        strAlamat = "Lat: ${position.latitude.toStringAsFixed(5)}, Long: ${position.longitude.toStringAsFixed(5)}";
        isLoading = false;
      });
    }
  }

  Future<void> submitAbsen(String alamat, String nama, String status) async {
    _showLoaderDialog();

    try {
      await _dataCollection.add({
        'name': nama.trim(),
        'address': alamat.isEmpty ? 'Lokasi tidak terekam' : alamat,
        'description': status,
        'datetime': strDateTime,
        'latitude': dLat,
        'longitude': dLong,
        'type': 'attendance',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _showSnackBar("Gagal menyimpan presensi: $e", Icons.error_outline);
    }
  }

  void _showLoaderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.image == null) {
      return _buildCameraScreen();
    } else {
      return _buildFormScreen();
    }
  }

  Widget _buildCameraScreen() {
    if (!isCameraReady) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Record"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 500,
              child: CameraPreview(controller!),
            ),
            const SizedBox(height: 32),
            DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(24),
              dashPattern: const [8, 4],
              color: Colors.blueAccent,
              strokeWidth: 2,
              child: SizedBox(
                width: 260,
                height: 340,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      'assets/raw/face_id_ring.json',
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('Animation not found'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Take Selfie"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A008F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Attendance"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              if (widget.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.image!.path,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(child: Text('Image not available')),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _statusController,
                decoration: const InputDecoration(
                  labelText: 'Status (Hadir/Sakit/Izin)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lokasi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(strAlamat.isEmpty ? 'Belum mengambil lokasi' : strAlamat),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isLoading ? null : getGeoLocationPosition,
                icon: isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.location_on),
                label: const Text("Ambil Lokasi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isEmpty) {
                    _showSnackBar('Nama tidak boleh kosong', Icons.warning);
                    return;
                  }
                  if (_statusController.text.trim().isEmpty) {
                    _showSnackBar('Status tidak boleh kosong', Icons.warning);
                    return;
                  }
                  submitAbsen(strAlamat, _nameController.text, _statusController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A008F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Submit Attendance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
