import 'package:flutter/material.dart';


class MyButton extends StatelessWidget {

  final Function()? onTap;

  const MyButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 50),
        decoration: BoxDecoration(
          color: Color(0xFF050a30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'SIGN IN',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17
            ),
          ),
        ),
      ),
    );
  }
}
