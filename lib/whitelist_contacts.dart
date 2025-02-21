import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';

// WHITELIST CONTACTS //
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
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                  icon: Icon(Icons.arrow_back_ios, color: Color(0xddffad49)),
                  // Back arrow icon
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Navigate back to the previous screen
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
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: Icon(Icons.search, color: Color(0xFF050a30)),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
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
