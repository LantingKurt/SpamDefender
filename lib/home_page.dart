// Flutter Dependencies
import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:firebase_auth/firebase_auth.dart';

// UI Screens
import 'welcome.dart';
import 'contacts_native/whitelist_contacts.dart';
import 'contacts_native/blacklist_contacts.dart';
import 'notification.dart';
import 'messages/safe_messages.dart';
import 'messages/spam_messages.dart';

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
              top: 95,
              left: 25,
              child: Image.asset(
                'images/keepinboxclean.png',
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.height * 0.05,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 140,
              left: 20,
              child: ClipRect(
                child: GestureDetector(
                  onTap: () {
                    // Add your onTap functionality here
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.53,
                      height: MediaQuery.of(context).size.height * 0.06, // Adjust aspect ratio here
                      child: Image.asset(
                        'images/search.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Image.asset(
                'images/minibar.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 240,
              left: 40,
              right: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'images/allmessages.png',
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.19,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 390,
              left: 45,
              right: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SafeMessages()),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'images/safemessages.png',
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.25,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SpamMessages()),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'images/spammessages.png',
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.25,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 600, // Adjusted position to avoid overlap
              left: 40, // Adjusted alignment
              right: 40, // Adjusted alignment
              child: GestureDetector(
                onTap: () {
                  // Handle tap
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'images/recentlydeleted.png',
                    width: MediaQuery.of(context).size.width, // Adjusted size
                    height: MediaQuery.of(context).size.height * 0.19, // Adjusted size
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 320,
              child: IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 35.0,
                ),
                onPressed: () {},
              ),
            ),
            // Whitelist Contacts button
            Positioned(
              bottom: 8,
              left: 250,
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
              left: 180,
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
              left: 110,
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
              left: 40,
              child: IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 35.0,
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

