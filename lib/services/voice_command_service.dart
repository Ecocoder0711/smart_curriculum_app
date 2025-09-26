import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:flutter_tts/flutter_tts.dart';

/// Voice Command Service for Smart India Hackathon
/// Provides hands-free interaction with the app
class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  // Mock implementation - in production, use speech_to_text and flutter_tts packages
  // late SpeechToText _speechToText;
  // late FlutterTts _flutterTts;

  bool _speechEnabled = false;
  bool _speechAvailable = false;
  String _lastWords = '';

  final StreamController<VoiceCommand> _commandController =
      StreamController<VoiceCommand>.broadcast();

  Stream<VoiceCommand> get commandStream => _commandController.stream;

  /// Initialize voice services
  Future<bool> initialize() async {
    try {
      // Mock initialization
      _speechAvailable = true;
      _speechEnabled = true;

      // In production:
      // _speechToText = SpeechToText();
      // _flutterTts = FlutterTts();
      // _speechEnabled = await _speechToText.initialize();
      // await _flutterTts.setLanguage("en-US");
      // await _flutterTts.setPitch(1.0);

      return _speechEnabled;
    } catch (e) {
      debugPrint('Voice initialization error: $e');
      return false;
    }
  }

  /// Start listening for voice commands
  Future<void> startListening() async {
    if (!_speechEnabled) return;

    // Mock listening implementation
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate voice recognition
    _simulateVoiceRecognition();

    // In production:
    // await _speechToText.listen(
    //   onResult: _onSpeechResult,
    //   listenFor: const Duration(seconds: 30),
    //   pauseFor: const Duration(seconds: 3),
    //   partialResults: true,
    //   localeId: "en_US",
    //   onSoundLevelChange: (level) => debugPrint('Sound level: $level'),
    // );
  }

  /// Stop listening
  Future<void> stopListening() async {
    // await _speechToText.stop();
  }

  /// Speak text aloud
  Future<void> speak(String text) async {
    try {
      debugPrint('Speaking: $text'); // Mock implementation

      // In production:
      // await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  /// Process voice input and extract commands
  void _processVoiceInput(String recognizedWords) {
    _lastWords = recognizedWords.toLowerCase();

    final command = _parseCommand(_lastWords);
    if (command.type != VoiceCommandType.unknown) {
      _commandController.add(command);
    }
  }

  /// Parse voice input into structured commands
  VoiceCommand _parseCommand(String input) {
    // Attendance commands
    if (input.contains('mark attendance') || input.contains('scan qr')) {
      return VoiceCommand(
        type: VoiceCommandType.markAttendance,
        action: 'navigate_to_qr_scanner',
        parameters: {},
        confidence: 0.9,
        originalText: input,
      );
    }

    // Navigation commands
    if (input.contains('go to dashboard') || input.contains('open dashboard')) {
      return VoiceCommand(
        type: VoiceCommandType.navigate,
        action: 'dashboard',
        parameters: {},
        confidence: 0.85,
        originalText: input,
      );
    }

    if (input.contains('show schedule') || input.contains('my classes')) {
      return VoiceCommand(
        type: VoiceCommandType.navigate,
        action: 'schedule',
        parameters: {},
        confidence: 0.88,
        originalText: input,
      );
    }

    // Information queries
    if (input.contains('attendance percentage') ||
        input.contains('my attendance')) {
      return VoiceCommand(
        type: VoiceCommandType.query,
        action: 'get_attendance_stats',
        parameters: {},
        confidence: 0.92,
        originalText: input,
      );
    }

    if (input.contains('upcoming assignments') ||
        input.contains('pending work')) {
      return VoiceCommand(
        type: VoiceCommandType.query,
        action: 'get_assignments',
        parameters: {},
        confidence: 0.87,
        originalText: input,
      );
    }

    // Settings commands
    if (input.contains('dark mode') || input.contains('change theme')) {
      return VoiceCommand(
        type: VoiceCommandType.settings,
        action: 'toggle_theme',
        parameters: {},
        confidence: 0.9,
        originalText: input,
      );
    }

    if (input.contains('switch language') ||
        input.contains('change language')) {
      String? language;
      if (input.contains('hindi')) language = 'hi';
      if (input.contains('english')) language = 'en';

      return VoiceCommand(
        type: VoiceCommandType.settings,
        action: 'change_language',
        parameters: {'language': language ?? 'en'},
        confidence: 0.85,
        originalText: input,
      );
    }

    // AI features
    if (input.contains('smart recommendations') ||
        input.contains('ai suggestions')) {
      return VoiceCommand(
        type: VoiceCommandType.ai,
        action: 'show_recommendations',
        parameters: {},
        confidence: 0.88,
        originalText: input,
      );
    }

    if (input.contains('predict grades') ||
        input.contains('grade prediction')) {
      return VoiceCommand(
        type: VoiceCommandType.ai,
        action: 'predict_performance',
        parameters: {},
        confidence: 0.86,
        originalText: input,
      );
    }

    // Help commands
    if (input.contains('help') || input.contains('what can you do')) {
      return VoiceCommand(
        type: VoiceCommandType.help,
        action: 'show_commands',
        parameters: {},
        confidence: 0.95,
        originalText: input,
      );
    }

    return VoiceCommand(
      type: VoiceCommandType.unknown,
      action: '',
      parameters: {},
      confidence: 0.0,
      originalText: input,
    );
  }

  /// Get list of available voice commands
  List<VoiceCommandHelp> getAvailableCommands() {
    return [
      VoiceCommandHelp(
        phrase: "Mark attendance",
        description: "Opens QR code scanner for attendance",
        example: "Hey app, mark attendance",
      ),
      VoiceCommandHelp(
        phrase: "Show my schedule",
        description: "Displays your class schedule",
        example: "Show my classes today",
      ),
      VoiceCommandHelp(
        phrase: "My attendance percentage",
        description: "Tells you your current attendance",
        example: "What's my attendance?",
      ),
      VoiceCommandHelp(
        phrase: "Upcoming assignments",
        description: "Lists pending assignments",
        example: "Show pending work",
      ),
      VoiceCommandHelp(
        phrase: "Switch to dark mode",
        description: "Changes app theme",
        example: "Enable dark mode",
      ),
      VoiceCommandHelp(
        phrase: "Change language to Hindi",
        description: "Switches app language",
        example: "Switch language to Hindi",
      ),
      VoiceCommandHelp(
        phrase: "Smart recommendations",
        description: "Shows AI-powered suggestions",
        example: "Give me smart recommendations",
      ),
      VoiceCommandHelp(
        phrase: "Predict my grades",
        description: "Shows AI grade predictions",
        example: "What are my predicted grades?",
      ),
    ];
  }

  /// Simulate voice recognition for demo
  void _simulateVoiceRecognition() {
    final demoCommands = [
      "mark attendance",
      "show my schedule",
      "my attendance percentage",
      "switch to dark mode",
      "smart recommendations",
    ];

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (timer.tick > 3) {
        timer.cancel();
        return;
      }

      final randomCommand = (demoCommands..shuffle()).first;
      _processVoiceInput(randomCommand);
    });
  }

  bool get isAvailable => _speechAvailable;
  bool get isListening => _speechEnabled; // Mock implementation
  String get lastWords => _lastWords;

  void dispose() {
    _commandController.close();
  }
}

