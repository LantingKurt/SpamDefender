import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {  const MyApp({super.key});
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


// HOME //


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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },

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



// SIGN UP //


class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isButtonActive = false;
  String errorMessage = '';

  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController confirmpasswordController;

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
      isButtonActive = usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          confirmpasswordController.text.isNotEmpty &&
          emailController.text.isNotEmpty;
    });
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  bool _isValidPassword(String password, String username) {
    if (password.length < 12) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#\$%\^&\*\(\)_\+\-=,./<>?;:|{}]'));

    bool isValid = (hasUppercase ? 1 : 0) +
        (hasLowercase ? 1 : 0) +
        (hasDigits ? 1 : 0) +
        (hasSpecialChars ? 1 : 0) >=
        3;

    if (password.contains(username)) return false;

    return isValid;
  }

  void _handleSignUp() {
    String enteredEmail = emailController.text;
    String enteredUsername = usernameController.text;
    String enteredPassword = passwordController.text;
    String confirmedPassword = confirmpasswordController.text;

    if (!_isValidEmail(enteredEmail)) {
      setState(() {
        errorMessage = 'Invalid email format';
      });
    } else if (enteredPassword != confirmedPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
    } else if (!_isValidPassword(enteredPassword, enteredUsername)) {
      setState(() {
        errorMessage = 'Weak password format.';
      });
    } else {
      setState(() {
        if (userDatabase.containsKey(enteredEmail)) {
          errorMessage = 'Email already exists';
        } else if (userDatabase.containsKey(enteredUsername)) {
          errorMessage = 'Username already exists';
        } else {
          userDatabase[enteredUsername] = enteredPassword;
          errorMessage = '';
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
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
              child: Image.asset('images/mainlogo.png', width: MediaQuery.of(context).size.width * 0.6, height: MediaQuery.of(context).size.height, fit: BoxFit.contain),
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
                key: Key('emailField'), // Added key here
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
                key: Key('usernameField'), // Added key here
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
                key: Key('passwordField'), // Added key here
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
                key: Key('passwordField'), // Added key here
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
              bottom: 70.0,
              left: 60.0,
              right: 60.0,
              child: OutlinedButton(
                onPressed: isButtonActive
                    ? () {
                  _handleSignUp();
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
}




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
      isButtonActive = usernameController.text.isNotEmpty &&
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
    }
    else if (userDatabase[enteredUsername] != enteredPassword) {
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
      resizeToAvoidBottomInset: false, // Prevents content shifting
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -300,
              left: 87,
              child: Image.asset('images/mainlogo.png', width: MediaQuery.of(context).size.width * 0.6, height: MediaQuery.of(context).size.height, fit: BoxFit.contain),
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
                key: Key('usernameField'), // Added key here
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
                key: Key('passwordField'), // Added key here
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
              top: -85,
              left: 20,
              child: Image.asset('images/search.png', width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.55, height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.55, fit: BoxFit.contain),
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
              top: -90,
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
              top: 100,
              left: 12,
              child: Image.asset('images/spammessages.png', width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.45 , height: MediaQuery
                  .of(context)
                  .size
                  .height , fit: BoxFit.contain),
            ),
            Positioned(
              top: 20,
              right: 12,
              child: Image.asset('images/safemessages.png', width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.45 , height: MediaQuery
                  .of(context)
                  .size
                  .height * 1.3 , fit: BoxFit.contain),
            ),
            Positioned(
              bottom: 5,
              right: 50,
              child: IconButton(
                icon: Icon(
                  Icons.bookmark_border

                  ,
                  color: Colors.white,
                  size: 40.0,
                ),
                onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WhitelistScreen()),
                );
              },
              ),
            ),
          ]
      ),
    );
  }
}

class WhitelistScreen extends StatefulWidget {
  @override
  _WhitelistScreenState createState() => _WhitelistScreenState();
}

class _WhitelistScreenState extends State<WhitelistScreen> {
  final List<Map<String, String>> whitelist = [
    {'name': 'Elle', 'phone': '123-456-7890'},
    {'name': 'Kurt', 'phone': '987-654-3210'},
    {'name': 'Wana', 'phone': '555-123-4567'},
    {'name': 'Anton', 'phone': '444-234-5678'},
    {'name': 'Rei Germar', 'phone': '333-345-6789'},
    {'name': 'Ella Gatchalian', 'phone': '222-456-7891'},
    {'name': 'Lily Cruz', 'phone': '112-567-8901'},
    {'name': 'Mica Millano', 'phone': '113-567-8901'},
    {'name': 'Andrea Brillantes', 'phone': '114-567-8901'},
    {'name': 'Janelle Mendoza', 'phone': '115-567-8901'},
    {'name': 'Joana Murillo', 'phone': '116-567-8901'},
    {'name': 'Nicholas Lanting', 'phone': '117-567-8901'},
    {'name': 'Ton Chio', 'phone': '118-567-8901'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents content shifting
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -350,
            left: 0,
            child: Image.asset(
              'images/minibartop.png',
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 37.0,
            left: 10,
            child: Row(
              children: [
                // Back arrow icon button
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Color(0xddffad49) ), // Back arrow icon
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the previous screen
                  },
                ),
                // Home text
                Text(
                  'Home',
                  style: TextStyle(
                    color: Color(0xffffffff),
                    fontSize: 23,
                    fontFamily: 'Mosafin',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 80.0,
            left: 25.0,
            child: Text(
              'Whitelisted',
              style: TextStyle(
                color: Color(0xffffffff),
                fontSize: 25,
                fontFamily: 'Mosafin',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            top: 140.0,
            left: 10,
            right: 30.0,
            child: TextField(
              key: Key('Search by name or number'),
              decoration: InputDecoration(
                hintText: 'Search by name or number',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF050a30),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                alignLabelWithHint: true,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 180),
              child: ListView.builder(
                itemCount: whitelist.length,
                itemBuilder: (context, index) {
                  final contact = whitelist[index];
                  return ListTile(
                    leading: Icon(Icons.person),
                    // Icon for contact (can be a photo if desired)
                    title: Text(contact['name']!),
                    subtitle: Text(contact['phone']!),
                    trailing: IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () {
                        print('Calling ${contact['name']}');
                      },
                    ),
                    onTap: () {
                      print('Tapped on ${contact['name']}');
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

















