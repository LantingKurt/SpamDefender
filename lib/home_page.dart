import 'package:flutter/material.dart';

// UI Screens
import 'whitelist_contacts.dart';

// HOMEPAGE //
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
            child: Image.asset(
              'images/safemessages.png',
              width: MediaQuery.of(context).size.width * 0.45,
              height: MediaQuery.of(context).size.height * 1.3,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 50,
            child: IconButton(
              icon: Icon(
                Icons.bookmark_border,
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
        ],
      ),
    );
  }
}
