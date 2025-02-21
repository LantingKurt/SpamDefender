import 'package:flutter/material.dart';
import 'welcome.dart';

// SPLASH //
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            top: -100,
            left: 0,
            child: Image.asset(
              'images/graymainscreen.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 60,
            left: 60,
            child: Image.asset(
              'images/mainlogo.png',
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.7,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  } // Widget build(BuildContext context)
} //_SplashState
