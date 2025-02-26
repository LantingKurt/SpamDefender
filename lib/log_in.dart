// Flutter Dependencies
import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';

// UI Screens
import 'home_page.dart';
import 'welcome.dart';

// LOG IN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool isButtonActive = false;
  bool _isLoggingin = false;
  bool _isPasswordVisible = false;
  String errorMessage = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkButtonState);
  }

  void _checkButtonState() {
    setState(() {
      isButtonActive = _passwordController.text.isNotEmpty;
    });
  }

  void _handleLogin() {
    setState(() {
      errorMessage = '';
    });
    _login();
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
        resizeToAvoidBottomInset: false,
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
              Positioned(
                top: 290,
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
              Positioned(
                top: 320,
                left: 30.0,
                right: 30.0,
                child: TextField(
                  key: Key('usernameField'),
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (value) {
                    if (isButtonActive) _handleLogin();
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Positioned(
                top: 400.0,
                left: 30.0,
                right: 30.0,
                child: Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFF050a30),
                    fontSize: 15,
                    fontFamily: 'Mosafin',
                  ),
                ),
              ),
              Positioned(
                top: 430.0,
                left: 30.0,
                right: 30.0,
                child: TextField(
                  key: Key('passwordField'),
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  onSubmitted: (value) {
                    if (isButtonActive) _handleLogin();
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 485.0, left: 20.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isPasswordVisible,
                        onChanged: (bool? value) {
                          setState(() {
                            _isPasswordVisible = value ?? false;
                          });
                        },
                      ),
                      Text('Show Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Mosafin',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 205.0, right: 30.0),
                  child: Text(
                  'Forget password?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Mosafin',
                  ),
                  ),
                ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 200.0,
                  ),
                  child: OutlinedButton(
                    onPressed: isButtonActive ? _handleLogin : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isButtonActive ? Colors.white : Colors.grey,
                      backgroundColor:
                          isButtonActive ? Color(0xFF050a30) : Colors.grey[400],
                      side: BorderSide(color: Color(0xFF050a30)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(
                        double.infinity,
                        50,
                      ), // Full width button
                    ),
                    child:
                        _isLoggingin
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : Text('LOG IN'),
                  ),
                ),
              ),
              if (errorMessage.isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 150.0),
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  // LOG IN FIREBASE
  void _login() async {
    setState(() {
      _isLoggingin = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signinWithEmailAndPassword(email, password);

    setState(() {
      _isLoggingin = false;
    });

    if (user != null) {
      print("User successfully logged in");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      print("User log in failed");
      setState(() {
        errorMessage = 'Login failed. Please try again.';
      });
    }
  }
}
