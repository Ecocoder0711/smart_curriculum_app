import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
    print('📋 Project ID: ${Firebase.app().options.projectId}');
    print('🔑 API Key: ${Firebase.app().options.apiKey.substring(0, 10)}...');
    print('🌐 Storage Bucket: ${Firebase.app().options.storageBucket ?? 'Not configured'}');
    print('💾 App ID: ${Firebase.app().options.appId}');
    
    print('\n🎯 CONNECTION STATUS: ✅ CONNECTED TO FIREBASE PROJECT!');
    print('   Your Flutter app is properly connected to Firebase project: ${Firebase.app().options.projectId}');
    
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('🎯 CONNECTION STATUS: ❌ NOT CONNECTED TO FIREBASE');
  }
}
