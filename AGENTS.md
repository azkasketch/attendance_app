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
- `hive`: ^2.2.3 - Local NoSQL database
- `hive_flutter`: ^1.1.0 - Hive Flutter integration
- `provider`: ^6.1.1 - State management
- `path_provider`: ^2.1.2 - File system access
- `uuid`: ^4.3.3 - Unique ID generation
- `intl`: ^0.20.1 - Date/time formatting

## Database Configuration

- **Database**: Hive (local NoSQL)
- **Box names**: attendance, permission
- **Storage**: Local device storage
- **Offline-first**: No server required

## Important Notes

- Assets are optional - app has fallbacks for missing assets
- All screens are now complete StatefulWidgets
- Face detection requires front camera
- GPS requires internet for geocoding
- Hive adapters must be generated with build_runner
