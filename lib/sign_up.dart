// Flutter Dependencies
import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';

// UI Screens
import 'home_page.dart';
import 'log_in.dart';
import 'welcome.dart';

// Toast Notif
import 'package:spamdefender/global/common/toast.dart';

// Utils
import 'utils/validation.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  bool isButtonActive = false;
  bool _isSigning = false;
  bool _isPasswordVisible = false;
  String errorMessage = '';
  String _emailError = '';
  String _passwordError = '';

  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _pageController.dispose();
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
          // _passwordController.text.isNotEmpty &&
          // _confirmpasswordController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text == _confirmpasswordController.text &&
          ValidationUtils.validateEmail(_emailController.text).isEmpty &&
          ValidationUtils.validateUsername(_usernameController.text).isEmpty;
    });
    print('Entered Email: ${_emailController.text}');
    print('Entered Username: ${_usernameController.text}');
    print('Entered Password: ${_passwordController.text}');
    print('Entered Confirm Password: ${_confirmpasswordController.text}');
    print('Is Button Active: $isButtonActive');
  }

  void _presignUp() async {
    setState(() {
      _isSigning = true;
      _emailError = '';
    });

    String email = _emailController.text;
    String username = _usernameController.text;

    String firebaseAuthEmail = await _auth.signUpVerifyEmail(email);

    /* This condition is for email duplicates, successful
    if firebaseAuthEmail did not returned anything since we dont want to register the user yet*/
    if (firebaseAuthEmail == '') {
      // Proceed if email is not a duplicate
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _isSigning = false;
      });
    } else if (firebaseAuthEmail == 'network-request-failed') {
      showToast(
        message: 'No internet connection. Please try again later.',
        fontSize: 15,
      );
      setState(() {
        // Store the error message, to be used by validator
        _emailError = 'Network error';
        _isSigning = false;
      });
      return;
    } else {
      // Email is a duplicate
      setState(() {
        // Store the error message, to be used by validator
        _emailError = firebaseAuthEmail;
        _isSigning = false;
      });
      return;
    }
  }

  void _signUp() async {
    setState(() {
      _isSigning = true;
      _passwordError = '';
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    String firebaseAuthPassword = await _auth.signUpWithEmailAndPassword(
      email,
      password,
    );

    if (firebaseAuthPassword.isNotEmpty) {
      setState(() {
        errorMessage = firebaseAuthPassword;
        _isSigning = false;
      });
      return;
    } else {
      print("User successfully created");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    }
  } //_signUp

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents content shifting
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.10,
              left: MediaQuery.of(context).size.width * 0.15,
              right: MediaQuery.of(context).size.width * 0.15,
              child: Center(
                child: Image.asset(
                  'images/mainlogo.png',
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.1,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [_buildFirstPage(), _buildSecondPage()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return PopScope(
      canPop: true, // Prevents default back navigation
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          // Navigate back to the first page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        }
      },
      child: Stack(
        children: [
          Positioned(
            top: 230.0,
            left: 30.0,
            child: Text(
              'Create your Email and Username',
              style: TextStyle(
                color: Color(0xFF050a30),
                fontSize: 20,
                fontFamily: 'Mosafin',
              ),
            ),
          ),
          Positioned(
            top: 285.0,
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
            top: 320.0,
            left: 30.0,
            right: 30.0,
            child: TextFormField(
              key: Key('emailField'),
              controller: _emailController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Enter email',
                border: OutlineInputBorder(),
                errorStyle: TextStyle(fontSize: 9.0),
              ),
              validator: (value) {
                // Check for email duplicates
                if (_emailError.isNotEmpty) {
                  String error = _emailError; // save error message
                  _emailError = ''; // clear error message after use
                  return error;
                }

                // Handles email format
                final validationResult = ValidationUtils.validateEmail(
                  value ?? '',
                );
                if (validationResult.isEmpty) {
                  return null;
                } else {
                  return validationResult.join('');
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          Positioned(
            top: 460.0,
            left: 30.0,
            right: 30.0,
            child: TextFormField(
              key: Key('usernameField'),
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Enter username',
                border: OutlineInputBorder(),
                errorStyle: TextStyle(fontSize: 9.0),
              ),
              validator: (value) {
                // Handles username format
                final validationResult = ValidationUtils.validateUsername(
                  value ?? '',
                );
                if (validationResult.isEmpty) {
                  return null;
                } else {
                  return validationResult.join('');
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          Positioned(
            top: 430.0,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 170.0,
              ),
              child: OutlinedButton(
                onPressed:
                    (!_isSigning && isButtonActive)
                        ? () {
                          _presignUp();
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
                  minimumSize: Size(1000, 45),
                ),
                child:
                    _isSigning
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : Text('NEXT'),
              ),
            ),
          ),
          Positioned(
            top: 670,
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
                      decoration:
                          TextDecoration.underline, // Optional, for emphasis
                    ),
                  ),
                ),
              ],
            ),
          ),
        ], //children
      ),
    );
  }

  Widget _buildSecondPage() {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          // Clear passwords
          _passwordController.clear();
          _confirmpasswordController.clear();

          // Navigate back to the first page
          _pageController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Stack(
        children: [
          Positioned(
            top: 230.0,
            left: 30.0,
            child: Text(
              'Create your Password',
              style: TextStyle(
                color: Color(0xFF050a30),
                fontSize: 20,
                fontFamily: 'Mosafin',
              ),
            ),
          ),
          Positioned(
            top: 265.0,
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
          Positioned(
            top: 300.0,
            left: 30.0,
            right: 30.0,
            child: TextFormField(
              key: Key('passwordField'),
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Enter password',
                border: OutlineInputBorder(),
                errorStyle: TextStyle(fontSize: 9.0),
                errorMaxLines: 10,
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
              validator: (value) {
                if (_passwordError.isNotEmpty) {
                  String error = _passwordError;
                  _passwordError = '';
                  return error;
                }

                final validationResult = ValidationUtils.validatePassword(
                  value ?? '',
                );
                if (validationResult.isEmpty) {
                  return null;
                } else {
                  return 'Password must ${validationResult.join('')}';
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          Positioned(
            top: 430.0,
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
          Positioned(
            top: 465.0,
            left: 30.0,
            right: 30.0,
            child: TextFormField(
              key: Key('confirmpasswordField'),
              controller: _confirmpasswordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Confirm password',
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
              validator: (value) {

                bool passwordmatch =  _passwordController.text == _confirmpasswordController.text;
                if (passwordmatch) {
                  return null;
                } else {
                  return 'Password must match';
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 170.0,
              ),
              child: OutlinedButton(
                onPressed:
                    (!_isSigning && isButtonActive)
                        ? () {
                          _signUp();
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
                  minimumSize: Size(1000, 45),
                ),
                child:
                    _isSigning
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : Text('SIGN UP'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
