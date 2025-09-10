import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/location_service.dart';

class ReliableQRScanner extends StatefulWidget {
  const ReliableQRScanner({super.key});

  @override
  State<ReliableQRScanner> createState() => _ReliableQRScannerState();
}

class _ReliableQRScannerState extends State<ReliableQRScanner>
    with WidgetsBindingObserver {
  MobileScannerController? cameraController;
  String scannedData = '';
  bool isScanning = true;
  bool isProcessing = false;
  bool isInitialized = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && !isInitialized) {
      _initializeScanner();
    }
  }

  Future<void> _initializeScanner() async {
    try {
      debugPrint('DEBUG: ReliableQRScanner - Starting initialization');

      setState(() {
        errorMessage = null;
        isInitialized = false;
      });

      // Create camera controller with basic settings
      cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      setState(() {
        isInitialized = true;
        errorMessage = null;
      });

      debugPrint('DEBUG: ReliableQRScanner - Initialization complete');
    } catch (e) {
      debugPrint('DEBUG: ReliableQRScanner - Initialization failed: $e');
      setState(() {
        errorMessage = 'Failed to initialize camera: $e';
        isInitialized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: isInitialized && cameraController != null
            ? [
                IconButton(
                  icon: Icon(isScanning ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      isScanning = !isScanning;
                      if (isScanning) {
                        cameraController!.start();
                      } else {
                        cameraController!.stop();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.flash_on),
                  onPressed: () => cameraController!.toggleTorch(),
                ),
              ]
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(errorMessage ?? 'Initializing camera...'),
            if (errorMessage != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeScanner,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    if (cameraController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Setting up camera...'),
          ],
        ),
      );
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
                errorBuilder: (context, error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Camera Error: $error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializeScanner,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                },
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
                      : 'Make sure the QR code is clearly visible',
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
      cameraController?.stop();

      final authProvider = context.read<AuthProvider>();
      final attendanceService = AttendanceService();
      final locationService = LocationService();

      // Show location verification progress
      _showLoadingDialog('Verifying your location...');

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
      final teacherLat = qrContent['latitude'] as double?;
      final teacherLon = qrContent['longitude'] as double?;
      final radiusMeters = qrContent['radius'] as double? ?? 50.0;

      if (classSessionId == null || classSessionId.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        _showDialog(
          'Invalid QR Code',
          'This QR code is not valid for attendance.',
          isError: true,
        );
        return;
      }

      // Verify location if coordinates are provided
      if (teacherLat != null && teacherLon != null) {
        final locationResult = await locationService.verifyAttendanceLocation(
          teacherLat: teacherLat,
          teacherLon: teacherLon,
          radiusMeters: radiusMeters,
        );

        Navigator.of(context).pop(); // Close loading dialog

        if (!locationResult.success) {
          _showDialog('Location Error', locationResult.message, isError: true);
          return;
        }

        if (!locationResult.isWithinRange) {
          _showProxyDetectedDialog(locationResult);
          return;
        }

        // Show location verification success
        _showLocationVerifiedDialog(locationResult, () async {
          await _proceedWithAttendance(
            attendanceService,
            authProvider,
            classSessionId,
            location,
          );
        });
      } else {
        // No location verification needed (old QR format)
        Navigator.of(context).pop(); // Close loading dialog
        await _proceedWithAttendance(
          attendanceService,
          authProvider,
          classSessionId,
          location,
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      debugPrint('Error marking attendance: $e');
      _showDialog('Error', 'Failed to mark attendance: $e', isError: true);
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _proceedWithAttendance(
    AttendanceService attendanceService,
    AuthProvider authProvider,
    String classSessionId,
    String location,
  ) async {
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
    } else {
      _showDialog('Failed', result.message, isError: true);
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showLocationVerifiedDialog(
    AttendanceLocationResult locationResult,
    VoidCallback onProceed,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Location Verified'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are within the attendance area.',
              style: TextStyle(color: Colors.green[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Distance from classroom: ${locationResult.distance?.toStringAsFixed(1) ?? 'N/A'}m',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onProceed();
            },
            child: const Text('Mark Attendance'),
          ),
        ],
      ),
    );
  }

  void _showProxyDetectedDialog(AttendanceLocationResult locationResult) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Proxy Attendance Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are not within the required attendance area.',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your distance: ${locationResult.distance?.toStringAsFixed(1) ?? 'N/A'}m',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Required range: ${locationResult.radiusMeters?.toStringAsFixed(0) ?? '50'}m',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please move closer to the classroom and try again.',
              style: Theme.of(context).textTheme.bodyMedium,
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
              cameraController?.start();
              setState(() {
                scannedData = '';
                isProcessing = false;
              });
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
              if (!isError) {
                Navigator.of(context).pop(); // Go back to dashboard
              } else {
                cameraController?.start();
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
}
