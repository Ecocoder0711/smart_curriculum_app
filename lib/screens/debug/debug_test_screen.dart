import 'package:flutter/material.dart';
import '../../utils/logger.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';

class DebugTestScreen extends StatelessWidget {
  const DebugTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Theme Test
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Provider Test',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Is Dark Mode: ${themeProvider.isDarkMode}'),
                        Text('Is Loading: ${themeProvider.isLoading}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            AppLogger.demo('TEST: Manually calling toggleTheme()');
                            themeProvider.toggleTheme();
                          },
                          child: const Text('Toggle Theme'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Language Test
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Language Provider Test',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current Language: ${languageProvider.currentLanguageName}',
                        ),
                        Text(
                          'Current Locale: ${languageProvider.currentLocale}',
                        ),
                        Text('Is Loading: ${languageProvider.isLoading}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            AppLogger.demo('TEST: Manually changing to Hindi');
                            languageProvider.changeLanguage('हिंदी');
                          },
                          child: const Text('Switch to Hindi'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            AppLogger.demo('TEST: Manually changing to English');
                            languageProvider.changeLanguage('English');
                          },
                          child: const Text('Switch to English'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