/// Voice command data structure
class VoiceCommand {
  final VoiceCommandType type;
  final String action;
  final Map<String, dynamic> parameters;
  final double confidence;
  final String originalText;
  final DateTime timestamp;

  VoiceCommand({
    required this.type,
    required this.action,
    required this.parameters,
    required this.confidence,
    required this.originalText,
  }) : timestamp = DateTime.now();
}

enum VoiceCommandType {
  markAttendance,
  navigate,
  query,
  settings,
  ai,
  help,
  unknown,
}

class VoiceCommandHelp {
  final String phrase;
  final String description;
  final String example;

  VoiceCommandHelp({
    required this.phrase,
    required this.description,
    required this.example,
  });
}

/// Voice Command Widget - Floating action button with voice controls
class VoiceCommandWidget extends StatefulWidget {
  final Function(VoiceCommand) onCommand;

  const VoiceCommandWidget({super.key, required this.onCommand});

  @override
  State<VoiceCommandWidget> createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends State<VoiceCommandWidget>
    with TickerProviderStateMixin {
  final VoiceCommandService _voiceService = VoiceCommandService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isListening = false;
  bool _isInitialized = false;
  StreamSubscription<VoiceCommand>? _commandSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeVoice();
  }

  Future<void> _initializeVoice() async {
    _isInitialized = await _voiceService.initialize();

    if (_isInitialized) {
      _commandSubscription = _voiceService.commandStream.listen((command) {
        widget.onCommand(command);
        _stopListening();
      });
    }

    setState(() {});
  }

  void _toggleListening() async {
    if (!_isInitialized) return;

    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    setState(() => _isListening = true);
    _animationController.repeat(reverse: true);
    await _voiceService.startListening();
  }

  void _stopListening() async {
    setState(() => _isListening = false);
    _animationController.stop();
    _animationController.reset();
    await _voiceService.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(); // Hide if voice not available
    }

    return Positioned(
      bottom: 100,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isListening)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🎤 Listening...',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (_isListening) const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening ? _scaleAnimation.value : 1.0,
                child: FloatingActionButton(
                  onPressed: _toggleListening,
                  backgroundColor: _isListening ? Colors.red : Colors.blue,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commandSubscription?.cancel();
    super.dispose();
  }
}
