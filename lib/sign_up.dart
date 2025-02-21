import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';

// SIGN UP //
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  bool isButtonActive = false;
  String errorMessage = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final Map<String, String> userDatabase = {};

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    confirmpasswordController = TextEditingController();

    emailController.addListener(_checkButtonState);
    usernameController.addListener(_checkButtonState);
    passwordController.addListener(_checkButtonState);
    confirmpasswordController.addListener(_checkButtonState);
  }

  void _checkButtonState() {
    setState(() {
      isButtonActive =
          usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          confirmpasswordController.text.isNotEmpty &&
          emailController.text.isNotEmpty;
    });
  }

  void _handleSignUp() {
    String enteredEmail = emailController.text;
    String enteredUsername = usernameController.text;
    String enteredPassword = passwordController.text;
    String confirmedPassword = confirmpasswordController.text;

    if (enteredPassword != confirmedPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
    } else {
      setState(() {
        if (userDatabase.containsKey(enteredEmail)) {
          errorMessage = 'Email already exists';
        } else if (userDatabase.containsKey(enteredUsername)) {
          errorMessage = 'Username already exists';
        } else {
          userDatabase[enteredUsername] = enteredPassword;
          errorMessage = 'Signed up';
          print('signed in user:');
          print(userDatabase);
          _signUp();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            // Username Label
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

            // Username TextField
            Positioned(
              top: 280,
              left: 35.0,
              right: 30.0,
              child: TextField(
                key: Key('emailField'),
                // Added key here
                controller: emailController,
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
            Positioned(
              top: 375,
              left: 35.0,
              right: 30.0,
              child: TextField(
                key: Key('usernameField'),
                // Added key here
                controller: usernameController,
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
              left: 35.0,
              right: 30.0,
              child: TextField(
                key: Key('passwordField'),
                // Added key here
                controller: passwordController,
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

            // Password TextField
            Positioned(
              top: 565.0,
              left: 35.0,
              right: 30.0,
              child: TextField(
                key: Key('passwordField'),
                // Added key here
                controller: confirmpasswordController,
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
            Positioned(
              bottom: 60.0,
              left: 60.0,
              right: 60.0,
              child: OutlinedButton(
                onPressed:
                    isButtonActive
                        ? () {
                          _handleSignUp();
                        }
                        : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isButtonActive ? Colors.white : Colors.grey,
                  backgroundColor:
                      isButtonActive ? Color(0xFF050a30) : Colors.grey[400],
                  side: BorderSide(color: Color(0xFF050a30)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(100, 45),
                ),
                child: Text('SIGN UP'),
              ),
            ),

            // Error message display
            if (errorMessage.isNotEmpty)
              Positioned(
                bottom: 30.0,
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
    );
  }

  // FUNCTION FOR SIGNING UP USER
  void _signUp() async {
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      print("User is successfully created");
    } else {
      print("User sign up failed");
    }
  } // _signUp
} // _SignupScreenState
