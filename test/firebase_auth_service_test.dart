import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spamdefender/global/common/toast.dart';
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';
import 'mocks.mocks.dart'; // Import generated mocks

void main() {
  late FirebaseAuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    authService = FirebaseAuthService(); // Your actual service
  });

  test('Sign up successfully returns a user', () async {
    when(mockFirebaseAuth.createUserWithEmailAndPassword(
      email: "test@example.com",
      password: "StrongPass123",
    )).thenAnswer((_) async => mockUserCredential);

    when(mockUserCredential.user).thenReturn(mockUser);

    final result = await authService.signUpWithEmailAndPassword("test@example.com", "StrongPass123");

    expect(result, equals(mockUser));
  });



}
