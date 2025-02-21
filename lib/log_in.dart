import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';

// UI Screens
import 'home_page.dart';

// LOG IN //
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isButtonActive = false;
  String errorMessage = '';

  late TextEditingController usernameController;
  late TextEditingController passwordController;

  final Map<String, String> userDatabase = {
    'admin1': 'password123',
    'admin2': 'password456',
    'admin3': 'password789',
  };

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController();
    passwordController = TextEditingController();

    usernameController.addListener(_checkButtonState);
    passwordController.addListener(_checkButtonState);
  }

  void _checkButtonState() {
    setState(() {
      isButtonActive =
          usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  void _handleLogin() {
    String enteredUsername = usernameController.text;
    String enteredPassword = passwordController.text;

    // Check if the entered username exists and the password matches
    if (!userDatabase.containsKey(enteredUsername)) {
      setState(() {
        errorMessage = 'Invalid username';
      });
    } else if (userDatabase[enteredUsername] != enteredPassword) {
      setState(() {
        errorMessage = 'Invalid password';
      });
    } else {
      setState(() {
        errorMessage = '';
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
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
              top: 250.0,
              left: 30.0,
              child: Text(
                'Log in to your Account',
                style: TextStyle(
                  color: Color(0xFF050a30),
                  fontSize: 20,
                  fontFamily: 'Mosafin',
                ),
              ),
            ),

            // Username Label
            Positioned(
              top: 290,
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
              top: 320,
              left: 35.0,
              right: 30.0,
              child: TextField(
                key: Key('usernameField'),
                // Added key here
                controller: usernameController,
                textInputAction: TextInputAction.next,
                onSubmitted: (value) {
                  if (isButtonActive) _handleLogin();
                },
                decoration: InputDecoration(
                  hintText: 'Enter username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Password Label
            Positioned(
              top: 400.0,
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
              top: 430.0,
              left: 35.0,
              right: 30.0,
              child: TextField(
                key: Key('passwordField'),
                // Added key here
                controller: passwordController,
                obscureText: true,
                onSubmitted: (value) {
                  if (isButtonActive) _handleLogin();
                },
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Positioned(
              top: 410.0,
              right: 35.0,
              child: Text(
                'Forget password?',
                style: TextStyle(
                  color: Color(0xffffffff),
                  fontSize: 15,
                  fontFamily: 'Mosafin',
                ),
              ),
            ),

            // Sign-In Button
            Positioned(
              bottom: 200.0,
              left: 60.0,
              right: 60.0,
              child: OutlinedButton(
                onPressed:
                    isButtonActive
                        ? () {
                          _handleLogin();
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
                child: Text('LOG IN'),
              ),
            ),

            // Error message display
            if (errorMessage.isNotEmpty)
              Positioned(
                bottom: 140.0,
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
}
