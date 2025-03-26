// Flutter Dependencies
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

// UI Screens
import 'contacts_native/edit_contacts.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  bool isLoading = true;
  String _searchQuery = ''; // Search query variable

  // Add a method to delete a contact
  void _deleteContact(Contact contact) {
    setState(() {
      contacts.remove(contact);
    });
  }

  // Add a method to update a contact
  void _updateContact(Contact updatedContact, int index) {
    setState(() {
      contacts[index] = updatedContact;
    });
  }

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Permission denied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter contacts based on search query
    List<Contact> filteredContacts =
        contacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final phone =
              contact.phones.isNotEmpty ? contact.phones[0].number : '';
          return name.contains(_searchQuery.toLowerCase()) ||
              phone.contains(_searchQuery);
        }).toList();

    // Group contacts alphabetically
    Map<String, List<Contact>> groupedContacts = {};
    for (var contact in filteredContacts) {
      String firstLetter =
          contact.displayName.isNotEmpty
              ? contact.displayName[0].toUpperCase()
              : '#';
      if (!groupedContacts.containsKey(firstLetter)) {
        groupedContacts[firstLetter] = [];
      }
      groupedContacts[firstLetter]!.add(contact);
    }
    List<String> sectionHeaders = groupedContacts.keys.toList()..sort();

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Color(0xddffad49)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
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
              'Contacts',
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
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 200),
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: sectionHeaders.length,
                        itemBuilder: (context, sectionIndex) {
                          String letter = sectionHeaders[sectionIndex];
                          List<Contact> sectionContacts =
                              groupedContacts[letter]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
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
                                      margin: EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...sectionContacts.map((contact) {
                                final name =
                                    contact.displayName.isNotEmpty
                                        ? contact.displayName
                                        : 'Unknown';
                                final phone =
                                    contact.phones.isNotEmpty
                                        ? contact.phones[0].number
                                        : 'No phone';

                                return ListTile(
                                  leading: Icon(Icons.person),
                                  title: Text(name),
                                  subtitle: Text(phone),
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
                                                      builder: (context) =>
                                                          EditContactScreen(
                                                        contact: {
                                                          'name': name,
                                                          'phone': phone,
                                                        },
                                                        index: contacts.indexOf(
                                                          contact,
                                                        ),
                                                        onUpdate: (updatedContact,
                                                            index) {
                                                          final updated = Contact(
                                                            displayName:
                                                                updatedContact['name']!,
                                                            phones: [
                                                              Phone(
                                                                updatedContact[
                                                                    'phone']!,
                                                              )
                                                            ],
                                                          );
                                                          _updateContact(
                                                              updated, index);
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              ListTile(
                                                title: Text('Delete'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _deleteContact(contact);
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
                              }).toList(),
                            ],
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
