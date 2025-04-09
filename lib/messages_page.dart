import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void clearSpamMessages() async {
  final file = File('spam_messages.json');
  if (await file.exists()) {
    await file.writeAsString(jsonEncode([])); // Write an empty JSON array
    print('spam_messages.json has been cleared.');
  } else {
    print('spam_messages.json does not exist.');
  }
}

class MessagesPage extends StatefulWidget {
  final int initialTab; // Add this parameter

  const MessagesPage({
    super.key,
    this.initialTab = 2,
  }); // Default to "All Texts"

  @override
  MessagesPageState createState() => MessagesPageState();
}

class MessagesPageState extends State<MessagesPage> {
  final Telephony telephony = Telephony.instance;
  Map<String, List<SmsMessage>> groupedMessages = {};
  late int selectedIndex;
  Map<int, bool> selectedMessages = {};
  bool isEditing = false;
  List<Map<String, String>> _spamMessagesFromFile = [];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialTab; // Use the initialTab parameter
    fetchMessages();
    _loadSpamMessages();
  }

  Future<void> _loadSpamMessages() async {
    final spamMessages = await _loadSpamMessagesFromFile();
    setState(() {
      _spamMessagesFromFile = spamMessages;
    });
  }

  Future<File> _getSpamMessagesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/spam_messages.json');
  }

  Future<List<Map<String, String>>> _loadSpamMessagesFromFile() async {
    try {
      final file = await _getSpamMessagesFile();
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        final List<dynamic> spamMessages = json.decode(jsonString);

        // Safely cast each item to Map<String, String>
        return spamMessages.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return {
            "sender": map["sender"]?.toString() ?? "Unknown",
            "number": map["number"]?.toString() ?? "Unknown",
            "message":
                (map["message"] is List && (map["message"] as List).isNotEmpty)
                    ? (map["message"] as List<dynamic>).first.toString()
                    : "No message available", // Use only the first message
          };
        }).toList();
      }
    } catch (e) {
      debugPrint("Error loading spam messages from file: $e");
    }
    return [];
  }

  List<Map<String, String>> get displayedMessages {
    if (selectedIndex == 0) {
      // Filter out users from spam_messages.json
      final spamSenders =
          _spamMessagesFromFile.map((msg) => msg['sender']).toSet();
      return groupedMessages.entries
          .where(
            (entry) => entry.key != "Spam" && !spamSenders.contains(entry.key),
          )
          .map(
            (entry) => {
              "sender": entry.key,
              "message": entry.value.first.body ?? "",
            },
          )
          .toList();
    }
    if (selectedIndex == 1) {
      // Debug: Print the loaded spam messages from the file
      // debugPrint("Spam messages loaded from file: $_spamMessagesFromFile");

      // Show spam messages directly without re-encoding
      final messages =
          _spamMessagesFromFile.map((spam) {
            return {
              "sender": spam['sender'] ?? "Unknown",
              "message": spam['message'] ?? "No message available",
            };
          }).toList();

      // Debug: Print the messages to be displayed
      // debugPrint("Messages to be displayed in Spam Messages tab: $messages");

      return messages;
    }

    return groupedMessages.entries
        .map(
          (entry) => {
            "sender": entry.key,
            "message": entry.value.first.body ?? "",
          },
        )
        .toList();
  }

  Future<void> fetchMessages() async {
    final List<SmsMessage> messages = await telephony.getInboxSms();
    final Map<String, List<SmsMessage>> grouped = {};

    // Fetch full contact details
    List<Contact> contacts = [];

    if (await FlutterContacts.requestPermission()) {
      try {
        final fetchedContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withAccounts: true,
        );

        contacts = await Future.wait(
          fetchedContacts.map((contact) async {
            return await FlutterContacts.getContact(
              contact.id,
              withProperties: true,
              withAccounts: true,
            );
          }),
        ).then(
          (detailedContacts) => detailedContacts.whereType<Contact>().toList(),
        );

        // Modify phone numbers to the format +639XXXXXXXXX
        for (var contact in contacts) {
          for (var phone in contact.phones) {
            // Modify phone numbers only if they match the format +639XXXXXXXXX or 09XXXXXXXXX
            if (phone.number.startsWith('09')) {
              phone.number = phone.number.replaceFirst('09', '+639');
            }
            // Normalize phone numbers by removing non-numeric characters
            if (phone.number.startsWith('+639')) {
              phone.number = phone.number.replaceAll(RegExp(r'\D'), '');
            }
          }
        }

        // // Print the contacts obtained along with their modified phone numbers
        // debugPrint("Contacts obtained: ${contacts.map((c) => {
        //   'name': c.displayName,
        //   'phones': c.phones.map((p) => p.number).toList()
        // }).toList()}");
      } catch (e) {
        debugPrint("Error fetching contacts: $e");
      }
    }
    for (var message in messages) {
      String sender =
          message.address?.trim() ??
          "Unknown"; // Ensure sender is not null or empty
      // debugPrint("Original sender: $sender");

      if (sender != "Unknown") {
        // Modify sender only if it matches the format +639XXXXXXXXX or 09XXXXXXXXX
        if (sender.startsWith('09')) {
          sender = sender.replaceFirst('09', '+639');
        }
        if (sender.startsWith('+639')) {
          // Normalize sender by removing non-numeric characters
          sender = sender.replaceAll(RegExp(r'\D'), '');
        }
      }
      // debugPrint("Normalized sender: $sender");

      // Resolve name if sender matches a contact's phone number
      final contact = contacts.firstWhere(
        (c) => c.phones.any((phone) => phone.number == sender),
        orElse: () => Contact(),
      );
      if (contact.displayName.isNotEmpty) {
        sender = contact.displayName;
      }

      if (!grouped.containsKey(sender)) {
        grouped[sender] = [];
      }
      grouped[sender]!.add(message);
    }

    setState(() {
      groupedMessages = grouped;
    });
  }

  void _resetEditingState() {
    setState(() {
      isEditing = false;
      selectedMessages.clear();
    });
  }

  void markAsSpam() async {
    final selectedIndexes =
        selectedMessages.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    final List<Map<String, dynamic>> spamMessagesToAdd = [];
    final Set<String> processedSenders = {}; // To avoid duplicate processing

    for (var index in selectedIndexes) {
      final message = displayedMessages[index];
      final senderName =
          message['sender'] ?? "Unknown"; // Handle missing sender name

      if (!processedSenders.contains(senderName)) {
        processedSenders.add(senderName);

        // Include all messages from the sender
        final senderMessages = groupedMessages[senderName] ?? [];
        spamMessagesToAdd.add({
          "sender": senderName,
          "number":
              senderMessages.isNotEmpty
                  ? senderMessages.first.address ?? "Unknown"
                  : "Unknown",
          "message": senderMessages.map((msg) => msg.body ?? "").toList(),
        });

        // Ensure groupedMessages retains the sender's messages
        if (!groupedMessages.containsKey(senderName)) {
          groupedMessages[senderName] = senderMessages;
        }
      }
    }

    setState(() {
      // Remove selected messages from the displayed list
      displayedMessages.removeWhere(
        (msg) => processedSenders.contains(msg['sender']),
      );

      // Remove selected messages from groupedMessages (Safe Messages tab)
      groupedMessages.removeWhere(
        (key, value) => processedSenders.contains(key),
      );

      selectedMessages.clear();
      isEditing = false;
    });

    try {
      final file = await _getSpamMessagesFile();
      debugPrint("Spam messages file path: ${file.path}"); // Debug statement
      List<dynamic> existingSpamMessages = [];
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        existingSpamMessages = json.decode(jsonString);
      }

      // Merge new spam messages with existing ones
      for (var newSpam in spamMessagesToAdd) {
        final existingIndex = existingSpamMessages.indexWhere(
          (spam) => spam['sender'] == newSpam['sender'],
        );
        if (existingIndex != -1) {
          // Merge messages if sender already exists
          existingSpamMessages[existingIndex]['message'].addAll(
            newSpam['message'],
          );
        } else {
          existingSpamMessages.add(newSpam);
        }
      }

      await file.writeAsString(json.encode(existingSpamMessages));
      debugPrint("Messages successfully added to spam_messages.json");

      // Debug: Print the updated content of the JSON file
      final String updatedContent = await file.readAsString();
      debugPrint("Updated spam_messages.json content: $updatedContent");

      // Load the spam messages to reflect changes
      await _loadSpamMessages();
      await fetchMessages();
    } catch (e) {
      debugPrint("Error updating spam messages JSON: $e");
    }
  }

  void _markAsSafe() async {
    final selectedIndexes =
        selectedMessages.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    final List<Map<String, String>> messagesToRemove = [];
    for (var index in selectedIndexes) {
      messagesToRemove.add(displayedMessages[index]);
    }

    try {
      final file = await _getSpamMessagesFile();
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        List<Map<String, dynamic>> currentSpamMessages =
            (json.decode(jsonString) as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();

        // Debug print
        debugPrint("Original spam_messages.json content: $currentSpamMessages");

        // Remove selected messages
        currentSpamMessages.removeWhere(
          (spam) => messagesToRemove.any(
            (msg) =>
                msg['sender'] == spam['sender'] &&
                msg['message'] ==
                    (spam['message'] as List<dynamic>).first.toString(),
          ),
        );

        await file.writeAsString(json.encode(currentSpamMessages));
        debugPrint(
          "Updated spam_messages.json after marking safe: $currentSpamMessages",
        );
      }

      // Update local state
      setState(() {
        _spamMessagesFromFile.removeWhere(
          (spam) => messagesToRemove.any(
            (msg) =>
                msg['sender'] == spam['sender'] &&
                msg['message'] == spam['message'],
          ),
        );

        groupedMessages.removeWhere(
          (key, value) => messagesToRemove.any((msg) => msg['sender'] == key),
        );

        selectedMessages.clear();
        isEditing = false;
      });
      await fetchMessages();
    } catch (e) {
      debugPrint("Error marking messages as safe: $e");
    }
  }

  void _showActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B0C42),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Action",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              if (selectedIndex == 0 ||
                  selectedIndex == 2) // Safe Messages or All Texts
                _bottomSheetButton("Mark as Spam", Colors.orange, () {
                  markAsSpam();
                  Navigator.pop(context);
                }),
              if (selectedIndex == 1 ||
                  selectedIndex == 2) // Spam Messages or All Texts
                _bottomSheetButton("Mark as Safe", Colors.green, () {
                  _markAsSafe();
                  Navigator.pop(context);
                }),
              _bottomSheetButton("Cancel", Colors.grey, () {
                _resetEditingState();
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomSheetButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    double tabWidth =
        title == 'Safe Messages'
            ? 120
            : title == 'Spam Messages'
            ? 130
            : 100;
    return GestureDetector(
      onTap: () {
        if (!isEditing) {
          setState(() {
            selectedIndex = index;
          });
        }
      },
      child: SizedBox(
        width: tabWidth,
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selectedIndex == index ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontFamily: 'Mosafin',
              ),
            ),
            if (selectedIndex == index)
              Container(
                height: 2,
                width: tabWidth - 20,
                color: Colors.orange,
                margin: const EdgeInsets.only(top: 2),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'images/minibartop.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40.0,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.home, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Mosafin',
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () async {
                        final file = await _getSpamMessagesFile();
                        if (await file.exists()) {
                          await file.writeAsString(
                            jsonEncode([]),
                          ); // Clear file
                          setState(() {
                            _spamMessagesFromFile.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Spam messages cleared!'),
                            ),
                          );
                        }
                      },
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isEditing
                                ? const Color(0xddffad49).withOpacity(0.8)
                                : Colors.grey.withOpacity(0.5),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            isEditing = !isEditing;
                            if (!isEditing) {
                              selectedMessages.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 95.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab('Safe Messages', 0),
                const SizedBox(width: 10),
                _buildTab('Spam Messages', 1),
                const SizedBox(width: 10),
                _buildTab('All Texts', 2),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 136),
            child: ListView.builder(
              itemCount: displayedMessages.length,
              itemBuilder: (context, index) {
                final message = displayedMessages[index];
                return ListTile(
                  leading: const Icon(
                    Icons.person,
                    size: 40.0,
                    color: Colors.grey,
                  ),
                  title: Text(
                    message['sender']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Mosafin',
                    ),
                  ),
                  subtitle: Text(
                    message['message']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Mosafin'),
                  ),
                  trailing:
                      isEditing
                          ? Checkbox(
                            value: selectedMessages[index] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                selectedMessages[index] = value ?? false;
                              });
                            },
                          )
                          : null,
                  onTap: () {
                    if (isEditing) {
                      setState(() {
                        selectedMessages[index] =
                            !(selectedMessages[index] ?? false);
                      });
                    } else {
                      final sender = message['sender']!;
                      final messages = groupedMessages[sender];
                      if (messages != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MessageDetailPage(
                                  sender: sender,
                                  messages: messages,
                                ),
                          ),
                        );
                      }
                      // else {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(
                      //       content: Text('Message details not available.'),
                      //     ),
                      //   );
                      // }
                    }
                  },
                );
              },
            ),
          ),
          if (isEditing && selectedMessages.containsValue(true))
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xddffad49),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _showActionBottomSheet,
                child: const Text(
                  "Perform Action",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MessageDetailPage extends StatelessWidget {
  final String sender;
  final List<SmsMessage> messages;

  const MessageDetailPage({
    required this.sender,
    required this.messages,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'images/minibartop.png',
              width: MediaQuery.of(context).size.width,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            top: 0,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      Column(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Color(0xFF1F0D68)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sender,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const Icon(Icons.menu, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF070056),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    message.body ?? '',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                message.dateSent != null
                                    ? DateTime.fromMillisecondsSinceEpoch(
                                      message.dateSent!,
                                    ).toString()
                                    : (message.date != null
                                        ? DateTime.fromMillisecondsSinceEpoch(
                                          message.date!,
                                        ).toString()
                                        : "Unknown date"),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ), // Add spacing between messages
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
