import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF050a30)),),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF050a30)), ),
          hintText: hintText

        ),
      ),
    );
  }
}

