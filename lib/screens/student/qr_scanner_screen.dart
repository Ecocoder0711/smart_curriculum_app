import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/location_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
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
                // Overlay
                Container(
                  decoration: ShapeDecoration(
                    shape: QrScannerOverlayShape(
                      borderColor: Theme.of(context).colorScheme.primary,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 300,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Instructions and Status
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isProcessing
                        ? Icons.location_searching
                        : Icons.qr_code_scanner,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    isProcessing
                        ? 'Verifying location and marking attendance...'
                        : 'Position QR code within the frame',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isProcessing
                        ? 'Please wait while we verify your location'
                        : 'Make sure the QR code is clear and well-lit',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  if (scannedData.isNotEmpty && !isProcessing) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'QR Code Scanned Successfully!',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (isProcessing) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Checking your location for proxy detection...',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

        // Mark attendance with location verification
        _markAttendanceWithLocation(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _markAttendanceWithLocation(String qrData) async {
    try {
      // Pause scanning
      cameraController.stop();

      final authProvider = context.read<AuthProvider>();
      final attendanceService = AttendanceService();
      final locationService = LocationService();

      // Parse QR data - updated format: JSON with classSessionId, teacherLat, teacherLon, radiusMeters
      Map<String, dynamic> qrContent;
      try {
        qrContent = jsonDecode(qrData);
      } catch (e) {
        // Fallback for old format: "classSessionId:location"
        final parts = qrData.split(':');
        if (parts.length != 2) {
          _showErrorDialog(
            'Invalid QR Code',
            'This QR code is not valid for attendance.',
          );
          return;
        }

        // Use default coordinates for legacy QR codes (classroom coordinates)
        qrContent = {
          'classSessionId': parts[0],
          'location': parts[1],
          'teacherLat': 37.7749, // Example: San Francisco coordinates
          'teacherLon': -122.4194,
          'radiusMeters': 50.0,
        };
      }

      final classSessionId = qrContent['classSessionId'] as String?;
      final location = qrContent['location'] as String? ?? 'Classroom';
      final teacherLat =
          (qrContent['teacherLat'] as num?)?.toDouble() ?? 37.7749;
      final teacherLon =
          (qrContent['teacherLon'] as num?)?.toDouble() ?? -122.4194;
      final radiusMeters =
          (qrContent['radiusMeters'] as num?)?.toDouble() ?? 50.0;

      if (classSessionId == null) {
        _showErrorDialog(
          'Invalid QR Code',
          'This QR code is missing required attendance information.',
        );
        return;
      }

      // Verify student location
      final locationResult = await locationService.verifyAttendanceLocation(
        teacherLat: teacherLat,
        teacherLon: teacherLon,
        radiusMeters: radiusMeters,
      );

      if (!locationResult.success) {
        // For demo purposes, if location fails, allow attendance anyway
        debugPrint(
          'Location verification failed, proceeding with attendance for demo',
        );
        final result = await attendanceService.markAttendance(
          studentId: authProvider.user!.id,
          classSessionId: classSessionId,
          location: location,
        );

        if (result.success) {
          _showSuccessDialog(
            'Attendance Marked!',
            'Your attendance has been recorded successfully.\n(Location verification skipped for demo)',
          );
        } else {
          _showErrorDialog('Attendance Failed', result.message);
        }
        return;
      }

      if (!locationResult.isWithinRange) {
        _showProxyDetectedDialog(
          locationResult.distance!,
          radiusMeters,
          locationResult.message,
        );
        return;
      }

      // Mark attendance if location is verified
      final result = await attendanceService.markAttendance(
        studentId: authProvider.user!.id,
        classSessionId: classSessionId,
        location: location,
      );

      if (result.success) {
        _showSuccessDialog(
          'Attendance Marked!',
          'Your attendance has been recorded successfully.\nDistance from class: ${locationResult.distance!.toStringAsFixed(1)}m',
        );
      } else {
        _showErrorDialog('Attendance Failed', result.message);
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to mark attendance: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _showProxyDetectedDialog(
    double distance,
    double allowedRadius,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('Proxy Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange[700],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Location Details:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('• Your distance: ${distance.toStringAsFixed(1)}m'),
                  Text(
                    '• Required range: ${allowedRadius.toStringAsFixed(1)}m',
                  ),
                  Text(
                    '• You need to be ${(distance - allowedRadius).toStringAsFixed(1)}m closer',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please move closer to the classroom and try again.',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset scanning state
              setState(() {
                scannedData = '';
                isProcessing = false;
              });
              cameraController.start();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600]),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Resume scanning
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
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: const Text('Cancel'),
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

// Custom overlay shape for QR scanner
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
    double? cutOutHeight,
    double? cutOutWidth,
    this.cutOutBottomOffset = 0,
  }) : cutOutWidth = cutOutWidth ?? cutOutSize ?? 250,
       cutOutHeight = cutOutHeight ?? cutOutSize ?? 250;

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutWidth;
  final double cutOutHeight;
  final double cutOutBottomOffset;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
          rect.left,
          rect.top,
          rect.left + borderRadius,
          rect.top,
        )
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final cutOutWidthAdjusted = cutOutWidth < width
        ? cutOutWidth
        : width - borderOffset;
    final cutOutHeightAdjusted = cutOutHeight < height
        ? cutOutHeight
        : height - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + (width - cutOutWidthAdjusted) / 2 + borderOffset,
      rect.top +
          (height - cutOutHeightAdjusted) / 2 +
          borderOffset +
          cutOutBottomOffset,
      cutOutWidthAdjusted - borderOffset * 2,
      cutOutHeightAdjusted - borderOffset * 2,
    );

    // Background
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
          )
          ..close(),
      ),
      backgroundPaint,
    );

    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left - borderOffset, cutOutRect.top + borderLength)
        ..lineTo(cutOutRect.left - borderOffset, cutOutRect.top + borderRadius)
        ..quadraticBezierTo(
          cutOutRect.left - borderOffset,
          cutOutRect.top - borderOffset,
          cutOutRect.left + borderRadius,
          cutOutRect.top - borderOffset,
        )
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.top - borderOffset),
      borderPaint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - borderLength, cutOutRect.top - borderOffset)
        ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top - borderOffset)
        ..quadraticBezierTo(
          cutOutRect.right + borderOffset,
          cutOutRect.top - borderOffset,
          cutOutRect.right + borderOffset,
          cutOutRect.top + borderRadius,
        )
        ..lineTo(
          cutOutRect.right + borderOffset,
          cutOutRect.top + borderLength,
        ),
      borderPaint,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(
          cutOutRect.left - borderOffset,
          cutOutRect.bottom - borderLength,
        )
        ..lineTo(
          cutOutRect.left - borderOffset,
          cutOutRect.bottom - borderRadius,
        )
        ..quadraticBezierTo(
          cutOutRect.left - borderOffset,
          cutOutRect.bottom + borderOffset,
          cutOutRect.left + borderRadius,
          cutOutRect.bottom + borderOffset,
        )
        ..lineTo(
          cutOutRect.left + borderLength,
          cutOutRect.bottom + borderOffset,
        ),
      borderPaint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(
          cutOutRect.right - borderLength,
          cutOutRect.bottom + borderOffset,
        )
        ..lineTo(
          cutOutRect.right - borderRadius,
          cutOutRect.bottom + borderOffset,
        )
        ..quadraticBezierTo(
          cutOutRect.right + borderOffset,
          cutOutRect.bottom + borderOffset,
          cutOutRect.right + borderOffset,
          cutOutRect.bottom - borderRadius,
        )
        ..lineTo(
          cutOutRect.right + borderOffset,
          cutOutRect.bottom - borderLength,
        ),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
