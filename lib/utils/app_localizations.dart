import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en', 'US'));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'save': 'Save',
      'select_language': 'Select Language',
      'english': 'English',
      'hindi': 'हिंदी',

      // Profile Screen
      'student_profile': 'Student Profile',
      'personal_information': 'Personal Information',
      'academic_information': 'Academic Information',
      'tap_edit_to_modify': 'Tap edit to modify fields',
      'full_name': 'Full Name',
      'email': 'Email',
      'roll_number': 'Roll Number',
      'class': 'Class',
      'section': 'Section',
      'semester': 'Semester',
      'department': 'Department',
      'edit_profile': 'Edit Profile',
      'logout': 'Logout',

      // Settings
      'settings': 'Settings',
      'notifications': 'Notifications',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'privacy_security': 'Privacy & Security',
      'sign_out_account': 'Sign out of your account',

      // Dashboard
      'assignments': 'Assignments',
      'view_pending_assignments': 'View pending assignments',
      'grades': 'Grades',
      'check_your_grades': 'Check your grades',

      // Navigation
      'home': 'Home',
      'schedule': 'Schedule',
      'attendance': 'Attendance',
      'profile': 'Profile',
    },
    'hi': {
      // Common
      'save': 'सेव',
      'select_language': 'भाषा चुनें',
      'english': 'English',
      'hindi': 'हिंदी',

      // Profile Screen
      'student_profile': 'छात्र प्रोफ़ाइल',
      'personal_information': 'व्यक्तिगत जानकारी',
      'academic_information': 'शैक्षणिक जानकारी',
      'tap_edit_to_modify': 'फ़ील्ड संशोधित करने के लिए संपादित करें',
      'full_name': 'पूरा नाम',
      'email': 'ईमेल',
      'roll_number': 'रोल नंबर',
      'class': 'कक्षा',
      'section': 'सेक्शन',
      'semester': 'सेमेस्टर',
      'department': 'विभाग',
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'logout': 'लॉगआउट',

      // Settings
      'settings': 'सेटिंग्स',
      'notifications': 'सूचनाएं',
      'dark_mode': 'डार्क मोड',
      'language': 'भाषा',
      'privacy_security': 'गोपनीयता और सुरक्षा',
      'sign_out_account': 'अपने खाते से साइन आउट करें',

      // Dashboard
      'assignments': 'असाइनमेंट',
      'view_pending_assignments': 'लंबित असाइनमेंट देखें',
      'grades': 'ग्रेड',
      'check_your_grades': 'अपने ग्रेड जांचें',

      // Navigation
      'home': 'होम',
      'schedule': 'शेड्यूल',
      'attendance': 'उपस्थिति',
      'profile': 'प्रोफ़ाइल',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Convenience getters for common translations
  String get studentProfile => translate('student_profile');
  String get personalInformation => translate('personal_information');
  String get academicInformation => translate('academic_information');
  String get tapEditToModify => translate('tap_edit_to_modify');
  String get fullName => translate('full_name');
  String get email => translate('email');
  String get rollNumber => translate('roll_number');
  String get className => translate('class');
  String get section => translate('section');
  String get semester => translate('semester');
  String get department => translate('department');
  String get editProfile => translate('edit_profile');
  String get logout => translate('logout');
  String get settings => translate('settings');
  String get notifications => translate('notifications');
  String get darkMode => translate('dark_mode');
  String get language => translate('language');
  String get privacySecurity => translate('privacy_security');
  String get signOutAccount => translate('sign_out_account');
  String get assignments => translate('assignments');
  String get viewPendingAssignments => translate('view_pending_assignments');
  String get grades => translate('grades');
  String get checkYourGrades => translate('check_your_grades');
  String get home => translate('home');
  String get schedule => translate('schedule');
  String get attendance => translate('attendance');
  String get profile => translate('profile');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
