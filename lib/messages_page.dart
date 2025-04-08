import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    selectedIndex = 2; // Default to "All Texts" tab
    _fetchMessages();
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
      return groupedMessages.entries
          .where((entry) => entry.key == "Spam")
          .map(
            (entry) => {
              "sender": entry.key,
              "message": entry.value.first.body ?? "",
            },
          )
          .toList();
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Mosafin'),
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
      appBar: AppBar(title: Text(sender), backgroundColor: Colors.orange),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return ListTile(
            title: Text(message.body ?? ""),
            subtitle: Text(
              message.dateSent != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                    message.dateSent!,
                  ).toString()
                  : (message.date != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                        message.date!,
                      ).toString()
                      : "Unknown date"),
            ),
          );
        },
      ),
    );
  }
}
