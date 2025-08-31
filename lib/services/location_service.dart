import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Default attendance radius in meters (50 meters = ~164 feet)
  static const double defaultAttendanceRadius = 50.0;

  /// Check if location services are enabled and request permissions
  Future<LocationResult> checkLocationPermissions() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          message:
              'Location services are disabled. Please enable location services in your device settings.',
        );
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            success: false,
            message:
                'Location permissions are denied. Please grant location access to mark attendance.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          success: false,
          message:
              'Location permissions are permanently denied. Please enable them in your device settings.',
        );
      }

      return LocationResult(
        success: true,
        message: 'Location permissions granted.',
      );
    } catch (e) {
      return LocationResult(
        success: false,
        message: 'Error checking location permissions: $e',
      );
    }
  }

  /// Get current device location
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Check permissions first
      final permissionResult = await checkLocationPermissions();
      if (!permissionResult.success) {
        return permissionResult;
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationResult(
        success: true,
        message: 'Location retrieved successfully.',
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (e) {
      return LocationResult(
        success: false,
        message: 'Failed to get current location: $e',
      );
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Check if student is within attendance range
  Future<AttendanceLocationResult> verifyAttendanceLocation({
    required double teacherLat,
    required double teacherLon,
    double radiusMeters = defaultAttendanceRadius,
  }) async {
    try {
      // Get student's current location
      final locationResult = await getCurrentLocation();
      if (!locationResult.success) {
        return AttendanceLocationResult(
          success: false,
          message: locationResult.message,
          isWithinRange: false,
        );
      }

      // Calculate distance between teacher and student
      double distance = calculateDistance(
        teacherLat,
        teacherLon,
        locationResult.latitude!,
        locationResult.longitude!,
      );

      bool isWithinRange = distance <= radiusMeters;

      return AttendanceLocationResult(
        success: true,
        message: isWithinRange
            ? 'You are within the attendance area.'
            : 'You are outside the attendance area. Distance: ${distance.toStringAsFixed(1)}m',
        isWithinRange: isWithinRange,
        distance: distance,
        studentLat: locationResult.latitude!,
        studentLon: locationResult.longitude!,
        teacherLat: teacherLat,
        teacherLon: teacherLon,
        radiusMeters: radiusMeters,
      );
    } catch (e) {
      return AttendanceLocationResult(
        success: false,
        message: 'Error verifying location: $e',
        isWithinRange: false,
      );
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String> getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Address unavailable';
    }
  }
}

/// Result class for location operations
class LocationResult {
  final bool success;
  final String message;
  final double? latitude;
  final double? longitude;
  final double? accuracy;

  LocationResult({
    required this.success,
    required this.message,
    this.latitude,
    this.longitude,
    this.accuracy,
  });
}

/// Result class for attendance location verification
class AttendanceLocationResult {
  final bool success;
  final String message;
  final bool isWithinRange;
  final double? distance;
  final double? studentLat;
  final double? studentLon;
  final double? teacherLat;
  final double? teacherLon;
  final double? radiusMeters;

  AttendanceLocationResult({
    required this.success,
    required this.message,
    required this.isWithinRange,
    this.distance,
    this.studentLat,
    this.studentLon,
    this.teacherLat,
    this.teacherLon,
    this.radiusMeters,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'isWithinRange': isWithinRange,
    'distance': distance,
    'studentLat': studentLat,
    'studentLon': studentLon,
    'teacherLat': teacherLat,
    'teacherLon': teacherLon,
    'radiusMeters': radiusMeters,
  };
}
