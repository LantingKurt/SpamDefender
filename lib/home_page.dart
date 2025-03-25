// Flutter Dependencies
import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:firebase_auth/firebase_auth.dart';

// UI Screens
import 'welcome.dart';
import 'whitelist_contacts.dart';
import 'blacklist_contacts.dart';
import 'notification.dart';
import 'safe_messages.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false, // Prevents back navigation
      child: Scaffold(
        backgroundColor: const Color(0xFF070056),
        body: Stack(
          children: [
            Positioned(
              top: 120,
              right: 0,
              child: Image.asset(
                'images/whitebg.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: -85,
              left: 20,
              child: Image.asset(
                'images/search.png',
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.55,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: -380,
              left: 0,
              child: Image.asset(
                'images/minibar.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: -90,
              left: 12,
              child: Image.asset(
                'images/allmessages.png',
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 100,
              left: 12,
              child: Image.asset(
                'images/spammessages.png',
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 20,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SafeMessages()),
                  );
                },
                child: Image.asset(
                  'images/safemessages.png',
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 1.3,
                  fit: BoxFit.contain,
                ),
              ),
            ),


            // Whitelist Contacts button
            Positioned(
              bottom: 8,
              right: 50,
              child: IconButton(
                icon: const Icon(
                  Icons.bookmark_border,
                  color: Colors.white,
                  size: 35.0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WhitelistScreen(),
                    ),
                  );
                },
              ),
            ),

            // Blacklist Contacts button
            Positioned(
              bottom: 8,
              right: 120,
              child: IconButton(
                icon: const Icon(
                  Icons.block,
                  color: Colors.white,
                  size: 35.0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BlacklistScreen(),
                    ),
                  );
                },
              ),
            ),

            // Notifications Button
            Positioned(
              bottom: 8,
              right: 190,
              child: IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 35.0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),
            ),

            // Sign out button
            Positioned(
              bottom: 8,
              left: 50,
              child: IconButton(
                icon: const Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                  size: 35.0,
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut(); //Signs out on firebase
                  // D/FirebaseAuth(25557): Notifying id token listeners about a sign-out event.
                  // D/FirebaseAuth(25557): Notifying auth state listeners about a sign-out event.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  );
                },
              ),
            ),


          ], //body: Stack(
        ),
      ),
    );
  }    //  Widget build(BuildContext context) {
}     //class HomeScreen extends StatelessWidget {
