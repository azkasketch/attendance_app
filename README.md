# Smart Attendance App

A Flutter-based smart attendance application for students with face detection, geolocation, and Firebase integration.

## Features

- **Face Detection Attendance**: Capture selfie with AI-powered face detection using Google ML Kit
- **Geolocation Tracking**: Automatically capture and store GPS coordinates
- **Address Resolution**: Convert coordinates to readable addresses using geocoding
- **Permission/Leave Management**: Submit leave requests with date range selection
- **Attendance History**: View, edit, and delete attendance records
- **Real-time Database**: Cloud Firestore for real-time data synchronization
- **Material Design 3**: Modern UI with Material Design 3 components

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── config/
│   └── firebase_config.dart          # Firebase configuration
├── ui/
│   ├── home_screen.dart              # Main menu screen
│   ├── attend/
│   │   └── attend_screen.dart         # Attendance recording with camera
│   ├── absent/
│   │   └── absent_screen.dart        # Permission/leave form
│   └── attendance_history/
│       └── attendance_history_screen.dart  # History viewer
└── utils/
    └── face_detection/
        ├── google_ml_kit.dart        # ML Kit wrapper
        └── vision.dart               # Face detector configuration
```

## Tech Stack

- **Framework**: Flutter 3.13.3+
- **Database**: Cloud Firestore (Firebase)
- **Face Detection**: Google ML Kit Face Detection
- **Camera**: Camera package for hardware access
- **Location**: Geolocator & Geocoding
- **UI Components**: 
  - Material Design 3
  - Lottie animations
  - Dotted border for camera frame

## Setup Instructions

### Prerequisites

- Flutter SDK 3.13.3 or higher
- Android Studio / Xcode
- Firebase project with Firestore enabled
- Valid Firebase credentials

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd attendance_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a Firebase project at https://console.firebase.google.com/
   - Enable Cloud Firestore
   - Add Android app to Firebase project
   - Download `google-services.json` and place it in `android/app/`
   - Update Firebase credentials in `lib/config/firebase_config.dart` or use environment variables

4. Add required assets:
   - Place icons in `assets/images/`:
     - `ic_absen.png` - Attendance icon
     - `ic_leave.png` - Leave icon
     - `ic_history.png` - History icon
   - Place Lottie animation in `assets/raw/`:
     - `face_id_ring.json` - Face scan animation

5. Run the app:
```bash
flutter run
```

## Environment Variables (Optional)

For production deployment, set these environment variables:

```bash
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id
```

Then run with:
```bash
flutter run --dart-define=FIREBASE_API_KEY=your_api_key ...
```

## Usage

### Recording Attendance

1. Tap "Attendance Record" from the home screen
2. Position your face within the scanning frame
3. Tap "Take Selfie" to capture your photo
4. The app will verify face detection
5. Fill in your name and status
6. Tap "Ambil Lokasi" to capture GPS location
7. Submit the attendance record

### Submitting Permission/Leave

1. Tap "Permission / Leave" from the home screen
2. Fill in your name and description
3. Select date range using the date pickers
4. Submit the permission request

### Viewing History

1. Tap "Attendance History" from the home screen
2. View all attendance and permission records
3. Tap the edit icon to modify records
4. Tap the delete icon to remove records

## Firebase Firestore Structure

Collection: `attendance`

Document Fields:
- `name` (string): Student name
- `address` (string): Location address
- `description` (string): Status or description
- `datetime` (string): Formatted date/time
- `latitude` (double): GPS latitude
- `longitude` (double): GPS longitude
- `type` (string): Record type ('attendance' or 'permission')
- `created_at` (timestamp): Server timestamp

## Permissions Required

- Camera: For taking attendance photos
- Location: For GPS tracking
- Internet: For Firebase connectivity

## Troubleshooting

### Camera not working
- Ensure camera permission is granted
- Check if device has a front camera
- Verify camera plugin configuration

### Location not updating
- Ensure GPS is enabled
- Grant location permission
- Check internet connectivity for geocoding

### Firebase connection failed
- Verify Firebase credentials
- Check `google-services.json` is in correct location
- Ensure Firestore is enabled in Firebase console
- Check internet connection

### Assets not loading
- Verify asset paths in `pubspec.yaml`
- Ensure asset files exist in correct directories
- Run `flutter clean` and `flutter pub get`

## Development

### Adding new features
- Follow the existing folder structure
- Use Material Design 3 components
- Implement proper error handling
- Add loading states for async operations

### Code style
- Follow Dart style guidelines
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small

## License

This project is for educational purposes.

## Credits

- IDN Boarding School Solo
- Flutter Team
- Firebase
- Google ML Kit
