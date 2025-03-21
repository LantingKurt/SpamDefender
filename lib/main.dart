// Flutter Dependencies -----------------------------------------------------------------
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//----------------------------------------------------------------------------------------

// Firebase Implementation --------------------------------------------------------------
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:spamdefender/firebase_options.dart';

//import 'package:firebase_auth/firebase_auth.dart';
//import 'firebase_auth_services.dart';
//----------------------------------------------------------------------------------------

// UI Screens -------------------------------
import 'splash_screen.dart';

//import 'welcome.dart';
//import 'log_in.dart';
//import 'sign_up.dart';

//import 'home_page.dart';
//import 'whitelist_contacts.dart';
// ------------------------------------------

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en', 'US'),
      supportedLocales: [Locale('en'), Locale('US')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}
