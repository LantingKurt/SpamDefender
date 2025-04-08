import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

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
    selectedIndex = 2; // Default to "All Texts" tab
    _fetchMessages();
    _loadSpamMessages();
  }

  Future<void> _loadSpamMessages() async {
    final spamMessages = await _loadSpamMessagesFromFile();
    setState(() {
      _spamMessagesFromFile = spamMessages;
    });
  }

  Future<List<Map<String, String>>> _loadSpamMessagesFromFile() async {
    try {
      final file = await _getSpamMessagesFile();
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        final List<dynamic> spamMessages = json.decode(jsonString);

        // Safely cast each item to Map<String, String>
        return spamMessages.map((item) {
          return Map<String, String>.from(item as Map);
        }).toList();
      }
    } catch (e) {
      debugPrint("Error loading spam messages from file: $e");
    }
    return [];
  }

  List<Map<String, String>> get displayedMessages {
    if (selectedIndex == 0) {
      return groupedMessages.entries
          .where((entry) => entry.key != "Spam")
          .map(
            (entry) => {
              "sender": entry.key,
              "message": entry.value.first.body ?? "",
            },
          )
          .toList();
    }
    if (selectedIndex == 1) {
      // Include messages from spam_messages.json
      return [
        ...groupedMessages.entries
            .where((entry) => entry.key == "Spam")
            .map(
              (entry) => {
                "sender": entry.key,
                "message": entry.value.first.body ?? "",
              },
            )
            .toList(),
        ..._spamMessagesFromFile,
      ];
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

  Future<void> _fetchMessages() async {
    final List<SmsMessage> messages = await telephony.getInboxSms();
    final Map<String, List<SmsMessage>> grouped = {};

    for (var message in messages) {
      final sender = message.address ?? "Unknown";
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

  Future<File> _getSpamMessagesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/spam_messages.json');
  }

  void _markAsSpam() async {
    final selectedIndexes = selectedMessages.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    final List<Map<String, String>> spamMessagesToAdd = [];
    for (var index in selectedIndexes) {
      spamMessagesToAdd.add(displayedMessages[index]);
    }

    setState(() {
      for (var index in selectedIndexes.reversed) {
        displayedMessages.removeAt(index);
      }
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
      existingSpamMessages.addAll(spamMessagesToAdd);

      await file.writeAsString(json.encode(existingSpamMessages));
      debugPrint("Messages successfully added to spam_messages.json");

      // Debug: Print the updated content of the JSON file
      final String updatedContent = await file.readAsString();
      debugPrint("Updated spam_messages.json content: $updatedContent");
    } catch (e) {
      debugPrint("Error updating spam messages JSON: $e");
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
              _bottomSheetButton("Mark as Spam", Colors.orange, () {
                _markAsSpam();
                Navigator.pop(context);
              }),
              _bottomSheetButton("Delete", Colors.red, () {
                // Add delete functionality here
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                      });
                    },
                  ),
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
            padding: const EdgeInsets.only(top: 120),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MessageDetailPage(
                                sender: message['sender']!,
                                messages: groupedMessages[message['sender']!]!,
                              ),
                        ),
                      );
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
                const SizedBox(height: 20),
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
