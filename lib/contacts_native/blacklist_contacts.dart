// Flutter Dependencies
import 'package:flutter/material.dart';
import 'whitelist_contacts.dart' as whitelistFile;

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
  final List<Map<String, String>> blacklist = [
    {'name': 'Scam Likely', 'phone': '123-456-7890'},
    {'name': 'Fraudster Kurt', 'phone': '987-654-3210'},
    {'name': 'Shady Wana', 'phone': '555-123-4567'},
    {'name': 'Anton Swindle', 'phone': '444-234-5678'},
    {'name': 'Rei Phisher', 'phone': '333-345-6789'},
    {'name': 'Ella Skimmer', 'phone': '222-456-7891'},
    {'name': 'Lily Deception', 'phone': '112-567-8901'},
    {'name': 'Mica Con', 'phone': '113-567-8901'},
    {'name': 'Andrea Spoofer', 'phone': '114-567-8901'},
    {'name': 'Janelle Fraud', 'phone': '115-567-8901'},
    {'name': 'Joana Hustler', 'phone': '116-567-8901'},
    {'name': 'Nicholas Ponzi', 'phone': '117-567-8901'},
    {'name': 'Ton Chio Swindler', 'phone': '118-567-8901'},
  ];
  String _searchQuery = ''; // Search query variable

  // Mark Contact as Blacklist from Whitelist (and Vice Versa)
  // Blacklist to Whitelist
  // blacklist => actual list of all contacts in the blacklist
  // contact => contact we want to transfer
  void _markContactAsWhitelist(List<Map<String, String>> blacklist, Map<String, String> contact){
    blacklist.removeWhere((item) => item['phone'] == contact['phone']);
    whitelistFile.WhitelistScreenState().whitelist.insert(0, contact);
  }

  // Modify _deleteContact to remove by contact rather than index
  void _deleteContact(Map<String, String> contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                blacklist.remove(contact);
              });
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateContact(Map<String, String> updatedContact, int index) {
    setState(() {
      blacklist[index] = updatedContact;
    });
  }

  void _addNewContact(Map<String, String> newContact) {
    setState(() {
      blacklist.add(newContact);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter whitelist based on search query
    List<Map<String, String>> filteredBlacklist =
    blacklist.where((contact) {
      final name = contact['name']!.toLowerCase();
      final phone = contact['phone']!;
      return name.contains(_searchQuery.toLowerCase()) ||
          phone.contains(_searchQuery);
    }).toList();

    // Group filtered contacts alphabetically

    Map<String, List<Map<String, String>>> groupedContacts = {};

    for (var contact in filteredBlacklist) {
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
                      title: Text(contact['name']!),
                      subtitle: Text(contact['phone']!),
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
                                  )
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
