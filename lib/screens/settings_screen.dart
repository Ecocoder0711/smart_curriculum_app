import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProfileService _profileService = ProfileService();
  Map<String, bool> _notificationPreferences = {};
  Map<String, dynamic> _privacySettings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        final notifications = await _profileService.getNotificationPreferences(
          user.id,
        );
        final privacy = await _profileService.getPrivacySettings(user.id);

        setState(() {
          _notificationPreferences = notifications;
          _privacySettings = privacy;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load settings: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._notificationPreferences.entries.map((entry) {
                      return SwitchListTile(
                        title: Text(_getNotificationTitle(entry.key)),
                        subtitle: Text(_getNotificationSubtitle(entry.key)),
                        value: entry.value,
                        onChanged: (value) {
                          _updateNotificationPreference(entry.key, value);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Privacy Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy & Security',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.visibility),
                      title: const Text('Profile Visibility'),
                      subtitle: Text(
                        _privacySettings['profile_visibility'] ?? 'Public',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _showProfileVisibilityDialog,
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.check_circle),
                      title: const Text('Show Attendance'),
                      subtitle: const Text(
                        'Allow others to see your attendance',
                      ),
                      value: _privacySettings['show_attendance'] ?? true,
                      onChanged: (value) {
                        _updatePrivacySetting('show_attendance', value);
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.grade),
                      title: const Text('Show Grades'),
                      subtitle: const Text('Allow others to see your grades'),
                      value: _privacySettings['show_grades'] ?? false,
                      onChanged: (value) {
                        _updatePrivacySetting('show_grades', value);
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.message),
                      title: const Text('Allow Messages'),
                      subtitle: const Text('Allow others to send you messages'),
                      value: _privacySettings['allow_messages'] ?? true,
                      onChanged: (value) {
                        _updatePrivacySetting('allow_messages', value);
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint),
                      title: const Text('Biometric Authentication'),
                      subtitle: const Text('Use fingerprint/face ID to unlock'),
                      value: _privacySettings['biometric_enabled'] ?? false,
                      onChanged: (value) {
                        _updatePrivacySetting('biometric_enabled', value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Account Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      subtitle: const Text('Update your account password'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _showChangePasswordDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Download Data'),
                      subtitle: const Text('Download a copy of your data'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _downloadData,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                      subtitle: const Text('Permanently delete your account'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _showDeleteAccountDialog,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: const Text('English'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _showLanguageDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Theme'),
                      subtitle: const Text('Light Mode'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _showThemeDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                      subtitle: const Text('App version and information'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _showAboutDialog,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNotificationTitle(String key) {
    switch (key) {
      case 'attendance_reminders':
        return 'Attendance Reminders';
      case 'assignment_notifications':
        return 'Assignment Notifications';
      case 'grade_updates':
        return 'Grade Updates';
      case 'general_announcements':
        return 'General Announcements';
      case 'push_notifications':
        return 'Push Notifications';
      default:
        return key;
    }
  }

  String _getNotificationSubtitle(String key) {
    switch (key) {
      case 'attendance_reminders':
        return 'Get reminded to mark attendance';
      case 'assignment_notifications':
        return 'New assignments and deadlines';
      case 'grade_updates':
        return 'When grades are posted';
      case 'general_announcements':
        return 'School and department updates';
      case 'push_notifications':
        return 'Enable push notifications';
      default:
        return '';
    }
  }

  void _updateNotificationPreference(String key, bool value) async {
    setState(() {
      _notificationPreferences[key] = value;
    });

    try {
      await _profileService.updateNotificationPreferences(
        _notificationPreferences,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preferences updated')),
        );
      }
    } catch (e) {
      // Revert the change
      setState(() {
        _notificationPreferences[key] = !value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update preferences: $e')),
        );
      }
    }
  }

  void _updatePrivacySetting(String key, dynamic value) async {
    final oldValue = _privacySettings[key];
    setState(() {
      _privacySettings[key] = value;
    });

    try {
      await _profileService.updatePrivacySettings(_privacySettings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy settings updated')),
        );
      }
    } catch (e) {
      // Revert the change
      setState(() {
        _privacySettings[key] = oldValue;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update settings: $e')),
        );
      }
    }
  }

  void _showProfileVisibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Visibility'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Public'),
              subtitle: const Text('Everyone can see your profile'),
              value: 'public',
              groupValue: _privacySettings['profile_visibility'],
              onChanged: (value) {
                Navigator.pop(context);
                _updatePrivacySetting('profile_visibility', value);
              },
            ),
            RadioListTile<String>(
              title: const Text('Friends'),
              subtitle: const Text('Only friends can see your profile'),
              value: 'friends',
              groupValue: _privacySettings['profile_visibility'],
              onChanged: (value) {
                Navigator.pop(context);
                _updatePrivacySetting('profile_visibility', value);
              },
            ),
            RadioListTile<String>(
              title: const Text('Private'),
              subtitle: const Text('Only you can see your profile'),
              value: 'private',
              groupValue: _privacySettings['profile_visibility'],
              onChanged: (value) {
                Navigator.pop(context);
                _updatePrivacySetting('profile_visibility', value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              try {
                await _profileService.changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to change password: $e')),
                  );
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _downloadData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Data'),
        content: const Text(
          'Your data download will be prepared and sent to your email within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download request submitted'),
                ),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion functionality coming soon'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Radio(
                value: 'en',
                groupValue: 'en',
                onChanged: (value) {},
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Hindi'),
              leading: Radio(
                value: 'hi',
                groupValue: 'en',
                onChanged: (value) {},
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Spanish'),
              leading: Radio(
                value: 'es',
                groupValue: 'en',
                onChanged: (value) {},
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light Mode'),
              leading: Radio(
                value: 'light',
                groupValue: 'light',
                onChanged: (value) {},
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Dark Mode'),
              leading: Radio(
                value: 'dark',
                groupValue: 'light',
                onChanged: (value) {},
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('System Default'),
              leading: Radio(
                value: 'system',
                groupValue: 'light',
                onChanged: (value) {},
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Curriculum App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.school, size: 48),
      children: [
        const Text('Smart Curriculum Activity & Attendance Management App'),
        const SizedBox(height: 16),
        const Text(
          'Developed for educational institutions to manage curriculum activities and track student attendance efficiently.',
        ),
      ],
    );
  }
}
