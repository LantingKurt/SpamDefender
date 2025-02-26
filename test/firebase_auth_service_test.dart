import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
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
  });
}
