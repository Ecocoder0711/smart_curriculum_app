import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';

class PermissionAwareQRScanner extends StatefulWidget {
  const PermissionAwareQRScanner({super.key});

  @override
  State<PermissionAwareQRScanner> createState() =>
      _PermissionAwareQRScannerState();
}

class _PermissionAwareQRScannerState extends State<PermissionAwareQRScanner>
    with WidgetsBindingObserver {
  MobileScannerController? cameraController;
  String scannedData = '';
  bool isScanning = true;
  bool isProcessing = false;
  bool hasPermission = false;
  bool isCheckingPermission = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When user returns from settings, check permissions again
    if (state == AppLifecycleState.resumed && !hasPermission) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      debugPrint('DEBUG: Starting permission check');
      setState(() {
        isCheckingPermission = true;
        errorMessage = null;
      });

      final status = await Permission.camera.status;
      debugPrint('DEBUG: Camera permission status: $status');

      if (status.isGranted) {
        debugPrint('DEBUG: Permission already granted, initializing camera');
        await _initializeCamera();
      } else if (status.isDenied) {
        debugPrint('DEBUG: Permission denied, requesting permission');
        final result = await Permission.camera.request();
        debugPrint('DEBUG: Permission request result: $result');

        if (result.isGranted) {
          debugPrint(
            'DEBUG: Permission granted after request, initializing camera',
          );
          await _initializeCamera();
        } else {
          debugPrint('DEBUG: Permission denied after request');
          setState(() {
            hasPermission = false;
            errorMessage =
                'Camera permission is required to scan QR codes for attendance.';
            isCheckingPermission = false;
          });
        }
      } else if (status.isPermanentlyDenied) {
        debugPrint('DEBUG: Permission permanently denied');
        setState(() {
          hasPermission = false;
          errorMessage =
              'Camera permission has been permanently denied. Please enable it in Settings.';
          isCheckingPermission = false;
        });
      } else {
        debugPrint('DEBUG: Permission in unknown state: $status');
        setState(() {
          hasPermission = false;
          errorMessage = 'Camera permission is required for QR code scanning';
          isCheckingPermission = false;
        });
      }
    } catch (e) {
      debugPrint('DEBUG: Error checking camera permission: $e');
      setState(() {
        hasPermission = false;
        errorMessage = 'Error checking camera permission: $e';
        isCheckingPermission = false;
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      debugPrint('DEBUG: Starting camera initialization');

      if (cameraController != null) {
        debugPrint('DEBUG: Disposing existing camera controller');
        await cameraController!.dispose();
      }

      debugPrint('DEBUG: Creating new MobileScannerController');
      cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      setState(() {
        hasPermission = true;
        isCheckingPermission = false;
        errorMessage = null;
      });

      debugPrint('DEBUG: Camera controller created successfully');

      // Small delay to ensure UI is updated before starting camera
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted && cameraController != null) {
        try {
          debugPrint('DEBUG: Starting camera controller');
          await cameraController!.start();
          debugPrint('DEBUG: Camera started successfully');
        } catch (e) {
          debugPrint('DEBUG: Failed to start camera: $e');
          setState(() {
            hasPermission = false;
            errorMessage = 'Failed to start camera: $e';
            isCheckingPermission = false;
          });
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Error initializing camera: $e');
      setState(() {
        hasPermission = false;
        errorMessage = 'Error initializing camera: $e';
        isCheckingPermission = false;
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
        actions: hasPermission && cameraController != null
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
    if (isCheckingPermission) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking camera permission...'),
          ],
        ),
      );
    }

    if (!hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'Camera Access Required',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Camera permission is needed to scan QR codes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final isPermanentlyDenied =
                      await Permission.camera.isPermanentlyDenied;
                  if (isPermanentlyDenied) {
                    openAppSettings();
                  } else {
                    _checkPermissions();
                  }
                },
                child: FutureBuilder<bool>(
                  future: Permission.camera.isPermanentlyDenied,
                  builder: (context, snapshot) {
                    final isPermanentlyDenied = snapshot.data ?? false;
                    return Text(
                      isPermanentlyDenied
                          ? 'Open Settings'
                          : 'Grant Permission',
                    );
                  },
                ),
              ),
            ],
          ),
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
            Text('Initializing camera...'),
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }
}
