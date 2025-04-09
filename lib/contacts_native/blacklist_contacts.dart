// Flutter Dependencies
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'whitelist_contacts.dart' as whitelistFile;
import '../contacts_page.dart'; // Import ContactsPage to use addContact

// UI Screens
import 'edit_contacts.dart';
import 'add_contacts.dart';

// BLACKLIST CONTACTS //
class BlacklistScreen extends StatefulWidget {
  const BlacklistScreen({super.key});

  @override
  BlacklistScreenState createState() => BlacklistScreenState();
}

class BlacklistScreenState extends State<BlacklistScreen> {
  List<Map<String, String>> blacklist = [];
  String _searchQuery = ''; // Search query variable

  @override
  void initState() {
    super.initState();
    _loadBlacklist(); // Load blacklist from file
    _printAppDirectory(); // Print the directory path
  }

  Future<void> _printAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    debugPrint("App-specific directory: ${directory.path}");
  }

  Future<File> _getBlacklistFile() async {
    final directory = await getApplicationDocumentsDirectory();
    print('${directory.path}/blacklist.json');
    return File('${directory.path}/blacklist.json');
  }

  Future<void> _loadBlacklist() async {
    try {
      final file = await _getBlacklistFile();
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        final List<dynamic> data = json.decode(jsonString);
        setState(() {
          blacklist = data.map((item) => Map<String, String>.from(item)).toList();
        });
      } else {
        // Initialize the file with an empty array if it doesn't exist
        await file.writeAsString(json.encode([
          { "sender": "Scam Likely", "number": "123-456-7890" },
          { "sender": "Fraudster Kurt", "number": "987-654-3210" },
          { "sender": "Shady Wana", "number": "555-123-4567" }
        ]));
        debugPrint("Blacklist file created and initialized.");
      }
    } catch (e) {
      debugPrint("Error loading or initializing blacklist: $e");
    }
  }

  Future<void> _saveBlacklist() async {
    try {
      final file = await _getBlacklistFile();
      await file.writeAsString(json.encode(blacklist));
      debugPrint("Blacklist saved successfully.");
    } catch (e) {
      debugPrint("Error saving blacklist: $e");
    }
  }

  // Mark Contact as Blacklist from Whitelist (and Vice Versa)
  // Blacklist to Whitelist
  // blacklist => actual list of all contacts in the blacklist
  // contact => contact we want to transfer
  void _markContactAsWhitelist(List<Map<String, String>> blacklist, Map<String, String> contact) {
    blacklist.removeWhere((item) => item['number'] == contact['number']);
    whitelistFile.WhitelistScreenState().whitelist.insert(0, contact);
  }

  Future<void> _markAsSafe(Map<String, String> contact) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/blacklist.json');

    try {
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        List<dynamic> blacklist = json.decode(jsonString);

        // Remove the contact from the blacklist
        blacklist.removeWhere((item) => item['number'] == contact['number']);
        await file.writeAsString(json.encode(blacklist));

        // Add the contact back to the Android phone
        await ContactsPage.addContact(contact['sender']!, contact['number']!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact marked as safe and added back')),
        );

        setState(() {
          this.blacklist.remove(contact);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as safe: $e')),
      );
    }
  }

  // Modify _deleteContact to remove by contact rather than index
  void _deleteContact(Map<String, String> contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                blacklist.remove(contact);
              });
              await _saveBlacklist(); // Save changes to file
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateContact(Map<String, String> updatedContact, int index) async {
    setState(() {
      blacklist[index] = updatedContact;
    });
    await _saveBlacklist(); // Save changes to file
  }

  void _addNewContact(Map<String, String> newContact) async {
    setState(() {
      blacklist.add(newContact);
    });
    await _saveBlacklist(); // Save changes to file
  }

  @override
  Widget build(BuildContext context) {
    // Filter whitelist based on search query
    List<Map<String, String>> filteredBlacklist =
        blacklist.where((contact) {
          final sender = contact['sender']?.toLowerCase() ?? '';
          final number = contact['number'] ?? '';
          return sender.contains(_searchQuery.toLowerCase()) ||
              number.contains(_searchQuery);
        }).toList();

    // Group filtered contacts alphabetically

    Map<String, List<Map<String, String>>> groupedContacts = {};

    for (var contact in filteredBlacklist) {
      String firstLetter = contact['sender']?[0].toUpperCase() ?? '#';
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
            top: 90.0,
            left: 25.0,
            child: Text(
              'Blacklisted',
              style: TextStyle(
                color: Color(0xffffffff),
                fontSize: 25,
                fontFamily: 'Mosafin',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 85.0,
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
            top: 170.0,
            left: 30,
            right: 30.0,
            child: TextField(
              key: Key('Search by name or number'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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

          // USER PROFILE TO BE USED IN FUTURE RELEASES
          // Positioned(
          //   top: 200.0,
          //   left: 15.0,
          //   right: 15.0,
          //   child: Card(
          //     elevation: 0,
          //     child: ListTile(
          //       leading: Icon(Icons.person, size: 60.0),
          //       title: Text(
          //         'My Name',
          //         style: TextStyle(
          //           fontFamily: 'Mosafin',
          //           fontSize: 20.0,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.black,
          //         ),
          //       ),
          //       subtitle: Text(
          //         '000-000-0000',
          //         style: TextStyle(
          //           fontFamily: 'Mosafin',
          //           fontSize: 15.0,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.black,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 200),
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
                      title: Text(contact['sender']!),
                      subtitle: Text(contact['number']!),
                      trailing: IconButton(
                        icon: Icon(Icons.more_horiz),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                            ),
                            backgroundColor: Color(0xFF050a30),
                            builder: (context) {
                              return Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Color(0xFF050a30),
                                          padding: EdgeInsets.symmetric(vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditContactScreen(
                                                contact: contact,
                                                index: blacklist.indexOf(contact),
                                                onUpdate: _updateContact,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text('Edit', style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.green,
                                          padding: EdgeInsets.symmetric(vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _markAsSafe(contact);
                                        },
                                        child: Text('Mark as Safe', style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.red,
                                          padding: EdgeInsets.symmetric(vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteContact(contact);
                                        },
                                        child: Text('Delete', style: TextStyle(fontSize: 16)),
                                      ),
                                    )
                                  ],
                                ),
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
