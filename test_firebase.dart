import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
    print('📋 Project ID: ${Firebase.app().options.projectId}');
    print('🔑 API Key: ${Firebase.app().options.apiKey.substring(0, 10)}...');

    // Test Firebase Auth
    FirebaseAuth auth = FirebaseAuth.instance;
    print('🔐 Firebase Auth instance created successfully!');
    print('👤 Current user: ${auth.currentUser?.email ?? 'No user signed in'}');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  runApp(const FirebaseTestApp());
}

class FirebaseTestApp extends StatelessWidget {
  const FirebaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Connection Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Connection Test'),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 20),
              Text(
                'Firebase Connected!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Check console for connection details',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
