import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selectedLanguage';

  // Supported languages (English and Hindi only)
  static const Map<String, Locale> supportedLanguages = {
    'English': Locale('en', 'US'),
    'हिंदी': Locale('hi', 'IN'),
  };

  Locale _currentLocale = const Locale('en', 'US');
  bool _isLoading = true;

  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;

  String get currentLanguageName {
    for (String key in supportedLanguages.keys) {
      if (supportedLanguages[key] == _currentLocale) {
        return key;
      }
    }
    return 'English';
  }

  LanguageProvider() {
    _loadLanguageFromPrefs();
  }

  // Load language preference from SharedPreferences
  Future<void> _loadLanguageFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';

      if (languageCode == 'hi') {
        _currentLocale = const Locale('hi', 'IN');
      } else {
        _currentLocale = const Locale('en', 'US');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading language preference: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change language
  Future<void> changeLanguage(String languageName) async {
    print('DEBUG: changeLanguage() called with: $languageName');
    final locale = supportedLanguages[languageName];
    print('DEBUG: changeLanguage() - locale found: $locale');
    print('DEBUG: changeLanguage() - current locale: $_currentLocale');
    if (locale != null && locale != _currentLocale) {
      _currentLocale = locale;
      print('DEBUG: changeLanguage() - setting new locale: $_currentLocale');
      notifyListeners();
      await _saveLanguageToPrefs();
      print('DEBUG: changeLanguage() - saved to prefs');
    } else {
      print('DEBUG: changeLanguage() - no change needed or locale not found');
    }
  }

  // Save language preference to SharedPreferences
  Future<void> _saveLanguageToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, _currentLocale.languageCode);
    } catch (e) {
      print('Error saving language preference: $e');
    }
  }

  // Get available language names
  List<String> get availableLanguages => supportedLanguages.keys.toList();
}
