import 'package:flutter/material.dart';

// UI Screens
import 'sign_up.dart';
import 'log_in.dart';

// WELCOME TO SPAMDEFENDER (HOME) //
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
        canPop: false,  // Prevents back navigation
        child: Scaffold(
      backgroundColor: Color(0xFF050a30),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: -35,
            child: Image.asset(
              'images/yellowmainscreen.png',
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 70,
            left: 120,
            child: Image.asset(
              'images/welcometosd.png',
              width: MediaQuery.of(context).size.width * 0.55,
              height: MediaQuery.of(context).size.height * 0.5,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 90,
            left: 120,
            child: Image.asset(
              'images/startcleaning.png',
              width: MediaQuery.of(context).size.width * 0.30,
              height: MediaQuery.of(context).size.height * 0.5,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 370,
            left: 150,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF050a30),
                side: BorderSide(color: Color(0xFF050a30), width: 2),
                minimumSize: Size(200, 40),
              ),
              child: Text('LOG IN'),
            ),
          ),
          Positioned(
            top: 420,
            left: 150,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF050a30),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.white, width: 2),
                minimumSize: Size(200, 40),
              ),
              child: Text('SIGN UP'),
            ),
          ),
        ], // children
      ),
    ),
    );
  } // Widget build(BuildContext context)
} //class Home extends StatelessWidget
