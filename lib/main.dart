import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'my_textfield.dart';
import 'my_button.dart';

 void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      }
    );
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
              child: Image.asset('images/yellowmainscreen.png', width: MediaQuery.of(context).size.width * 0.95, height: MediaQuery.of(context).size.height, fit: BoxFit.contain),
            ),
            Positioned(
              top: -100,
              left: 0,
              child: Image.asset('images/graymainscreen.png', width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, fit: BoxFit.contain),
            ),
            Positioned(
              top: 60,
              left: 60,
              child: Image.asset('images/mainlogo.png', width: MediaQuery.of(context).size.width * 0.7, height: MediaQuery.of(context).size.height * 0.7, fit: BoxFit.contain),
            ),
          ],
        ),
      );
    }
  }

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xFF050a30),
      body: Stack(
        children: [
      Positioned(
        top: 0,
        right: -35,
        child: Image.asset('images/yellowmainscreen.png', width: MediaQuery.of(context).size.width * 0.95, height: MediaQuery.of(context).size.height, fit: BoxFit.contain),
      ),
      Positioned(
        top: 70,
        left: 120,
        child: Image.asset('images/welcometosd.png', width: MediaQuery.of(context).size.width * 0.55, height: MediaQuery.of(context).size.height * 0.5, fit: BoxFit.contain),
      ),
      Positioned(
        top: 90,
        left: 120,
        child: Image.asset('images/startcleaning.png', width: MediaQuery.of(context).size.width * 0.30, height: MediaQuery.of(context).size.height * 0.5, fit: BoxFit.contain),
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
            side: BorderSide(color: Color(0xFF050a30), width: 2 ),
            minimumSize: Size (200, 40),
             ),
            child: Text('LOG IN'),
        ),
      ),
      Positioned(
        top: 420,
        left: 150,
        child: OutlinedButton(
          onPressed: () {},

           style: OutlinedButton.styleFrom(
           foregroundColor: Color(0xFF050a30),
           backgroundColor: Colors.white,
           side: BorderSide(color: Colors.white, width: 2 ),
           minimumSize: Size (200, 40),
           ),
           child: Text('SIGN UP'),
        ),
      ),
     ]
    ),
   );
  }

 }



class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isButtonActive = false;
  String errorMessage = '';

  late TextEditingController usernameController;
  late TextEditingController passwordController;

  final String correctUsername = 'admin';
  final String correctPassword = 'password123';

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
      isButtonActive = usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  void _handleLogin() {
    String enteredUsername = usernameController.text;
    String enteredPassword = passwordController.text;

    if (enteredUsername != correctUsername) {
      setState(() {
        errorMessage = 'Invalid account';
      });
    }
    else if (enteredPassword != correctPassword) {
      setState(() {
        errorMessage = 'Invalid password';
      });
    }
    else {
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [

            // Sign-In Button
            Positioned(
              bottom: 200.0,
              left: 60.0,
              right: 60.0,
              child: OutlinedButton(
                onPressed: isButtonActive
                    ? () {
                  _handleLogin();
                }
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isButtonActive ? Colors.white : Colors.grey,
                  backgroundColor: isButtonActive ? Color(0xFF050a30) : Colors.grey[400],
                  side: BorderSide(color: Color(0xFF050a30)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(100, 45),
                ),
                child: Text('LOG IN'),
              ),
            ),

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



  class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF070056),
      body: Stack(
          children: [
            Positioned(
              top: 120,
              right: 0,
              child: Image.asset(
                  'images/whitebg.png', width: MediaQuery
                  .of(context)
                  .size
                  .width, height: MediaQuery
                  .of(context)
                  .size
                  .height, fit: BoxFit.contain),
            ),
            Positioned(
              top: -50,
              left: 20,
              child: Image.asset('images/search.png', width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.55, height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.5, fit: BoxFit.contain),
            ),
            Positioned(
              bottom: -380,
              left: 0,
              child: Image.asset('images/minibar.png', width: MediaQuery
                  .of(context)
                  .size
                  .width , height: MediaQuery
                  .of(context)
                  .size
                  .height , fit: BoxFit.contain),
            ),

            Positioned(
              top: -80,
              left: 12,
              child: Image.asset('images/allmessages.png', width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.95 , height: MediaQuery
                  .of(context)
                  .size
                  .height , fit: BoxFit.contain),
            ),
            Positioned(
              top: 345,
              left: 12,
              child: Image.asset('images/safemessages.png', width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.30 , height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.4, fit: BoxFit.contain),
            ),
          ]
      ),
    );
  }
}


















