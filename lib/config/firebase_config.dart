import 'package:firebase_core/firebase_core.dart';

/// Firebase Configuration
/// 
/// SECURITY NOTE: In production, these values should be loaded from environment
/// variables or secure storage. Never commit sensitive credentials to version control.
/// 
/// For development, you can use the values below or set up environment variables.
class FirebaseConfig {
  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyDauGqKgEV6Q2yJMjFbaCbUNDk5FjGb0hc',
  );
  
  static const String appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:113228359740:android:c9363c7bec701353b93b39',
  );
  
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '113228359740',
  );
  
  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'idn-attendance-app-6ceac',
  );

  static FirebaseOptions get options => FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
  );
}
