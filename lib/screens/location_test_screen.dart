import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_verification_service.dart';

class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  bool _isLoading = false;
  LocationServiceStatus? _serviceStatus;
  Position? _currentPosition;
  LocationAccuracyTest? _accuracyTest;
  AttendanceVerificationResult? _mockTest;

  @override
  void initState() {
    super.initState();
    _checkLocationService();
  }

  Future<void> _checkLocationService() async {
    setState(() => _isLoading = true);
    try {
      final status = await LocationVerificationService.checkLocationService();
      setState(() => _serviceStatus = status);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await LocationVerificationService.getCurrentLocation();
      setState(() => _currentPosition = position);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testAccuracy() async {
    setState(() => _isLoading = true);
    try {
      final test = await LocationVerificationService.testLocationAccuracy();
      setState(() => _accuracyTest = test);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _mockAttendanceTest() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please get current location first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Mock teacher location very close to student (within 15m)
      final result = await LocationVerificationService.verifyStudentLocation(
        teacherLat: _currentPosition!.latitude + 0.0001, // ~11m away
        teacherLon: _currentPosition!.longitude + 0.0001,
        maxRadiusMeters: 15.0,
      );
      setState(() => _mockTest = result);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Location Service Test',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Location Services Diagnostic',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This tool helps verify if location services are working properly for attendance verification.',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Service Status Card
                    _buildTestCard(
                      title: '1. Location Service Status',
                      icon: Icons.location_on,
                      onPressed: _checkLocationService,
                      child: _serviceStatus != null
                          ? _buildStatusResult(_serviceStatus!)
                          : const Text('Tap to check location service status'),
                    ),

                    const SizedBox(height: 16),

                    // Current Location Card
                    _buildTestCard(
                      title: '2. Get Current Location',
                      icon: Icons.my_location,
                      onPressed: _getCurrentLocation,
                      child: _currentPosition != null
                          ? _buildLocationResult(_currentPosition!)
                          : const Text('Tap to get your current location'),
                    ),

                    const SizedBox(height: 16),

                    // Accuracy Test Card
                    _buildTestCard(
                      title: '3. Location Accuracy Test',
                      icon: Icons.speed,
                      onPressed: _testAccuracy,
                      child: _accuracyTest != null
                          ? _buildAccuracyResult(_accuracyTest!)
                          : const Text('Tap to test location accuracy (takes ~10 seconds)'),
                    ),

                    const SizedBox(height: 16),

                    // Mock Attendance Test Card
                    _buildTestCard(
                      title: '4. Mock Attendance Verification',
                      icon: Icons.verified_user,
                      onPressed: _mockAttendanceTest,
                      child: _mockTest != null
                          ? _buildMockTestResult(_mockTest!)
                          : const Text('Tap to simulate attendance verification'),
                    ),

                    const SizedBox(height: 24),

                    // Status Summary
                    if (_serviceStatus != null && _currentPosition != null && _accuracyTest != null)
                      _buildSummaryCard(),
                  ],
                ),
              ),
            ),

            // Loading indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon, 
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusResult(LocationServiceStatus status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.isWorking
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status.isWorking ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            status.isWorking ? Icons.check_circle : Icons.error,
            color: status.isWorking ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.message,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationResult(Position position) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Location obtained successfully',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Latitude: ${position.latitude.toStringAsFixed(6)}',
            style: TextStyle(
              fontFamily: 'monospace',
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          Text(
            'Longitude: ${position.longitude.toStringAsFixed(6)}',
            style: TextStyle(
              fontFamily: 'monospace',
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          Text(
            'Accuracy: ±${position.accuracy.toStringAsFixed(1)}m',
            style: TextStyle(
              fontFamily: 'monospace',
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyResult(LocationAccuracyTest test) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: test.isAccurate
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: test.isAccurate ? Colors.green : Colors.orange,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                test.isAccurate ? Icons.check_circle : Icons.warning,
                color: test.isAccurate ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  test.message,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (test.averageAccuracy != null) ...[
            const SizedBox(height: 8),
            Text(
              'Average accuracy: ±${test.averageAccuracy!.toStringAsFixed(1)}m',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
            Text(
              'Position variation: ${test.maxVariation?.toStringAsFixed(1) ?? 'N/A'}m',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
            Text(
              'Readings taken: ${test.readings}',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMockTestResult(AttendanceVerificationResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result.isValid
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: result.isValid ? Colors.green : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.isValid ? Icons.check_circle : Icons.error,
                color: result.isValid ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.message,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (result.distance != null) ...[
            const SizedBox(height: 8),
            Text(
              'Distance from mock teacher: ${result.distance!.toStringAsFixed(1)}m',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAllGood = _serviceStatus!.isWorking && 
                     _currentPosition != null && 
                     (_accuracyTest?.isAccurate ?? false);
    
    return Card(
      elevation: 3,
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAllGood ? Icons.verified : Icons.warning,
                  color: isAllGood ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Overall Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isAllGood
                  ? 'Location services are working perfectly! The 15m attendance verification should work reliably.'
                  : 'Location services have some issues. Attendance verification may not work properly.',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Recommendations:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            if (!_serviceStatus!.isWorking)
              Text(
                '• Enable location services and grant permissions',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
            if (_currentPosition == null)
              Text(
                '• Make sure GPS signal is strong (go outdoors if needed)',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
            if (!(_accuracyTest?.isAccurate ?? true))
              Text(
                '• Improve GPS accuracy by going outdoors or near windows',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
            if (isAllGood)
              Text(
                '• Location services are ready for attendance verification!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
