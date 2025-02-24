// Firebase Implementation
import 'package:firebase_auth/firebase_auth.dart';

// Toast Notif
import 'package:spamdefender/global/common/toast.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {

    final List<String> failedEmailSignUpCriteria = [];
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

// Check if email matches the valid format
    if (!emailRegex.hasMatch(email)) {
      failedEmailSignUpCriteria.add(
          'Email must be in a valid format (e.g., test.email@example.com).');
    }


    // Must satisfy the following criterias:
    //   Regex:
    //   ^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{12,}$
    //
    //   Valid Passwords:
    //   StrongPass1!@#
    //   ComplexPwd2025$%
    //   MySecure#Password123
    //
    //   Invalid Passwords:
    //
    //   short1A!
    //   Issue: Less than 12 characters.
    //
    //   alllowercase123!
    //   Issue: Missing uppercase letter.
    //
    //   ALLUPPERCASE123!
    //   Issue: Missing lowercase letter.
    //
    //   NoNumbers!@#
    //   Issue: Missing digit.
    //
    //   NoSpecialChar123
    //   Issue: Missing special character.

    final List<String> failedPasswordSignUpCriteria = [];
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{12,}$');

    // Check password length
    if (password.length < 6) {
      failedPasswordSignUpCriteria.add('The password must be at least 6 characters long.');
    }
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      failedPasswordSignUpCriteria.add('The password must contain at least one uppercase letter.');
    }
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      failedPasswordSignUpCriteria.add('The password must contain at least one lowercase letter.');
    }
    // Check for at least one digit
    if (!RegExp(r'\d').hasMatch(password)) {
      failedPasswordSignUpCriteria.add('The password must contain at least one digit.');
    }
    // Check for at least one special character
    if (!passwordRegex.hasMatch(password)) {
      failedPasswordSignUpCriteria.add('The password must contain at least one special character.');
    }



    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use.');
      } else if (e.code == 'invalid-email' || failedEmailSignUpCriteria.isNotEmpty) {
        showToast(message: 'The email address is badly formatted.');
      } else if (e.code == 'weak-password' || failedPasswordSignUpCriteria.isNotEmpty ) {
        // For 6 characters long only
        showToast(message: 'The password is too weak.');
      } else if (e.code == 'network-request-failed') {
        showToast(
          message:
          'No network connection. Please connect to your internet and try again.',
          fontSize: 15.0,
        );
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }

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
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }
}
