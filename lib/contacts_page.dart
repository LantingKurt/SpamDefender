import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() => isLoading = true);
    if (await FlutterContacts.requestPermission()) {
      try {
        final fetchedContacts = await FlutterContacts.getContacts(
          withProperties: true,
        );
        setState(() {
          contacts = fetchedContacts;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: const Color(0xFF050a30),
      ),
      backgroundColor: const Color(0xFF050a30),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
          ? const Center(child: Text('No contacts found', style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final name = contact.displayName.isNotEmpty ? contact.displayName : 'Unknown';
          final phone = contact.phones.isNotEmpty ? contact.phones[0].number : 'No phone';

          return ListTile(
            title: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            subtitle: Text(
              phone,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        },
      ),
    );
  }
}