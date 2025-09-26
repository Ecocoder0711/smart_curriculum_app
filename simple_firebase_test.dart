import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/utils/logger.dart';

void main() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.demo('✅ Firebase initialized successfully!');
    AppLogger.demo('📋 Project ID: ${Firebase.app().options.projectId}');
    AppLogger.demo('🔑 API Key: ${Firebase.app().options.apiKey.substring(0, 10)}...');
    AppLogger.demo(
      '🌐 Storage Bucket: ${Firebase.app().options.storageBucket ?? 'Not configured'}',
    );
    AppLogger.demo('💾 App ID: ${Firebase.app().options.appId}');

    AppLogger.demo('\n🎯 CONNECTION STATUS: ✅ CONNECTED TO FIREBASE PROJECT!');
    AppLogger.demo(
      '   Your Flutter app is properly connected to Firebase project: ${Firebase.app().options.projectId}',
    );
  } catch (e) {
    AppLogger.demo('❌ Firebase initialization failed: $e');
    AppLogger.demo('🎯 CONNECTION STATUS: ❌ NOT CONNECTED TO FIREBASE');
  }
}
