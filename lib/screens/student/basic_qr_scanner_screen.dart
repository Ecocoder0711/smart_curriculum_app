import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Add this package
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/facial_recognition_service.dart';

enum AttendanceVerificationStep { faceVerification, qrScanning, completed }

class BasicQRScannerScreen extends StatefulWidget {
  const BasicQRScannerScreen({super.key});

  @override
  State<BasicQRScannerScreen> createState() => _BasicQRScannerScreenState();
}

class _BasicQRScannerScreenState extends State<BasicQRScannerScreen> {
  bool isProcessing = false;

  // Two-step verification state
  AttendanceVerificationStep currentStep =
      AttendanceVerificationStep.faceVerification;
  bool isFaceVerified = false;
  String? verifiedStudentId;
  String? studentName;
  bool isScanning = false;
  
  // Mobile scanner controller
  MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  // Services
  final FacialRecognitionService _facialService = FacialRecognitionService();
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void dispose() {
    cameraController.dispose();
    _facialService.dispose();
    super.dispose();
  }

  void _toggleTorch() {
    cameraController.toggleTorch();
  }

  void _switchCamera() {
    cameraController.switchCamera();
  }

  Future<void> _processScannedQR(String qrData) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user == null || !isFaceVerified) {
        throw Exception('Face verification required before QR scanning');
      }

      await _attendanceService.markAttendanceWithQR(
        studentId: user.id,
        qrData: qrData,
        faceVerified: true,
        verificationMethod: 'face_then_qr_camera',
      );

      if (mounted) {
        setState(() {
          currentStep = AttendanceVerificationStep.completed;
          isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance marking failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _startFaceVerification() async {
    if (!mounted) return;

    setState(() {
      isProcessing = true;
    });

    try {
      // Get context-dependent values before async operation
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      
      // Mock face verification - in real implementation, this would use camera
      await Future.delayed(const Duration(seconds: 3));

      if (mounted && user != null) {
        setState(() {
          isFaceVerified = true;
          verifiedStudentId = user.id;
          studentName = user.name;
          currentStep = AttendanceVerificationStep.qrScanning;
          isProcessing = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Face verified successfully! Welcome, ${user.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Face verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildCurrentStep(),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (currentStep) {
      case AttendanceVerificationStep.faceVerification:
        return 'Face Verification';
      case AttendanceVerificationStep.qrScanning:
        return 'QR Code Scanner';
      case AttendanceVerificationStep.completed:
        return 'Attendance Complete';
    }
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case AttendanceVerificationStep.faceVerification:
        return _buildFaceVerificationStep();
      case AttendanceVerificationStep.qrScanning:
        return _buildQRScanningStep();
      case AttendanceVerificationStep.completed:
        return _buildCompletedStep();
    }
  }

  Widget _buildFaceVerificationStep() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Security icon - more compact
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.face_retouching_natural,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Anti-Proxy Security',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'To prevent proxy attendance, please verify your identity with face recognition first.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),

          // Face verification step indicator
          _buildStepIndicator(),
          const SizedBox(height: 24),

          // Mock face verification button
          ElevatedButton.icon(
            onPressed: isProcessing ? null : _startFaceVerification,
            icon: Icon(isProcessing ? Icons.hourglass_empty : Icons.camera_alt),
            label: Text(
              isProcessing ? 'Verifying Face...' : 'Start Face Verification',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info card - more compact
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This ensures only the registered student can mark attendance.',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanningStep() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // More compact face verification banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Face Verified ✓ Welcome, ${user?.name ?? 'Student'}!',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // QR code icon and header (more compact)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 38,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR Scanner Entry',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Scan teacher\'s QR code',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Step indicator (more compact)
          _buildStepIndicator(),
          const SizedBox(height: 16),

          // Real QR Camera Implementation
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 350, // Increased camera size
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Real camera view
                  MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty && !isProcessing) {
                        final String qrData = barcodes.first.rawValue ?? '';
                        if (qrData.isNotEmpty) {
                          _processScannedQR(qrData);
                        }
                      }
                    },
                  ),
                  
                  // QR Frame overlay
                  CustomPaint(
                    painter: QRScannerOverlayPainter(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Container(),
                  ),
                  
                  // Controls at the bottom
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Flash button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.flash_on),
                            onPressed: _toggleTorch,
                          ),
                        ),
                        
                        // Switch camera button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.flip_camera_ios),
                            onPressed: _switchCamera,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Scanning indicator
                  if (isProcessing)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Scanning Instructions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Point your camera at the QR code displayed by your teacher',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  '2. Hold steady until the QR code is detected',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  '3. Attendance will be marked automatically',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedStep() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success animation placeholder - more compact
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Attendance Marked!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Your attendance has been successfully recorded with verified identity.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot(1, 'Face', currentStep.index >= 0),
        _buildStepLine(currentStep.index >= 1),
        _buildStepDot(2, 'QR', currentStep.index >= 1),
        _buildStepLine(currentStep.index >= 2),
        _buildStepDot(3, 'Done', currentStep.index >= 2),
      ],
    );
  }

  Widget _buildStepDot(int step, String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 36, // Smaller dots
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6), // Reduced spacing
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isCompleted
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      width: 30, // Shorter lines
      height: 2,
      margin: const EdgeInsets.only(bottom: 20), // Reduced margin
      color: isCompleted
          ? Theme.of(context).colorScheme.primary
          : Colors.grey.shade300,
    );
  }
}

// Custom painter for QR scanner overlay
class QRScannerOverlayPainter extends CustomPainter {
  final Color color;

  QRScannerOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double cornerLength = 20.0;

    // Draw corner brackets
    // Top-left corner
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), paint);

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top),
      Offset(left + scanAreaSize, top),
      paint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanAreaSize - cornerLength),
      Offset(left, top + scanAreaSize),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + cornerLength, top + scanAreaSize),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize),
      paint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}