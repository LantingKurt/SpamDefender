import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spam_defender/main.dart';

void main() {
  testWidgets('Splash screen navigates to Home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Splash()), // Start from the splash screen
    );

    // Verify splash screen is displayed
    expect(find.byType(Splash), findsOneWidget);

    // Simulate splash delay and ensure transition completes
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify Home screen is displayed
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('Home screen contains login and sign-up buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    await tester.pumpAndSettle();

    // Verify login and sign-up buttons exist
    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);
  });

  testWidgets('Home navigates to Login Screen when Log In is clicked', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    await tester.pumpAndSettle();

    // Tap the LOG IN button
    await tester.tap(find.text('LOG IN'));
    await tester.pumpAndSettle();

    // Verify that LoginScreen is now displayed
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Login screen - Successful login navigates to HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    await tester.pumpAndSettle();

    // Find username and password fields by their keys
    final Finder usernameField = find.byKey(Key('usernameField'));
    final Finder passwordField = find.byKey(Key('passwordField'));

    // Ensure the fields are found before interacting
    expect(usernameField, findsOneWidget);
    expect(passwordField, findsOneWidget);

    // Enter correct username and password
    await tester.enterText(usernameField, 'admin1');
    await tester.pump();
    await tester.enterText(passwordField, 'password123');
    await tester.pump();

    // Tap login button
    await tester.tap(find.text('LOG IN'));
    await tester.pumpAndSettle();

    // Verify HomeScreen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Login screen - Invalid Username error upon invalid login', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    await tester.pumpAndSettle();

    // Find username and password fields by their keys
    final Finder usernameField = find.byKey(Key('usernameField'));
    final Finder passwordField = find.byKey(Key('passwordField'));

    // Ensure the fields are found before interacting
    expect(usernameField, findsOneWidget);
    expect(passwordField, findsOneWidget);

    // Enter incorrect username and correct password
    await tester.enterText(usernameField, 'wrong_user');
    await tester.pump();
    await tester.enterText(passwordField, 'password123');
    await tester.pump();

    // Tap login button
    await tester.tap(find.text('LOG IN'));
    await tester.pumpAndSettle();

    // Verify error message appears
    expect(find.textContaining('Invalid username'), findsOneWidget);
  });

  testWidgets('Login screen - Invalid Password error upon valid username', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    await tester.pumpAndSettle();

    // Find username and password fields by their keys
    final Finder usernameField = find.byKey(Key('usernameField'));
    final Finder passwordField = find.byKey(Key('passwordField'));

    // Ensure the fields are found before interacting
    expect(usernameField, findsOneWidget);
    expect(passwordField, findsOneWidget);

    // Enter correct username and incorrect password
    await tester.enterText(usernameField, 'admin1');
    await tester.pump();
    await tester.enterText(passwordField, 'wrong_password');
    await tester.pump();

    // Tap login button
    await tester.tap(find.text('LOG IN'));
    await tester.pumpAndSettle();

    // Verify error message appears
    expect(find.textContaining('Invalid password'), findsOneWidget);
  });

  testWidgets('Login button is initially disabled when username and password are empty', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    await tester.pumpAndSettle();

    // Find the login button
    final Finder loginButton = find.byType(OutlinedButton);

    // Verify that the button is disabled (i.e., onPressed is null)
    final OutlinedButton button = tester.widget(loginButton);
    expect(button.onPressed, isNull);
  });

  testWidgets('Login button is disabled when password is empty', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginScreen()));

  await tester.pumpAndSettle();

  // Find the username and password fields by their keys
  final Finder usernameField = find.byKey(Key('usernameField'));
  final Finder passwordField = find.byKey(Key('passwordField'));

  // Ensure the fields are found before interacting
  expect(usernameField, findsOneWidget);
  expect(passwordField, findsOneWidget);

  // Enter text in the username field but leave the password field empty
  await tester.enterText(usernameField, 'admin1');
  await tester.pump();

  // Find the login button
  final Finder loginButton = find.byType(OutlinedButton);

  // Verify that the button is disabled (i.e., onPressed is null) because password is empty
  final OutlinedButton button = tester.widget(loginButton);
  expect(button.onPressed, isNull);
});


  testWidgets('Login button is enabled when username and password are provided', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    await tester.pumpAndSettle();

    // Find username and password fields by their keys
    final Finder usernameField = find.byKey(Key('usernameField'));
    final Finder passwordField = find.byKey(Key('passwordField'));

    // Enter text in both username and password fields
    await tester.enterText(usernameField, 'admin1');
    await tester.pump();
    await tester.enterText(passwordField, 'password123');
    await tester.pump();

    // Find the login button
    final Finder loginButton = find.byType(OutlinedButton);

    // Verify that the button is enabled when both fields are filled
    final OutlinedButton button = tester.widget(loginButton);
    expect(button.onPressed, isNotNull);
  });
}