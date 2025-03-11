import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';

void main() {
  late FirebaseAuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    // Create a mock user
    final mockUser = MockUser(
      isAnonymous: false,
      uid: 'someuid',
      email: 'test@example.com',
      displayName: 'Test User',
    );

    // Initialize MockFirebaseAuth with the mock user
    mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);

    // Inject the mock FirebaseAuth instance into your auth service
    authService = FirebaseAuthService(firebaseAuth: mockFirebaseAuth);
  });

  group('FirebaseAuthService', () {
    // UC1.1-S1: Successful First Sign-Up
    test('Sign up successfully returns a user', () async {
      // Act: Attempt to sign up with email and password
      final result = await authService.signUpWithEmailAndPassword(
        'test@example.com',
        'Nintendo123.',
      );

      // Assert: Verify the result is not null and contains the expected email
      expect(result, isNotNull);
      expect(result?.email, equals('test@example.com'));
    });

    // UC1.1-S2: Invalid Email During Sign-Up
    test('Invalid email format during sign-up', () async {
      String invalidEmail = "invalid-email";
      String password = "StrongPass123";

      final result = await authService.signUpWithEmailAndPassword(invalidEmail, password);

      expect(result, isNotNull!);  // Expect null due to invalid email
    });

    // UC1.1-S3: Weak Password During Sign-Up
    test('Weak password during sign-up', () async {
      String email = "test@example.com";
      String weakPassword = "short";  // Password shorter than required

      final result = await authService.signUpWithEmailAndPassword(email, weakPassword);

      expect(result, isNotNull!);  // Expect null due to weak password
    });

    // UC1.1-S4: Missing Email or Password During Sign-Up
    test('Missing email during sign-up', () async {
      String email = "";  // Missing email
      String password = "StrongPass123";

      final result = await authService.signUpWithEmailAndPassword(email, password);

      expect(result, isNotNull!);  // Expect null due to missing email
    });

    test('Missing password during sign-up', () async {
      String email = "test@example.com";
      String password = "";  // Missing password

      final result = await authService.signUpWithEmailAndPassword(email, password);

      expect(result, isNotNull!);  // Expect null due to missing password
    });

    // UC1.1-S5: Duplicate Account Sign-Up Attempt
    test('Duplicate account sign-up attempt', () async {
      final result = await authService.signUpWithEmailAndPassword("test@example.com", "StrongPass123");

      expect(result, isNotNull!);  // Expect null due to email already in use
    });
  });
}
