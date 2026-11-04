import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionHelper {
  static FaceDetector? _detector;

  static FaceDetector get detector {
    _detector ??= FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: false,
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.15,
      ),
    );
    return _detector!;
  }

  static Future<List<Face>> detectFaces(InputImage image) async {
    try {
      return await detector.processImage(image);
    } catch (e) {
      return [];
    }
  }

  static void dispose() {
    _detector?.close();
    _detector = null;
  }
}
