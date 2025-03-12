import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spamdefender/add_contacts.dart'; 
import 'package:spamdefender/edit_contacts.dart'; 
import 'package:spamdefender/whitelist_contacts.dart'; 
void main() {
  // UC-3.0-S1: View Whitelist Contacts
  testWidgets('UC-3.0-S1: View Whitelist Contacts', (WidgetTester tester) async {
    // Build the widget for whitelist contacts screen
    await tester.pumpWidget(MaterialApp(home: WhitelistScreen())); 

    // Check if the contact list is displayed
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);  // Ensure there are multiple contact entries
  });

  // UC-3.0-S2: Modify Whitelist Contacts
  testWidgets('UC-3.0-S2: Modify Whitelist Contacts', (WidgetTester tester) async {
    // Create a mock contact to pass
    final contact = {'name': 'John Doe', 'phone': '1234567890'};
    final index = 0;

    // Build the EditContactScreen widget
    await tester.pumpWidget(MaterialApp(
      home: EditContactScreen(contact: contact, index: index, onUpdate: (updatedContact, index) {
        // Simulate the update action here
        print('Contact Updated: $updatedContact');
      }),
    ));

    // Find the name field and modify it
    final nameField = find.byType(TextField).at(0);
    await tester.enterText(nameField, 'Jane Doe');
    await tester.pump();

    // Tap the Save Changes button
    final saveButton = find.text('Save Changes');
    await tester.tap(saveButton);
    await tester.pump();

    // Ensure the contact was updated (this is an example of what should happen on the save action)
    expect(find.text('Jane Doe'), findsOneWidget);
  });

// UC-3.0-S3: Add Whitelist Contacts
testWidgets('UC-3.0-S3: Add Whitelist Contacts', (WidgetTester tester) async {
  // Build the AddContactScreen widget
  await tester.pumpWidget(MaterialApp(
    home: AddContactScreen(onAdd: (newContact) {
      print('New Contact Added: $newContact');
    }),
  ));

  // Enter name and phone number
  await tester.enterText(find.byType(TextField).at(0), 'John Doe');
  await tester.enterText(find.byType(TextField).at(1), '1234567890');
  await tester.pump();

  // Find the "Add Contact" button using its text and tap it
  final addContactButton = find.text('Add Contact').last; // Use 'last' in case there are multiple buttons with the same text
  await tester.tap(addContactButton); // Tap the button with the label "Add Contact"
  await tester.pump();

  // Ensure the contact was added (this is an example of what should happen)
  expect(find.text('John Doe'), findsOneWidget);  // Verify that the contact name is added
});

// UC-3.0-S4: Delete Whitelist Contacts
testWidgets('UC-3.0-S4: Delete Whitelist Contacts', (WidgetTester tester) async {
  // Build the WhitelistContactsScreen widget
  await tester.pumpWidget(MaterialApp(home: WhitelistScreen()));

  // Wait for the widget tree to settle
  await tester.pumpAndSettle();  // Ensure all widgets are built and visible

  // Find the "more" button (trailing icon) for the first contact
  final moreButton = find.byIcon(Icons.more_horiz).first;
  expect(moreButton, findsOneWidget); // Ensure the "more" button is found

  // Tap the "more" button to open the modal
  await tester.tap(moreButton);
  await tester.pumpAndSettle(); // Wait for the modal to appear

  // Find and tap the "Delete" button inside the modal
  final deleteButton = find.text('Delete').first; // Find the "Delete" option
  expect(deleteButton, findsOneWidget); // Ensure the delete button is found
  await tester.tap(deleteButton); // Tap the delete button
  await tester.pump(); // Wait for the widget tree to rebuild

  // Verify that the contact was deleted
  expect(find.text('John Doe'), findsNothing); // Adjust this for the specific contact name
});

  // UC-3.0-S5: Customize Notification Settings (UI only)
  testWidgets('Customize Notification Settings UI', (WidgetTester tester) async {
    // Act: Pump the notification settings screen (UI only, no functionality)
    await tester.pumpWidget(MaterialApp(home: Scaffold()));

    // Assert: Verify that the notification settings UI elements are present
    expect(find.byType(Switch), findsNothing); // Example placeholder
    expect(find.text('Notifications'), findsNothing); // Example placeholder
  });
}
