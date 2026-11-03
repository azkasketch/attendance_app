# Project-Specific Information

## Build Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Clean build
flutter clean
```

## Testing Commands

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## Linting and Formatting

```bash
# Analyze code
flutter analyze

# Format code
dart format .
```

## Key Dependencies

- `camera`: ^0.11.0+2 - Camera access
- `geolocator`: ^13.0.2 - GPS location
- `geocoding`: ^3.0.0 - Address from coordinates
- `google_mlkit_face_detection`: ^0.12.0 - Face detection AI
- `cloud_firestore`: ^5.6.3 - Firebase database
- `firebase_core`: ^3.11.0 - Firebase core
- `lottie`: ^3.3.1 - Animations
- `dotted_border`: ^2.1.0 - UI component

## Firebase Configuration

- Project ID: idn-attendance-app-6ceac
- Collection: attendance
- Fields: name, address, description, datetime, latitude, longitude, type, created_at

## Important Notes

- Firebase credentials are now in `lib/config/firebase_config.dart`
- Use environment variables for production deployment
- Assets are optional - app has fallbacks for missing assets
- All screens are now complete StatefulWidgets
- Face detection requires front camera
- GPS requires internet for geocoding
