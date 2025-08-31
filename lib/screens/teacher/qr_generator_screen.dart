import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final _classSessionController = TextEditingController();
  final _locationController = TextEditingController();
  String _qrData = '';

  @override
  void initState() {
    super.initState();
    // Set default values
    _classSessionController.text = 'CS101_2025_08_31';
    _locationController.text = 'Room 101';
    _generateQR();
  }

  void _generateQR() {
    final qrContent = {
      'classSessionId': _classSessionController.text,
      'location': _locationController.text,
      'teacherLat': 37.7749, // San Francisco coordinates for demo
      'teacherLon': -122.4194,
      'radiusMeters': 50.0,
    };

    setState(() {
      _qrData = jsonEncode(qrContent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input fields
            TextField(
              controller: _classSessionController,
              decoration: const InputDecoration(
                labelText: 'Class Session ID',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _generateQR(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _generateQR(),
            ),
            const SizedBox(height: 32),

            // QR Code display
            if (_qrData.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Scan this QR code for attendance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Session: ${_classSessionController.text}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Location: ${_locationController.text}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'How it works:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Students scan this QR code with their app'),
                  const Text('2. App verifies student location (50m radius)'),
                  const Text('3. Attendance is marked automatically'),
                  const Text('4. Prevents proxy attendance'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _classSessionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
