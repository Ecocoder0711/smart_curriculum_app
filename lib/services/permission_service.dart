import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Check and request camera permission for QR scanning
  Future<PermissionResult> checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;

      if (status.isGranted) {
        return PermissionResult(
          isGranted: true,
          message: 'Camera permission granted',
        );
      }

      if (status.isDenied) {
        final result = await Permission.camera.request();
        if (result.isGranted) {
          return PermissionResult(
            isGranted: true,
            message: 'Camera permission granted',
          );
        } else {
          return PermissionResult(
            isGranted: false,
            message:
                'Camera permission is required to scan QR codes for attendance',
            showSettings: true,
          );
        }
      }

      if (status.isPermanentlyDenied) {
        return PermissionResult(
          isGranted: false,
          message:
              'Camera permission has been permanently denied. Please enable it in Settings to scan QR codes.',
          showSettings: true,
        );
      }

      return PermissionResult(
        isGranted: false,
        message: 'Camera permission is required for QR code scanning',
      );
    } catch (e) {
      debugPrint('Error checking camera permission: $e');
      return PermissionResult(
        isGranted: false,
        message: 'Error checking camera permission: $e',
      );
    }
  }

  /// Check and request location permission for attendance verification
  Future<PermissionResult> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;

      if (status.isGranted) {
        return PermissionResult(
          isGranted: true,
          message: 'Location permission granted',
        );
      }

      if (status.isDenied) {
        final result = await Permission.location.request();
        if (result.isGranted) {
          return PermissionResult(
            isGranted: true,
            message: 'Location permission granted',
          );
        } else {
          return PermissionResult(
            isGranted: false,
            message:
                'Location permission is required to verify your attendance location and prevent proxy attendance',
            showSettings: false, // Allow fallback for demo
          );
        }
      }

      if (status.isPermanentlyDenied) {
        return PermissionResult(
          isGranted: false,
          message:
              'Location permission has been permanently denied. For security, attendance verification requires location access.',
          showSettings: true,
        );
      }

      return PermissionResult(
        isGranted: false,
        message: 'Location permission is required for attendance verification',
      );
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return PermissionResult(
        isGranted: false,
        message:
            'Location permission check failed, proceeding with limited functionality',
      );
    }
  }

  /// Check multiple permissions at once
  Future<Map<String, PermissionResult>> checkAttendancePermissions() async {
    final results = <String, PermissionResult>{};

    results['camera'] = await checkCameraPermission();
    results['location'] = await checkLocationPermission();

    return results;
  }

  /// Open app settings
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Show permission dialog with professional UI
  static void showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onGrant,
    VoidCallback? onDeny,
    bool showSettings = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.security,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This helps ensure secure and accurate attendance tracking.',
                        style: TextStyle(color: Colors.blue[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (onDeny != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDeny();
                },
                child: const Text('Not Now'),
              ),
            if (showSettings)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  PermissionService().openSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onGrant();
                },
                icon: const Icon(Icons.check),
                label: const Text('Grant Permission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        );
      },
    );
  }

  /// Show loading dialog while checking permissions
  static void showPermissionLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Checking Permissions...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Verifying camera and location access for secure attendance',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class PermissionResult {
  final bool isGranted;
  final String message;
  final bool showSettings;

  PermissionResult({
    required this.isGranted,
    required this.message,
    this.showSettings = false,
  });
}
