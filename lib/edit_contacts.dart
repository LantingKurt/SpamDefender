import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';

class EditContactScreen extends StatefulWidget {
  final Map<String, String> contact;
  final int index;
  final Function(Map<String, String>, int) onUpdate;

  const EditContactScreen({super.key,
    required this.contact,
    required this.index,
    required this.onUpdate,
  });

  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact['name']);
    _phoneController = TextEditingController(text: widget.contact['phone']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents content shifting
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -380,
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
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                // Edit Contact text
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
            top: 120.0,
            left: 75.0,
            right: 75,
            child: Text(
              'Edit Contact Details',
              style: TextStyle(
                color: Color(0xFF070056),
                fontSize: 25,
                fontFamily: 'Mosafin',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 180.0,
            left: 15.0,
            right: 15.0,
            child: Icon(Icons.person, size: 100.0),
          ),
          Positioned(
            top: 300.0,
            left: 30,
            right: 30.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Label
                Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Name',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                SizedBox(height: 20),
                // Phone Number Label
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'Enter Phone Number',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
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
              ],
            ),
          ),
          Positioned(
            top: 530.0,
            left: 60.0,
            right: 60.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF070056),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                widget.onUpdate({
                  'name': _nameController.text,
                  'phone': _phoneController.text,
                }, widget.index);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}


