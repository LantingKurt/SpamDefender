import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_database/firebase_database.dart';

Future<void> syncSpamMessagesJsonToFirebase() async {
  try {
    // Load the JSON file
    final String jsonString = await rootBundle.loadString('assets/spam_messages.json');
    final List<dynamic> messages = json.decode(jsonString);

    // Reference to Firebase Realtime Database
    final DatabaseReference database = FirebaseDatabase.instance.ref();

    // Upload each message to the 'spamMessages' node
    for (var message in messages) {
      await database.child('spamMessages').push().set({
        'sender': message['sender'] ?? '',
        'message': message['message'] ?? '',
      });
    }

    print('Spam messages JSON synced to Firebase successfully!');
  } catch (e) {
    print('Error syncing spam messages JSON to Firebase: $e');
  }
}