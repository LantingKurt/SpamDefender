import 'package:flutter/material.dart';

// Firebase Implementation
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spamdefender/firebase_auth_implementation/firebase_auth_services.dart';

import 'edit_contacts.dart';
import 'add_contacts.dart';

// WHITELIST CONTACTS //
class WhitelistScreen extends StatefulWidget {
  const WhitelistScreen({super.key});

  @override
  WhitelistScreenState createState() => WhitelistScreenState();
}

class WhitelistScreenState extends State<WhitelistScreen> {
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

  void _deleteContact(int index) {
    setState(() {
      whitelist.removeAt(index);
    });
  }

  void _updateContact(Map<String, String> updatedContact, int index) {
    setState(() {
      whitelist[index] = updatedContact;
    });
  }

  void _addNewContact(Map<String, String> newContact) {
    setState(() {
      whitelist.add(newContact);
    });
  }

  @override
  Widget build(BuildContext context) {
    whitelist.sort((a, b) => a['name']!.compareTo(b['name']!));

    Map<String, List<Map<String, String>>> groupedContacts = {};

    for (var contact in whitelist) {
      String firstLetter = contact['name']![0].toUpperCase();
      if (!groupedContacts.containsKey(firstLetter)) {
        groupedContacts[firstLetter] = [];
      }
      groupedContacts[firstLetter]!.add(contact);
    }

    List<String> sectionHeaders = groupedContacts.keys.toList()..sort();

    int itemCount = sectionHeaders.fold<int>(
      0,
      (sum, letter) => sum + 1 + groupedContacts[letter]!.length,
    );

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
                    Navigator.pop(context);
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
            top: 75.0,
            right: 25.0,
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 30),
              // Back arrow icon
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddContactScreen(onAdd: _addNewContact),
                  ),
                );
              },
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
          Positioned(
            top: 200.0,
            left: 15.0,
            right: 15.0,
            child: Card(
              elevation: 0,
              child: ListTile(
                leading: Icon(Icons.person, size: 60.0),
                title: Text(
                  'My Name',
                  style: TextStyle(
                    fontFamily: 'Mosafin',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  '000-000-0000',
                  style: TextStyle(
                    fontFamily: 'Mosafin',
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 260),
              child: ListView.builder(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  int sectionIndex = 0;
                  String letter = '';
                  List<Map<String, String>> contacts = [];

                  for (var section in sectionHeaders) {
                    int currentSectionItemCount =
                        1 +
                        groupedContacts[section]!
                            .length; // 1 for the header + contacts

                    if (index < sectionIndex + currentSectionItemCount) {
                      letter = section;
                      contacts = groupedContacts[section]!;
                      break;
                    }

                    sectionIndex += currentSectionItemCount;
                  }

                  if (index == sectionIndex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            letter,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            height: 2,
                            color: Color(0xddffad49),
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                          ),
                        ],
                      ),
                    );
                  } else if (index > sectionIndex) {
                    int contactIndex = index - sectionIndex - 1;
                    final contact = contacts[contactIndex];
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(contact['name']!),
                      subtitle: Text(contact['phone']!),
                      trailing: IconButton(
                        icon: Icon(Icons.more_horiz),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return ListView(
                                children: <Widget>[
                                  ListTile(
                                    title: Text('Edit'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => EditContactScreen(
                                                contact: contact,
                                                index: contactIndex,
                                                onUpdate: _updateContact,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    title: Text('Delete'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _deleteContact(contactIndex);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      onTap: () {},
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
