import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/attendance_service.dart';
import '../services/location_service.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _locationController = TextEditingController();
  final _radiusController = TextEditingController(
    text: '50',
  ); // Default 50 meters
  String? _generatedQRData;
  String? _classSessionId;
  bool _isGenerating = false;
  double? _currentLat;
  double? _currentLon;

  @override
  void dispose() {
    _subjectController.dispose();
    _locationController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Attendance QR'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class Session Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject/Course',
                          hintText: 'e.g., Data Structures',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.book),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter subject name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Class Location',
                          hintText: 'e.g., Room 101, CS Department',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter class location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _radiusController,
                        decoration: const InputDecoration(
                          labelText: 'Attendance Range (meters)',
                          hintText: 'e.g., 50',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.radio_button_unchecked),
                          suffixText: 'm',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter attendance range';
                          }
                          final radius = double.tryParse(value.trim());
                          if (radius == null || radius <= 0 || radius > 1000) {
                            return 'Please enter a valid range (1-1000 meters)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateQR,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.qr_code),
                          label: Text(
                            _isGenerating
                                ? 'Getting Location...'
                                : 'Generate QR Code',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_generatedQRData != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Attendance QR Code',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: QrImageView(
                            data: _generatedQRData!,
                            version: QrVersions.auto,
                            size: 250.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Session Details:',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Subject: ${_subjectController.text}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Location: ${_locationController.text}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Attendance Range: ${_radiusController.text}m',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (_currentLat != null &&
                                  _currentLon != null) ...[
                                Text(
                                  'GPS: ${_currentLat!.toStringAsFixed(6)}, ${_currentLon!.toStringAsFixed(6)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              Text(
                                'Session ID: $_classSessionId',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Created: ${DateTime.now().toString().substring(0, 19)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _shareQR,
                                icon: const Icon(Icons.share),
                                label: const Text('Share QR'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _generateNewQR,
                                icon: const Icon(Icons.refresh),
                                label: const Text('New QR'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instructions',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Display this QR code to students at the beginning of class\n'
                          '• Students can scan the QR code using the app to mark attendance\n'
                          '• QR code contains GPS coordinates for location verification\n'
                          '• Students must be within the specified range to mark attendance\n'
                          '• Proxy attendance is automatically detected and blocked\n'
                          '• QR codes expire after the class session ends',
                          style: TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _generateQR() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final teacher = authProvider.user;

      if (teacher == null) {
        _showErrorSnackBar('Authentication error. Please log in again.');
        return;
      }

      // Get current location
      final locationService = LocationService();
      final locationResult = await locationService.getCurrentLocation();

      if (!locationResult.success) {
        _showErrorSnackBar('Failed to get location: ${locationResult.message}');
        return;
      }

      _currentLat = locationResult.latitude!;
      _currentLon = locationResult.longitude!;

      // Generate unique session ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sessionId = 'session_${teacher.id}_$timestamp';

      // Parse radius
      final radiusMeters = double.parse(_radiusController.text.trim());

      // Generate QR data with location
      final attendanceService = AttendanceService();
      final qrData = attendanceService.generateQRDataWithLocation(
        classSessionId: sessionId,
        location: _locationController.text.trim(),
        teacherLat: _currentLat!,
        teacherLon: _currentLon!,
        radiusMeters: radiusMeters,
      );

      setState(() {
        _classSessionId = sessionId;
        _generatedQRData = qrData;
      });

      // Show success message
      _showSuccessSnackBar('QR Code generated with location verification!');
    } catch (e) {
      _showErrorSnackBar('Failed to generate QR code: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('QR Code generated successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareQR() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _generateNewQR() {
    setState(() {
      _generatedQRData = null;
      _classSessionId = null;
    });
    _subjectController.clear();
    _locationController.clear();
  }
}
