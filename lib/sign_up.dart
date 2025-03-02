// Flutter Dependencies
import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';

// UI Screens
import 'welcome.dart';
import 'home_page.dart';

// login page
import 'log_in.dart';

import 'validation_utils.dart';

// SIGN UP //
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  bool isButtonActive = false;
  bool _isSigning = false;
  String errorMessage = '';

  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmpasswordController = TextEditingController();

    _emailController.addListener(_checkButtonState);
    _usernameController.addListener(_checkButtonState);
    _passwordController.addListener(_checkButtonState);
    _confirmpasswordController.addListener(_checkButtonState);
  }

  void _checkButtonState() {
    setState(() {
      isButtonActive =
          _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmpasswordController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text == _confirmpasswordController.text;

      if (_passwordController.text != _confirmpasswordController.text) {
        errorMessage = 'Passwords do not match';
      } else {
        errorMessage = '';
      }
    });
  }

  void _handleSignUp() {
        setState(() {
      _isSigning = true;
      errorMessage = ''; // Clear any previous error messages
    });

    String enteredEmail = _emailController.text;
    String enteredUsername = _usernameController.text;
    String enteredPassword = _passwordController.text;
    String confirmedPassword = _confirmpasswordController.text;

    if (enteredPassword != confirmedPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
    } 

    final failedEmailSignUpCriteria = ValidationUtils.validateEmail(enteredEmail);
    final failedUsernameSignUpCriteria = ValidationUtils.validateUsername(enteredUsername);
    final failedPasswordSignUpCriteria = ValidationUtils.validatePassword(enteredPassword);
    if (failedEmailSignUpCriteria.isNotEmpty) {
      setState(() {
        errorMessage = [
          'Sign up failed. Please try again.',
          '',
          ...failedEmailSignUpCriteria,
        ].join('\n');
        _isSigning = false; // Stop the spinner
      });
      return;
    }

    if (failedUsernameSignUpCriteria.isNotEmpty) {
      setState(() {
        errorMessage = [
          'Sign up failed. Please try again.',
          '',
          ...failedUsernameSignUpCriteria,
        ].join('\n');
        _isSigning = false; // Stop the spinner
      });
      return;
    }

    if (failedPasswordSignUpCriteria.isNotEmpty) {
      setState(() {
        errorMessage = [
          'Sign up failed. Please try again.\n',
          'The password must',
          ...failedPasswordSignUpCriteria,
          '.'
        ].join(' ');
        _isSigning = false; // Stop the spinner
      });
      return;
    }

    _signUp();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents default back navigation
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Prevents content shifting
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -330,
                left: 87,
                child: Image.asset(
                  'images/mainlogo.png',
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 220.0 - 50,
                left: 30.0,
                child: Text(
                  'Create your Account',
                  style: TextStyle(
                    color: Color(0xFF050a30),
                    fontSize: 20,
                    fontFamily: 'Mosafin',
                  ),
                ),
              ),
              // Email Label
              Positioned(
                top: 255 - 50,
                left: 30.0,
                child: Text(
                  'Email',
                  style: TextStyle(
                    color: Color(0xFF050a30),
                    fontSize: 15,
                    fontFamily: 'Mosafin',
                  ),
                ),
              ),
              // Email TextField
              Positioned(
                top: 280 - 50,
                left: 30.0,
                right: 30.0,
                child: TextField(
                  key: Key('emailField'),
                  // Added key here
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (value) {
                    if (isButtonActive) _handleSignUp();
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // Username Label
              Positioned(
                top: 350 - 50,
                left: 30.0,
                child: Text(
                  'Username',
                  style: TextStyle(
                    color: Color(0xFF050a30),
                    fontSize: 15,
                    fontFamily: 'Mosafin',
                  ),
                ),
              ),
              // Username TextField
              Positioned(
                top: 375 - 50,
                left: 30.0,
                right: 30.0,
                child: TextField(
                  key: Key('usernameField'),
                  // Added key here
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (value) {
                    if (isButtonActive) _handleSignUp();
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter username',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // Password Label
              Positioned(
                top: 440.0 - 50,
                left: 30.0,
                child: Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFF050a30),
                    fontSize: 15,
                    fontFamily: 'Mosafin',
                  ),
                ),
              ),
              // Password TextField
              Positioned(
                top: 470.0 - 50,
                left: 30.0,
                right: 30.0,
                child: TextField(
                  key: Key('passwordField'),
                  // Added key here
                  controller: _passwordController,
                  obscureText: true,
                  onSubmitted: (value) {
                    if (isButtonActive) _handleSignUp();
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // Confirm Password Label
              Positioned(
                top: 540.0 - 50,
                left: 30.0,
                child: Text(
                  'Confirm password',
                  style: TextStyle(
                    color: Color(0xFF050a30),
                    fontSize: 15,
                    fontFamily: 'Mosafin',
                  ),
                ),
              ),
              // Confirm Password TextField
              Positioned(
                top: 565.0 - 50,
                left: 30.0,
                right: 30.0,
                child: TextField(
                  key: Key('confirmpasswordField'),
                  // Added key here
                  controller: _confirmpasswordController,
                  obscureText: true,
                  onSubmitted: (value) {
                    if (isButtonActive) _handleSignUp();
                  },
                  decoration: InputDecoration(
                    hintText: 'Confirm password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // Sign-Up Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 170.0,
                  ),
                  child: OutlinedButton(
                    onPressed:
                        isButtonActive
                            ? () {
                              _handleSignUp();
                            }
                            : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isButtonActive ? Colors.white : Colors.grey,
                      backgroundColor:
                          isButtonActive ? Color(0xFF050a30) : Colors.grey[400],
                      side: BorderSide(color: Color(0xFF050a30)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(1000, 45),
                    ),
                    child:
                        _isSigning
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : Text('SIGN UP'),
                  ),
                ),
              ),
              Positioned(
                top: 610,
                left: 75.0,
                child: Row(
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Color(0xFF050a30),
                        fontSize: 15,
                        fontFamily: 'Mosafin',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle the login button tap here
                        // print('Login button pressed!');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue, // Make it look like a button
                          fontSize: 15,
                          fontFamily: 'Mosafin',
                          decoration: TextDecoration.underline, // Optional, for emphasis
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Error message display
              if (errorMessage.isNotEmpty)
                Positioned(
                  bottom: 25.0,
                  left: 10.0,
                  right: 10.0,
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // SIGN UP FIREBASE
  void _signUp() async {
    setState(() {
      _isSigning = true;
      errorMessage = ''; // Clear any previous error messages
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;


    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      print("User successfully created");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      print("User sign up failed");
      setState(() {
        errorMessage = 'Sign up failed. Please try again.';
         _isSigning = false;
      });
    }

  }
}
