// Firebase Implementation
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Toast Notif
import 'package:spamdefender/global/common/toast.dart';

import 'package:spamdefender/sign_up.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use.');
      } else if (e.code == 'invalid-email') {
        showToast(message: 'The email address is badly formatted.');
      } else if (e.code == 'weak-password') {
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
