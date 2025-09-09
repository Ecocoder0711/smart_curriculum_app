import 'package:geolocator/geolocator.dart';

class LocationVerificationService {
  /// Maximum allowed distance from teacher's location (in meters)
  static const double maxDistanceMeters = 15.0;

  /// Check if location services are enabled and permissions are granted
  static Future<LocationServiceStatus> checkLocationService() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationServiceStatus(
          isEnabled: false,
          hasPermission: false,
          message:
              'Location services are disabled. Please enable them in device settings.',
        );
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationServiceStatus(
            isEnabled: true,
            hasPermission: false,
            message:
                'Location permission denied. Please grant permission to mark attendance.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationServiceStatus(
          isEnabled: true,
          hasPermission: false,
          message:
              'Location permission permanently denied. Please enable in app settings.',
        );
      }

      return LocationServiceStatus(
        isEnabled: true,
        hasPermission: true,
        message: 'Location services are working properly.',
      );
    } catch (e) {
      return LocationServiceStatus(
        isEnabled: false,
        hasPermission: false,
        message: 'Error checking location service: $e',
      );
    }
  }

  /// Get current device location with high accuracy
  static Future<Position?> getCurrentLocation() async {
    try {
      LocationServiceStatus status = await checkLocationService();
      if (!status.isEnabled || !status.hasPermission) {
        throw Exception(status.message);
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Verify if student is within allowed distance from teacher
  static Future<AttendanceVerificationResult> verifyStudentLocation({
    required double teacherLat,
    required double teacherLon,
    required double maxRadiusMeters,
  }) async {
    try {
      // Get student's current location
      Position? studentPosition = await getCurrentLocation();
      if (studentPosition == null) {
        return AttendanceVerificationResult(
          isValid: false,
          distance: null,
          message:
              'Unable to get your current location. Please check GPS and try again.',
        );
      }

      // Calculate distance between teacher and student
      double distance = Geolocator.distanceBetween(
        teacherLat,
        teacherLon,
        studentPosition.latitude,
        studentPosition.longitude,
      );

      bool isWithinRange = distance <= maxRadiusMeters;

      return AttendanceVerificationResult(
        isValid: isWithinRange,
        distance: distance,
        message: isWithinRange
            ? 'Location verified! You are ${distance.toStringAsFixed(1)}m from the classroom.'
            : 'You are too far from the classroom (${distance.toStringAsFixed(1)}m). Please move closer (max ${maxRadiusMeters}m).',
        studentLat: studentPosition.latitude,
        studentLon: studentPosition.longitude,
      );
    } catch (e) {
      return AttendanceVerificationResult(
        isValid: false,
        distance: null,
        message: 'Error verifying location: $e',
      );
    }
  }

  /// Test location accuracy by comparing multiple readings
  static Future<LocationAccuracyTest> testLocationAccuracy() async {
    try {
      List<Position> positions = [];
      List<double> accuracies = [];

      // Take 3 readings over 10 seconds
      for (int i = 0; i < 3; i++) {
        Position? position = await getCurrentLocation();
        if (position != null) {
          positions.add(position);
          accuracies.add(position.accuracy);
        }
        if (i < 2) await Future.delayed(const Duration(seconds: 5));
      }

      if (positions.isEmpty) {
        return LocationAccuracyTest(
          isAccurate: false,
          averageAccuracy: null,
          maxVariation: null,
          message: 'Unable to get location readings',
        );
      }

      // Calculate accuracy statistics
      double avgAccuracy =
          accuracies.reduce((a, b) => a + b) / accuracies.length;

      // Calculate position variation
      double maxDistance = 0;
      for (int i = 0; i < positions.length; i++) {
        for (int j = i + 1; j < positions.length; j++) {
          double distance = Geolocator.distanceBetween(
            positions[i].latitude,
            positions[i].longitude,
            positions[j].latitude,
            positions[j].longitude,
          );
          if (distance > maxDistance) maxDistance = distance;
        }
      }

      bool isAccurate =
          avgAccuracy <= 10.0 && maxDistance <= 5.0; // Good accuracy

      return LocationAccuracyTest(
        isAccurate: isAccurate,
        averageAccuracy: avgAccuracy,
        maxVariation: maxDistance,
        message: isAccurate
            ? 'Location accuracy is good (±${avgAccuracy.toStringAsFixed(1)}m)'
            : 'Location accuracy needs improvement (±${avgAccuracy.toStringAsFixed(1)}m)',
        readings: positions.length,
      );
    } catch (e) {
      return LocationAccuracyTest(
        isAccurate: false,
        averageAccuracy: null,
        maxVariation: null,
        message: 'Error testing location accuracy: $e',
      );
    }
  }
}

class LocationServiceStatus {
  final bool isEnabled;
  final bool hasPermission;
  final String message;

  LocationServiceStatus({
    required this.isEnabled,
    required this.hasPermission,
    required this.message,
  });

  bool get isWorking => isEnabled && hasPermission;
}

class AttendanceVerificationResult {
  final bool isValid;
  final double? distance;
  final String message;
  final double? studentLat;
  final double? studentLon;

  AttendanceVerificationResult({
    required this.isValid,
    required this.distance,
    required this.message,
    this.studentLat,
    this.studentLon,
  });
}

class LocationAccuracyTest {
  final bool isAccurate;
  final double? averageAccuracy;
  final double? maxVariation;
  final String message;
  final int readings;

  LocationAccuracyTest({
    required this.isAccurate,
    required this.averageAccuracy,
    required this.maxVariation,
    required this.message,
    this.readings = 0,
  });
}
