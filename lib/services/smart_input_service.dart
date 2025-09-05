class SmartInputService {
  // Common correction patterns for Indian names and academic terms
  static final Map<String, String> _commonCorrections = {
    // Name corrections
    'jhon': 'John',
    'jon': 'John',
    'micheal': 'Michael',
    'arjun': 'Arjun',
    'priya': 'Priya',
    'rahul': 'Rahul',
    'ankit': 'Ankit',
    'shreya': 'Shreya',
    'kumar': 'Kumar',
    'singh': 'Singh',
    'sharma': 'Sharma',
    'gupta': 'Gupta',

    // Department corrections
    'computr': 'Computer',
    'compter': 'Computer',
    'scienc': 'Science',
    'enginering': 'Engineering',
    'mathmatics': 'Mathematics',
    'phisics': 'Physics',
    'chemisty': 'Chemistry',
    'informaton': 'Information',
    'tecnology': 'Technology',
    'managment': 'Management',
    'bussiness': 'Business',
    'adminstration': 'Administration',

    // Subject corrections
    'algoritms': 'Algorithms',
    'databse': 'Database',
    'programing': 'Programming',
    'sofware': 'Software',
    'hardwar': 'Hardware',
    'netwrk': 'Network',
    'securty': 'Security',
    'artficial': 'Artificial',
    'inteligence': 'Intelligence',
    'machne': 'Machine',
    'lerning': 'Learning',

    // Common typos
    'tha': 'the',
    'teh': 'the',
    'recieve': 'receive',
    'seperate': 'separate',
    'occured': 'occurred',
    'begining': 'beginning',
    'adress': 'address',
    'goverment': 'government',
    'enviroment': 'environment',
  };

  // Email domain corrections
  static final Map<String, String> _emailDomainCorrections = {
    'gmial': 'gmail',
    'gmai': 'gmail',
    'yahooo': 'yahoo',
    'outlok': 'outlook',
    'hotmial': 'hotmail',
    'universty': 'university',
    'colege': 'college',
    'instute': 'institute',
    'acadmy': 'academy',
  };

  // Phone number patterns (Indian)
  static final RegExp _indianPhonePattern = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates and suggests corrections for names
  static ValidationResult validateName(String input) {
    if (input.isEmpty) {
      return ValidationResult(
        isValid: false,
        originalText: input,
        correctedText: input,
        suggestions: [],
        errorMessage: 'Name cannot be empty',
      );
    }

    String corrected = _applyCorrections(input);
    corrected = _capitalizeWords(corrected);

    List<String> suggestions = [];
    if (corrected != input) {
      suggestions.add(corrected);
    }

    // Additional name-specific validations
    if (corrected.length < 2) {
      return ValidationResult(
        isValid: false,
        originalText: input,
        correctedText: corrected,
        suggestions: suggestions,
        errorMessage: 'Name must be at least 2 characters long',
      );
    }

    if (RegExp(r'[0-9]').hasMatch(corrected)) {
      return ValidationResult(
        isValid: false,
        originalText: input,
        correctedText: corrected,
        suggestions: suggestions,
        errorMessage: 'Name should not contain numbers',
      );
    }

    return ValidationResult(
      isValid: true,
      originalText: input,
      correctedText: corrected,
      suggestions: suggestions,
      errorMessage: null,
    );
  }

  /// Validates and suggests corrections for email addresses
  static ValidationResult validateEmail(String input) {
    if (input.isEmpty) {
      return ValidationResult(
        isValid: false,
        originalText: input,
        correctedText: input,
        suggestions: [],
        errorMessage: 'Email cannot be empty',
      );
    }

    String corrected = input.toLowerCase().trim();

    // Apply domain corrections
    for (String typo in _emailDomainCorrections.keys) {
      if (corrected.contains(typo)) {
        corrected = corrected.replaceAll(typo, _emailDomainCorrections[typo]!);
      }
    }

    // Check for common mistakes
    if (corrected.contains('..')) {
      corrected = corrected.replaceAll('..', '.');
    }

    if (corrected.contains('@.')) {
      corrected = corrected.replaceAll('@.', '@');
    }

    List<String> suggestions = [];
    if (corrected != input.toLowerCase().trim()) {
      suggestions.add(corrected);
    }

    bool isValid = _emailPattern.hasMatch(corrected);

    return ValidationResult(
      isValid: isValid,
      originalText: input,
      correctedText: corrected,
      suggestions: suggestions,
      errorMessage: isValid ? null : 'Please enter a valid email address',
    );
  }

  /// Validates and suggests corrections for department names
  static ValidationResult validateDepartment(String input) {
    if (input.isEmpty) {
      return ValidationResult(
        isValid: false,
        originalText: input,
        correctedText: input,
        suggestions: [],
        errorMessage: 'Department cannot be empty',
      );
    }

    String corrected = _applyCorrections(input);
    corrected = _capitalizeWords(corrected);

    List<String> suggestions = [];
    if (corrected != input) {
      suggestions.add(corrected);
    }

    // Add common department suggestions if partial match
    List<String> commonDepartments = [
      'Computer Science',
      'Information Technology',
      'Electronics and Communication',
      'Mechanical Engineering',
      'Civil Engineering',
      'Electrical Engineering',
      'Business Administration',
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'English Literature',
      'Psychology',
      'Economics',
    ];

    String lowerInput = corrected.toLowerCase();
    for (String dept in commonDepartments) {
      if (dept.toLowerCase().contains(lowerInput) ||
          lowerInput.contains(
            dept.toLowerCase().split(' ').first.toLowerCase(),
          )) {
        if (!suggestions.contains(dept)) {
          suggestions.add(dept);
        }
      }
    }

    return ValidationResult(
      isValid: true,
      originalText: input,
      correctedText: corrected,
      suggestions: suggestions.take(3).toList(),
      errorMessage: null,
    );
  }

  /// Validates phone numbers (Indian format)
  static ValidationResult validatePhoneNumber(String input) {
    if (input.isEmpty) {
      return ValidationResult(
        isValid: false,
        originalText: input,
        correctedText: input,
        suggestions: [],
        errorMessage: 'Phone number cannot be empty',
      );
    }

    // Remove all non-digit characters
    String digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');

    String corrected = digitsOnly;
    List<String> suggestions = [];

    // Handle common formats
    if (digitsOnly.length == 11 && digitsOnly.startsWith('0')) {
      // Remove leading 0 for Indian numbers
      corrected = digitsOnly.substring(1);
      suggestions.add(corrected);
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      // Remove country code
      corrected = digitsOnly.substring(2);
      suggestions.add(corrected);
    } else if (digitsOnly.length == 13 && digitsOnly.startsWith('+91')) {
      corrected = digitsOnly.substring(3);
      suggestions.add(corrected);
    }

    bool isValid = _indianPhonePattern.hasMatch(corrected);

    if (!isValid && corrected.length == 10) {
      // Check if it starts with valid Indian mobile prefixes
      String firstDigit = corrected.substring(0, 1);
      if (!['6', '7', '8', '9'].contains(firstDigit)) {
        return ValidationResult(
          isValid: false,
          originalText: input,
          correctedText: corrected,
          suggestions: suggestions,
          errorMessage: 'Indian mobile numbers start with 6, 7, 8, or 9',
        );
      }
    }

    return ValidationResult(
      isValid: isValid,
      originalText: input,
      correctedText: corrected,
      suggestions: suggestions,
      errorMessage: isValid
          ? null
          : 'Please enter a valid 10-digit mobile number',
    );
  }

  /// Auto-translate text using Google Translate API (fallback to mock implementation)
  static Future<TranslationResult> translateText(
    String text,
    String targetLanguage,
  ) async {
    try {
      // Mock translation for demo purposes
      // In production, you would use Google Translate API or similar service
      return _mockTranslation(text, targetLanguage);
    } catch (e) {
      return TranslationResult(
        originalText: text,
        translatedText: text,
        detectedLanguage: 'unknown',
        targetLanguage: targetLanguage,
        confidence: 0.0,
      );
    }
  }

  /// Mock translation implementation
  static TranslationResult _mockTranslation(
    String text,
    String targetLanguage,
  ) {
    Map<String, Map<String, String>> translations = {
      'hi': {
        'john': 'जॉन',
        'smith': 'स्मिथ',
        'computer science': 'कंप्यूटर साइंस',
        'engineering': 'इंजीनियरिंग',
        'mathematics': 'गणित',
        'physics': 'भौतिकी',
        'chemistry': 'रसायन',
        'biology': 'जीव विज्ञान',
        'hello': 'नमस्ते',
        'welcome': 'स्वागत',
        'student': 'छात्र',
        'teacher': 'शिक्षक',
        'professor': 'प्रोफेसर',
      },
      'en': {
        'जॉन': 'John',
        'स्मिथ': 'Smith',
        'कंप्यूटर साइंस': 'Computer Science',
        'इंजीनियरिंग': 'Engineering',
        'गणित': 'Mathematics',
        'भौतिकी': 'Physics',
        'रसायन': 'Chemistry',
        'जीव विज्ञान': 'Biology',
        'नमस्ते': 'Hello',
        'स्वागत': 'Welcome',
        'छात्र': 'Student',
        'शिक्षक': 'Teacher',
        'प्रोफेसर': 'Professor',
      },
    };

    String lowerText = text.toLowerCase();
    String translatedText = text;

    if (translations.containsKey(targetLanguage)) {
      for (String key in translations[targetLanguage]!.keys) {
        if (lowerText.contains(key.toLowerCase())) {
          translatedText = translatedText.replaceAll(
            RegExp(key, caseSensitive: false),
            translations[targetLanguage]![key]!,
          );
        }
      }
    }

    return TranslationResult(
      originalText: text,
      translatedText: translatedText,
      detectedLanguage: targetLanguage == 'hi' ? 'en' : 'hi',
      targetLanguage: targetLanguage,
      confidence: translatedText != text ? 0.9 : 0.0,
    );
  }

  /// Apply common corrections to text
  static String _applyCorrections(String input) {
    String corrected = input.toLowerCase();

    for (String typo in _commonCorrections.keys) {
      corrected = corrected.replaceAll(
        typo,
        _commonCorrections[typo]!.toLowerCase(),
      );
    }

    return corrected;
  }

  /// Capitalize first letter of each word
  static String _capitalizeWords(String input) {
    return input
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Smart suggestions for academic fields
  static List<String> getAcademicSuggestions(String input, String fieldType) {
    List<String> suggestions = [];
    String lowerInput = input.toLowerCase();

    Map<String, List<String>> fieldData = {
      'subjects': [
        'Data Structures',
        'Algorithms',
        'Database Systems',
        'Computer Networks',
        'Operating Systems',
        'Software Engineering',
        'Machine Learning',
        'Artificial Intelligence',
        'Web Development',
        'Mobile Development',
        'Cybersecurity',
        'Cloud Computing',
        'Blockchain Technology',
        'Digital Signal Processing',
        'Computer Graphics',
        'Human Computer Interaction',
        'Mathematics',
        'Physics',
        'Chemistry',
        'Biology',
        'English Literature',
        'History',
        'Geography',
        'Economics',
        'Psychology',
        'Sociology',
      ],
      'departments': [
        'Computer Science and Engineering',
        'Information Technology',
        'Electronics and Communication Engineering',
        'Mechanical Engineering',
        'Civil Engineering',
        'Electrical Engineering',
        'Chemical Engineering',
        'Aerospace Engineering',
        'Biotechnology',
        'Business Administration',
        'Management Studies',
        'Mathematics',
        'Physics',
        'Chemistry',
        'Biology',
        'English Literature',
        'Psychology',
        'Economics',
      ],
      'universities': [
        'Indian Institute of Technology',
        'Indian Institute of Science',
        'National Institute of Technology',
        'Indian Institute of Management',
        'Delhi University',
        'Mumbai University',
        'Pune University',
        'Bangalore University',
        'Chennai University',
        'Kolkata University',
        'Jawaharlal Nehru University',
        'Aligarh Muslim University',
        'Banaras Hindu University',
        'Anna University',
        'Osmania University',
      ],
    };

    if (fieldData.containsKey(fieldType)) {
      for (String item in fieldData[fieldType]!) {
        if (item.toLowerCase().contains(lowerInput) ||
            lowerInput.contains(
              item.toLowerCase().split(' ').first.toLowerCase(),
            )) {
          suggestions.add(item);
        }
      }
    }

    return suggestions.take(5).toList();
  }
}

class ValidationResult {
  final bool isValid;
  final String originalText;
  final String correctedText;
  final List<String> suggestions;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    required this.originalText,
    required this.correctedText,
    required this.suggestions,
    this.errorMessage,
  });
}

class TranslationResult {
  final String originalText;
  final String translatedText;
  final String detectedLanguage;
  final String targetLanguage;
  final double confidence;

  TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.detectedLanguage,
    required this.targetLanguage,
    required this.confidence,
  });
}
