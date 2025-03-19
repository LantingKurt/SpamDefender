// Firebase Implementation
import 'package:firebase_auth/firebase_auth.dart';

// Toast Notif
import 'package:spamdefender/global/common/toast.dart';

// Utils
import 'package:spamdefender/utils/validation.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  Future<String> signUpVerifyEmail(String email) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: 'dummypassword',
      );

    } on FirebaseAuthException catch (e) {
      final failedEmailSignUpCriteria = ValidationUtils.validateEmail(email);
      if (e.code == 'email-already-in-use') {
        var message = 'The email address is already in use.';
        return message;
      } else if (e.code == 'invalid-email' ||
          failedEmailSignUpCriteria.isNotEmpty) {
        return failedEmailSignUpCriteria[0];
      } else {
        var message = e.code;
        return message;
      }
    } finally { /* If account creation succeeds, delete the test user
      since we want to create the user with the inputted password by the user*/
      User? user = FirebaseAuth.instance.currentUser;
      await user?.delete();
    }
    return ''; // Email was available
  }

  // Actual signing up
  Future<String> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return '';
    } on FirebaseAuthException catch (e) {
      final failedPasswordSignUpCriteria = ValidationUtils.validatePassword(
        password,
      );
      if (e.code == 'weak-password' ||
          failedPasswordSignUpCriteria.isNotEmpty) {
        return failedPasswordSignUpCriteria[0];
      } else if (e.code == 'network-request-failed') {
        var message = 'No internet connection. Please try again later.';
        return message;
      } else {
        var message = 'An error occurred: ${e.code}';
        return message;
      }
    }
  }

  // Login
  Future<User?> signinWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'invalid-credential') {
        // Invalid email or password
        showToast(message: 'Invalid email or password. Please try again.');
      } else if (e.code == 'invalid-email') {
        showToast(
          message: 'Wrong email format. Please try again.',
          fontSize: 15,
        );
      } else if (e.code == 'user-disabled') {
        // if user disabled on Firebase console
        showToast(
          message:
              'The user account has been disabled. Reach out to your administrator and try again.',
        );
      } else if (e.code == 'network-request-failed') {
        showToast(
          message:
              'No network connection. Please connect to your internet and try again.',
          fontSize: 15,
        );
      }
      else if (e.code == 'too-many-requests') {
        showToast(
          message:
          'Too many requests. Please try again later.',
          fontSize: 15,
        );
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }
}
