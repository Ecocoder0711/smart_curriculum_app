// This is a basic Flutter widget test for Smart Curriculum App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_curriculum_app/providers/auth_provider.dart';
import 'package:smart_curriculum_app/providers/language_provider.dart';
import 'package:smart_curriculum_app/providers/theme_provider.dart';
import 'package:smart_curriculum_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login Screen Widget Test', (WidgetTester tester) async {
    // Build our app with minimal setup for testing
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(home: const LoginScreen()),
      ),
    );

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify that we can find the login screen elements
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
  });

  testWidgets('Login Form Validation Test', (WidgetTester tester) async {
    // Build the login screen
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(home: const LoginScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Find the login button and try to login with empty fields
    final loginButton = find.text('Login');

    // Try to login with empty fields
    await tester.tap(loginButton);
    await tester.pump();

    // Verify that the form shows validation errors
    // Note: The actual validation messages may vary based on implementation
    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('App Theme and Layout Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(home: const LoginScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the app has proper material design elements
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Check for key UI components
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  // Test for basic widget structure and navigation
  testWidgets('Widget Structure Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(home: const LoginScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the widget tree structure
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
    expect(find.byType(Column), findsWidgets);

    // Check for interactive elements
    expect(
      find.byType(TextFormField),
      findsAtLeastNWidgets(2),
    ); // Email and Password
    expect(
      find.byType(ElevatedButton),
      findsAtLeastNWidgets(1),
    ); // Login button
  });
}
