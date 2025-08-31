import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/location_service.dart';
import '../../services/permission_service.dart';

class SafeQRScannerScreen extends StatefulWidget {
  const SafeQRScannerScreen({super.key});

  @override
  State<SafeQRScannerScreen> createState() => _SafeQRScannerScreenState();
}

class _SafeQRScannerScreenState extends State<SafeQRScannerScreen> {
  MobileScannerController? cameraController;
  String scannedData = '';
  bool isScanning = true;
  bool isProcessing = false;
  bool isInitialized = false;
  bool hasPermissions = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Don't call _initializeScanner here - moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      _initializeScanner();
    }
  }

  Future<void> _initializeScanner() async {
    try {
      // Show loading dialog
      if (mounted) {
        PermissionService.showPermissionLoadingDialog(context);
      }

      // Check permissions
      final permissionService = PermissionService();
      final permissions = await permissionService.checkAttendancePermissions();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      final cameraPermission = permissions['camera']!;
      final locationPermission = permissions['location']!;

      if (!cameraPermission.isGranted) {
        setState(() {
          hasPermissions = false;
          errorMessage = cameraPermission.message;
        });

        if (mounted) {
          _showPermissionDialog(
            title: 'Camera Permission Required',
            message: cameraPermission.message,
            showSettings: cameraPermission.showSettings,
            onGrant: _initializeScanner,
          );
        }
        return;
      }

      // Camera permission granted, initialize scanner
      cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        returnImage: false,
      );

      setState(() {
        hasPermissions = true;
        isInitialized = true;
        errorMessage = null;
      });

      // Check location permission (non-blocking)
      if (!locationPermission.isGranted && mounted) {
        _showLocationPermissionInfo(locationPermission);
      }
    } catch (e) {
      debugPrint('Error initializing scanner: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        setState(() {
          hasPermissions = false;
          errorMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  void _showPermissionDialog({
    required String title,
    required String message,
    required VoidCallback onGrant,
    bool showSettings = false,
  }) {
    PermissionService.showPermissionDialog(
      context: context,
      title: title,
      message: message,
      onGrant: onGrant,
      onDeny: () {
        Navigator.of(context).pop(); // Go back to dashboard
      },
      showSettings: showSettings,
    );
  }

  void _showLocationPermissionInfo(PermissionResult locationResult) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Location access helps prevent proxy attendance',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Enable',
          textColor: Colors.white,
          onPressed: () async {
            final result = await PermissionService().checkLocationPermission();
            if (result.isGranted && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location permission granted!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (hasPermissions && isInitialized) ...[
            IconButton(
              icon: Icon(isScanning ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  isScanning = !isScanning;
                  if (isScanning) {
                    cameraController?.start();
                  } else {
                    cameraController?.stop();
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => cameraController?.toggleTorch(),
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!hasPermissions) {
      return _buildPermissionDeniedView();
    }

    if (!isInitialized) {
      return _buildLoadingView();
    }

    return Column(
      children: [
        // Scanner Area
        Expanded(
          flex: 4,
          child: Stack(
            children: [
              MobileScanner(
                controller: cameraController!,
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
        Expanded(flex: 2, child: _buildInstructions()),
      ],
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Camera Permission Required',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ??
                  'Camera access is needed to scan QR codes for attendance',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _initializeScanner,
              icon: const Icon(Icons.refresh),
              label: const Text('Grant Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing camera...'),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isProcessing ? Icons.location_searching : Icons.qr_code_scanner,
            size: 50,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),

          Text(
            isProcessing
                ? 'Verifying location and marking attendance...'
                : 'Position QR code within the frame',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
      cameraController?.stop();

      final authProvider = context.read<AuthProvider>();
      final attendanceService = AttendanceService();
      final locationService = LocationService();

      // Parse QR data
      Map<String, dynamic> qrContent;
      try {
        qrContent = jsonDecode(qrData);
      } catch (e) {
        // Fallback for old format
        final parts = qrData.split(':');
        if (parts.length != 2) {
          _showErrorDialog(
            'Invalid QR Code',
            'This QR code is not valid for attendance.',
          );
          return;
        }

        qrContent = {
          'classSessionId': parts[0],
          'location': parts[1],
          'teacherLat': 37.7749,
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

      // Try location verification (with fallback)
      try {
        final locationResult = await locationService.verifyAttendanceLocation(
          teacherLat: teacherLat,
          teacherLon: teacherLon,
          radiusMeters: radiusMeters,
        );

        if (locationResult.success && !locationResult.isWithinRange) {
          _showProxyDetectedDialog(
            locationResult.distance!,
            radiusMeters,
            locationResult.message,
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
          _showSuccessDialog(
            'Attendance Marked!',
            locationResult.success
                ? 'Your attendance has been recorded successfully.\nDistance from class: ${locationResult.distance!.toStringAsFixed(1)}m'
                : 'Your attendance has been recorded successfully.',
          );
        } else {
          _showErrorDialog('Attendance Failed', result.message);
        }
      } catch (e) {
        // Location verification failed, but allow attendance for demo
        debugPrint('Location verification failed: $e');
        final result = await attendanceService.markAttendance(
          studentId: authProvider.user!.id,
          classSessionId: classSessionId,
          location: location,
        );

        if (result.success) {
          _showSuccessDialog(
            'Attendance Marked!',
            'Your attendance has been recorded successfully.\n(Location verification was skipped)',
          );
        } else {
          _showErrorDialog('Attendance Failed', result.message);
        }
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
            const Text('Location Verification Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text(
              'You are ${distance.toStringAsFixed(1)}m away from the classroom. Please move closer and try again.',
              style: TextStyle(color: Colors.orange[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                scannedData = '';
                isProcessing = false;
              });
              cameraController?.start();
            },
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
              Navigator.of(context).pop();
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
              cameraController?.start();
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
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}

// Copy the existing QrScannerOverlayShape class here
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

    // Corner borders
    final cornerPaths = [
      // Top left
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

      // Top right
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

      // Bottom left
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

      // Bottom right
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
    ];

    for (final path in cornerPaths) {
      canvas.drawPath(path, borderPaint);
    }
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
