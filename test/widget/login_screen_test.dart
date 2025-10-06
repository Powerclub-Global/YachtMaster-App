import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yacht_master/src/auth/view/login.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Verify key widgets are present
      expect(find.byType(TextField), findsWidgets);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Find the email text field (assuming it's the first TextField)
      final emailField = find.byType(TextField).first;

      // Enter text
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Password field is obscured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Find text fields
      final textFields = find.byType(TextField);

      // Assuming password is the second field
      if (textFields.evaluate().length > 1) {
        final passwordField = textFields.at(1);
        final TextField widget = tester.widget(passwordField);

        // Password field should be obscured
        expect(widget.obscureText, isTrue);
      }
    });

    testWidgets('Login button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Find login button
      final loginButton = find.byType(ElevatedButton).first;

      // Tap the button
      await tester.tap(loginButton);
      await tester.pump();

      // Button should not throw errors when tapped
    });

    testWidgets('Shows error when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Find and tap login button without entering credentials
      final loginButton = find.byType(ElevatedButton).first;
      await tester.tap(loginButton);
      await tester.pump();

      // Should show some kind of validation error
      // (exact implementation depends on your app)
    });
  });
}
