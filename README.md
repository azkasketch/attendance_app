# Smart Attendance App

A Flutter-based smart attendance application for students with face detection, geolocation, and local database storage using Clean Architecture.

## Features

- **Face Detection Attendance**: Capture selfie with AI-powered face detection using Google ML Kit (simplified)
- **Geolocation Tracking**: Automatically capture and store GPS coordinates
- **Address Resolution**: Convert coordinates to readable addresses using geocoding
- **Permission/Leave Management**: Submit leave requests with date range selection
- **Attendance History**: View and delete attendance records
- **Local Database**: Hive (NoSQL) for offline-first data storage
- **State Management**: Provider pattern for reactive state
- **Material Design 3**: Modern UI with Material Design 3 components

## Architecture

This project follows **Clean Architecture** with the following layers:

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # App-wide constants
│   ├── theme/
│   │   └── app_theme.dart              # App theme configuration
│   ├── utils/
│   │   ├── date_formatter.dart        # Date formatting utilities
│   │   ├── location_helper.dart       # Geocoding helper (simplified)
│   │   └── face_detection_helper.dart # Face detection helper (simplified)
│   └── database/
│       └── hive_service.dart          # Hive database service
├── data/
│   ├── models/
│   │   ├── attendance_model.dart      # Attendance data model
│   │   └── permission_model.dart      # Permission data model
│   └── repositories/
│       ├── attendance_repository.dart  # Attendance data operations
│       └── permission_repository.dart  # Permission data operations
├── domain/
│   └── usecases/
│       ├── add_attendance.dart        # Add attendance use case
│       ├── get_all_attendance.dart    # Get all attendance use case
│       ├── update_attendance.dart     # Update attendance use case
│       ├── delete_attendance.dart     # Delete attendance use case
│       ├── add_permission.dart        # Add permission use case
│       └── get_all_permissions.dart   # Get all permissions use case
└── presentation/
    ├── providers/
    │   ├── attendance_provider.dart   # Attendance state management
    │   └── permission_provider.dart   # Permission state management
    ├── screens/
    │   ├── home_screen.dart           # Main menu screen
    │   ├── attendance_screen.dart     # Attendance recording with camera
    │   ├── permission_screen.dart     # Permission/leave form
    │   └── history_screen.dart        # History viewer
    └── widgets/
        └── common/                    # Reusable widgets
```

## Tech Stack

- **Framework**: Flutter 3.13.3+
- **Language**: Dart
- **State Management**: Provider ^6.1.1
- **Local Database**: Hive ^2.2.3 (NoSQL)
- **Face Detection**: Google ML Kit Face Detection ^0.12.0 (simplified)
- **Camera**: Camera ^0.11.0+2
- **Location**: Geolocator ^13.0.2 & Geocoding ^3.0.0
- **Code Generation**: build_runner & hive_generator
- **UI Components**: 
  - Material Design 3
  - Lottie animations
  - Dotted border for camera frame

## Setup Instructions

### Prerequisites

- Flutter SDK 3.13.3 or higher
- Android Studio / VS Code
- (Optional) Android/iOS device for camera & GPS testing

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

3. Generate Hive adapters:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. Add required assets (optional):
   - Place icons in `assets/images/`
   - Place Lottie animation in `assets/raw/`

5. Run the app:
```bash
flutter run
```

## Usage

### Recording Attendance
1. Tap "Attendance Record" from the home screen
2. Position your face within the camera frame
3. Tap "Take Selfie" to capture your photo
4. The app will verify face detection (simplified mode)
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
2. View all attendance and permission records combined
3. Tap the delete icon to remove records

## Database Structure

### Attendance Model (Hive)
- `id` (string): Unique identifier
- `name` (string): Student name
- `address` (string): Location address
- `description` (string): Status
- `datetime` (string): Formatted date/time
- `latitude` (double?): GPS latitude
- `longitude` (double?): GPS longitude
- `createdAt` (DateTime): Creation timestamp

### Permission Model (Hive)
- `id` (string): Unique identifier
- `name` (string): Student name
- `description` (string): Reason
- `fromDate` (string): Start date
- `toDate` (string): End date
- `createdAt` (DateTime): Creation timestamp

## Permissions Required

- Camera: For taking attendance photos
- Location: For GPS tracking
- Internet: For geocoding (address resolution)

## Architecture Highlights

### State Management (Provider)
- Clean separation of UI and business logic
- Reactive updates with `Consumer` widgets
- Easy to test and maintain

### Local Database (Hive)
- Offline-first architecture
- Fast NoSQL queries
- No server/backend required
- Easy backup (export database file)

### Simplified Face Detection
- Fast mode for better performance
- Disabled unnecessary features (classification, landmarks)
- Simple helper class API
- Graceful error handling

### Simplified Geocoding
- Helper class for location operations
- Fallback to coordinates if geocoding fails
- Simple error handling

## Troubleshooting

### Camera not working
- Ensure camera permission is granted
- Check if device has a front camera
- Note: Camera doesn't work on web platform

### Location not updating
- Ensure GPS is enabled
- Grant location permission
- Check internet connectivity for geocoding
- Note: Geolocation may not work on web without HTTPS

### Hive initialization failed
- Run `flutter clean` and `flutter pub get`
- Re-run build_runner: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- Check if hive_flutter is properly initialized

### Face detection not working
- Note: ML Kit doesn't work on web platform
- Test on Android/iOS device
- Ensure proper lighting and face visibility

## Development

### Adding new features
- Follow Clean Architecture layers
- Create model in `data/models/`
- Create repository in `data/repositories/`
- Create use case in `domain/usecases/`
- Add to provider in `presentation/providers/`
- Update screen in `presentation/screens/`

### Code style
- Follow Dart style guidelines
- Use meaningful variable names
- Keep functions focused and small
- Separate UI logic from business logic

## License

This project is for educational purposes.

## Credits

- IDN Boarding School Solo
- Flutter Team
- Google ML Kit
- Hive Database
