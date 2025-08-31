import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';

class BasicQRScannerScreen extends StatefulWidget {
  const BasicQRScannerScreen({super.key});

  @override
  State<BasicQRScannerScreen> createState() => _BasicQRScannerScreenState();
}

class _BasicQRScannerScreenState extends State<BasicQRScannerScreen> {
  final TextEditingController _qrController = TextEditingController();
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual QR Code Entry'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 30),
            Text(
              'Manual QR Code Entry',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'If camera scanning is not available, you can manually enter the QR code data here:',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _qrController,
              decoration: const InputDecoration(
                labelText: 'QR Code Data',
                hintText: 'Enter QR code content or session ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code_scanner),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _markAttendance,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Processing...'),
                        ],
                      )
                    : const Text('Mark Attendance'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Note: Ask your teacher for the QR code data if camera scanning is not working.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAttendance() async {
    final qrData = _qrController.text.trim();

    if (qrData.isEmpty) {
      _showDialog(
        'Invalid Input',
        'Please enter the QR code data or session ID.',
        isError: true,
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
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
          'This QR code data is not valid for attendance.',
          isError: true,
        );
        return;
      }

      // Mark attendance
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
        _qrController.clear();
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Try Again'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (!isError) {
                Navigator.of(context).pop(); // Go back to dashboard
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
    _qrController.dispose();
    super.dispose();
  }
}
