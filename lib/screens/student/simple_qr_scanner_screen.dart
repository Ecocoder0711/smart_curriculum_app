import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';

class SimpleQRScannerScreen extends StatefulWidget {
  const SimpleQRScannerScreen({super.key});

  @override
  State<SimpleQRScannerScreen> createState() => _SimpleQRScannerScreenState();
}

class _SimpleQRScannerScreenState extends State<SimpleQRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  String scannedData = '';
  bool isScanning = true;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                isScanning = !isScanning;
                if (isScanning) {
                  cameraController.start();
                } else {
                  cameraController.stop();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner Area
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onQRDetected,
                ),
                // Simple overlay
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.all(50),
                ),
              ],
            ),
          ),

          // Instructions
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isProcessing ? Icons.check_circle : Icons.qr_code_scanner,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isProcessing
                        ? 'Processing attendance...'
                        : 'Position QR code within the frame',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isProcessing
                        ? 'Please wait...'
                        : 'Make sure the QR code is clear and well-lit',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null &&
          scannedData != barcode.rawValue &&
          !isProcessing) {
        setState(() {
          scannedData = barcode.rawValue!;
          isProcessing = true;
        });

        _markAttendance(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _markAttendance(String qrData) async {
    try {
      cameraController.stop();

      final authProvider = context.read<AuthProvider>();
      final attendanceService = AttendanceService();

      // Parse QR data
      Map<String, dynamic> qrContent;
      try {
        qrContent = jsonDecode(qrData);
      } catch (e) {
        // Fallback for simple format
        final parts = qrData.split(':');
        if (parts.length >= 2) {
          qrContent = {'classSessionId': parts[0], 'location': parts[1]};
        } else {
          // If it's just a simple string, use it as session ID
          qrContent = {'classSessionId': qrData, 'location': 'Classroom'};
        }
      }

      final classSessionId = qrContent['classSessionId'] as String?;
      final location = qrContent['location'] as String? ?? 'Classroom';

      if (classSessionId == null || classSessionId.isEmpty) {
        _showDialog(
          'Invalid QR Code',
          'This QR code is not valid for attendance.',
          isError: true,
        );
        return;
      }

      // Mark attendance (without location verification for simplicity)
      final result = await attendanceService.markAttendance(
        studentId: authProvider.user!.id,
        classSessionId: classSessionId,
        location: location,
      );

      if (result.success) {
        _showDialog(
          'Success!',
          'Your attendance has been marked successfully for session: $classSessionId',
          isError: false,
        );
      } else {
        _showDialog('Failed', result.message, isError: true);
      }
    } catch (e) {
      debugPrint('Error marking attendance: $e');
      _showDialog('Error', 'Failed to mark attendance: $e', isError: true);
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _showDialog(String title, String message, {required bool isError}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: isError ? Colors.red[600] : Colors.green[600],
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          if (isError)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                cameraController.start();
                setState(() {
                  scannedData = '';
                  isProcessing = false;
                });
              },
              child: const Text('Try Again'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (!isError) {
                Navigator.of(context).pop(); // Go back to dashboard
              } else {
                cameraController.start();
                setState(() {
                  scannedData = '';
                  isProcessing = false;
                });
              }
            },
            child: Text(isError ? 'Cancel' : 'OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
