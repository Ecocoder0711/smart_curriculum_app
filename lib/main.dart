import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'utils/app_localizations.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/student/student_dashboard.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartCurriculumApp());
}

class SmartCurriculumApp extends StatelessWidget {
  const SmartCurriculumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'Smart Curriculum App',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.currentLocale,
            supportedLocales: const [Locale('en', 'US'), Locale('hi', 'IN')],
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Avoid lerping between theme TextStyles to prevent inherit mismatches
            themeAnimationDuration: Duration(milliseconds: 0),
            themeAnimationCurve: Curves.linear,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32),
                brightness: Brightness.light,
              ),
              fontFamily: GoogleFonts.inter().fontFamily,
              // Use the same base for both light and dark to keep TextStyle inheritance consistent
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.light().textTheme.copyWith(
                  bodyLarge: const TextStyle(color: Colors.black87),
                  bodyMedium: const TextStyle(color: Colors.black87),
                  titleMedium: const TextStyle(color: Colors.black87),
                  titleLarge: const TextStyle(color: Colors.black87),
                ),
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              cardTheme: const CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              listTileTheme: const ListTileThemeData(
                textColor: Colors.black87,
                iconColor: Colors.black54,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32),
                brightness: Brightness.dark,
                surface: const Color(
                  0xFF1A1A1A,
                ), // Deeper card background like Netflix/Spotify
                onSurface: const Color(0xFFE8E8E8), // Softer white text
                primary: const Color(0xFF4CAF50), // Brighter green for accents
                secondary: const Color(
                  0xFF81C784,
                ), // Lighter green for secondary elements
                tertiary: const Color(0xFF388E3C), // Medium green for variety
                surfaceVariant: const Color(
                  0xFF2D2D2D,
                ), // Slightly lighter for elevated surfaces
                onSurfaceVariant: const Color(0xFFB0B0B0), // Muted text
                outline: const Color(0xFF3A3A3A), // Subtle borders
              ),
              scaffoldBackgroundColor: const Color(
                0xFF0D0D0D,
              ), // Very dark background like premium apps
              fontFamily: GoogleFonts.inter().fontFamily,
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.dark().textTheme.copyWith(
                  displayLarge: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w300,
                  ),
                  displayMedium: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w400,
                  ),
                  displaySmall: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w400,
                  ),
                  headlineLarge: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w400,
                  ),
                  headlineMedium: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w400,
                  ),
                  headlineSmall: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w400,
                  ),
                  titleLarge: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                  titleMedium: const TextStyle(
                    color: Color(0xFFE8E8E8),
                    fontWeight: FontWeight.w500,
                  ),
                  titleSmall: const TextStyle(
                    color: Color(0xFFE8E8E8),
                    fontWeight: FontWeight.w500,
                  ),
                  bodyLarge: const TextStyle(
                    color: Color(0xFFE8E8E8),
                    fontWeight: FontWeight.w400,
                  ),
                  bodyMedium: const TextStyle(
                    color: Color(0xFFE8E8E8),
                    fontWeight: FontWeight.w400,
                  ),
                  bodySmall: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w400,
                  ),
                  labelLarge: const TextStyle(
                    color: Color(0xFFE8E8E8),
                    fontWeight: FontWeight.w500,
                  ),
                  labelMedium: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w500,
                  ),
                  labelSmall: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: const Color(
                  0xFF000000,
                ), // Pure black for dark mode
                surfaceTintColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                titleTextStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
                color: const Color(0xFF1A1A1A),
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF3A3A3A).withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Improve text contrast in dark mode
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
              listTileTheme: const ListTileThemeData(
                textColor: Color(0xFFE8E8E8),
                iconColor: Color(0xFFB0B0B0),
                selectedTileColor: Color(0xFF2D2D2D),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF4CAF50);
                  }
                  return const Color(0xFF666666);
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF4CAF50).withOpacity(0.3);
                  }
                  return const Color(0xFF3A3A3A);
                }),
              ),
              dividerTheme: const DividerThemeData(
                color: Color(0xFF3A3A3A),
                thickness: 0.5,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF2D2D2D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4CAF50),
                    width: 2,
                  ),
                ),
                labelStyle: const TextStyle(
                  color: Color(0xFFE8E8E8),
                  fontSize: 14,
                ), // Brighter label text
                hintStyle: const TextStyle(
                  color: Color(0xFFB0B0B0),
                ), // Softer hint text
                // Style for input text
                floatingLabelStyle: const TextStyle(
                  color: Color(0xFF4CAF50),
                ), // Green when focused
              ),
            ),
            home: const AppWrapper(),
          );
        },
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show splash screen while loading
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        // Show appropriate dashboard based on user role
        if (authProvider.isLoggedIn) {
          switch (authProvider.user!.role) {
            case UserRole.teacher:
              return const TeacherDashboard();
            case UserRole.student:
              return const StudentDashboard();
            case UserRole.admin:
              return const TeacherDashboard(); // Use teacher dashboard for admin for now
          }
        }

        // Show login screen if not logged in
        return const LoginScreen();
      },
    );
  }
}
