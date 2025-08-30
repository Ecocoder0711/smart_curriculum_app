// This is a basic Flutter widget test for Smart Curriculum App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_curriculum_app/main.dart';
import 'package:smart_curriculum_app/providers/auth_provider.dart';

void main() {
  testWidgets('Smart Curriculum App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: const SmartCurriculumApp(),
      ),
    );

    // Wait for the splash screen animation to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that we can find the login screen elements
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to your account'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login form validation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: const SmartCurriculumApp(),
      ),
    );

    // Wait for the splash screen to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Try to tap login without entering any data
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify that validation errors appear
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Navigation to register screen test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: const SmartCurriculumApp(),
      ),
    );

    // Wait for the splash screen to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Tap on "Sign Up" link
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify that we're on the register screen
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Join Smart Curriculum'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Role'), findsOneWidget);
  });
}
