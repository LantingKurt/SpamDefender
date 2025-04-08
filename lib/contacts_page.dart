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

  // Delete a contact from the phone and update the local list
  Future<void> _deleteContact(Contact contact) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FlutterContacts.deleteContact(contact);
        if (mounted) {
          setState(() {
            contacts.remove(contact);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Contact deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete contact: $e')),
          );
        }
      }
    }
  }

  // Add a new contact to the phone and update the local list
  Future<void> _addContact(String name, String phone) async {
    if (await FlutterContacts.requestPermission()) {
      final newContact = Contact(
        displayName: name,
        name: Name(first: name),
        phones: [Phone(phone)],
      );

      try {
        await FlutterContacts.insertContact(newContact);
        await _fetchContacts();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contact added successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add contact: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission denied')));
    }
  }

  // Edit an existing contact on the phone and update the local list
  Future<void> _editContact(
    Contact contact,
    String newPrefix,
    String newFirstName,
    String newMiddleName,
    String newLastName,
    String newSuffix,
    String newPhone,
  ) async {
    final fullContact = await FlutterContacts.getContact(contact.id, withProperties: true, withAccounts: true);

    if (fullContact == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch full contact details')));
      return;
    }

    // Update the name fields
    fullContact.name.prefix = newPrefix.isNotEmpty ? newPrefix : fullContact.name.prefix;
    fullContact.name.first = newFirstName.isNotEmpty ? newFirstName : fullContact.name.first;
    fullContact.name.middle = newMiddleName.isNotEmpty ? newMiddleName : fullContact.name.middle;
    fullContact.name.last = newLastName.isNotEmpty ? newLastName : fullContact.name.last;
    fullContact.name.suffix = newSuffix.isNotEmpty ? newSuffix : fullContact.name.suffix;

    // Ensure displayName is updated
    fullContact.displayName = [
      fullContact.name.prefix,
      fullContact.name.first,
      fullContact.name.middle,
      fullContact.name.last,
      fullContact.name.suffix
    ].where((namePart) => namePart.isNotEmpty).join(' ');

    // Update the phone number
    if (newPhone.isNotEmpty) {
      if (fullContact.phones.isNotEmpty) {
        fullContact.phones[0] = Phone(newPhone);
      } else {
        fullContact.phones.add(Phone(newPhone));
      }
    }

    try {
      await fullContact.update();

      setState(() {
        final index = contacts.indexWhere((c) => c.id == contact.id);
        if (index != -1) {
          contacts[index] = fullContact;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contact updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update contact: $e')));
    }
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
          withAccounts: true, // Ensure rawId is fetched
        );

        // Fetch full details
        final detailedContacts = await Future.wait(
          fetchedContacts.map((contact) async {
            return await FlutterContacts.getContact(contact.id, withProperties: true, withAccounts: true);
          }),
        );

        setState(() {
          contacts = detailedContacts.whereType<Contact>().toList();
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission denied')));
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
            top: 90.0,
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
            top: 85.0,
            right: 25.0,
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 30),
              // Back arrow icon
              onPressed: () => _showAddContactDialog(),
            ),
          ),
          Positioned(
            top: 170.0,
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
                                                      _showEditContactDialog(contact);
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
                                                ),
                                              ],
                                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(),
        child: Icon(Icons.add),
        backgroundColor: Color(0xddffad49),
      ),
    );
  }

  // Show a dialog to add a new contact
  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addContact(nameController.text, phoneController.text);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Show a dialog to edit an existing contact
  void _showEditContactDialog(Contact contact) {
    final prefixController = TextEditingController(text: contact.name.prefix);
    final firstNameController = TextEditingController(text: contact.name.first);
    final middleNameController = TextEditingController(text: contact.name.middle);
    final lastNameController = TextEditingController(text: contact.name.last);
    final suffixController = TextEditingController(text: contact.name.suffix);
    final phoneController = TextEditingController(
      text: contact.phones.isNotEmpty ? contact.phones[0].number : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: prefixController,
                  decoration: InputDecoration(labelText: 'Name Prefix'),
                ),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: middleNameController,
                  decoration: InputDecoration(labelText: 'Middle Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: suffixController,
                  decoration: InputDecoration(labelText: 'Name Suffix'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _editContact(
                  contact,
                  prefixController.text,
                  firstNameController.text,
                  middleNameController.text,
                  lastNameController.text,
                  suffixController.text,
                  phoneController.text,
                );
                Navigator.pop(context); // Close dialog after saving
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

}