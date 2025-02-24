// Flutter Dependencies
import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';

// UI Screens
import 'welcome.dart';
import 'home_page.dart';

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
          _emailController.text.isNotEmpty;
    });
  }

  void _handleSignUp() {
    String enteredEmail = _emailController.text;
    String enteredUsername = _usernameController.text;
    String enteredPassword = _passwordController.text;
    String confirmedPassword = _confirmpasswordController.text;

    if (enteredPassword != confirmedPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
    } else {
      _signUp();
    }
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
                top: -300,
                left: 87,
                child: Image.asset(
                  'images/mainlogo.png',
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 220.0,
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
                top: 255,
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
                top: 280,
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
                top: 350,
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
                top: 375,
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
                top: 440.0,
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
                top: 470.0,
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
                top: 540.0,
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
                top: 565.0,
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
                    vertical: 120.0,
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
              // Error message display
              if (errorMessage.isNotEmpty)
                Positioned(
                  bottom: 70.0,
                  left: 60.0,
                  right: 60.0,
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

    // Wrong email format
    // Regex:
    // ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
    //
    // Accepted:
    // ✔ test.email@example.com
    // ✔ user.name+tag@sub.domain.co.uk
    // ✔ 123456789@domain.io
    // ✔ first.last@company.org
    // ✔ email@hyphen-domain.com
    //
    // Rejected:
    // ❌ plainaddress (No @)
    // ❌ @missingusername.com (Missing username)
    // ❌ user@.com (Invalid domain)
    // ❌ user@domain (No top-level domain)
    // ❌ user@domain..com (Double dot issue)

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

    if (failedPasswordSignUpCriteria.isNotEmpty || failedEmailSignUpCriteria.isNotEmpty){
      setState(() {
        errorMessage = [
          ...failedEmailSignUpCriteria,
          ...failedPasswordSignUpCriteria,
        ].join('\n');
        _isSigning = false; // Stop the spinner
      });
      return;
    }

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      print("User is successfully created");
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
      });
    }
    setState(() {
      _isSigning = false;
    });
  }
}
