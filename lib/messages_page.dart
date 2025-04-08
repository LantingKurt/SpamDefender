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

  @override
  void initState() {
    super.initState();
    _fetchMessages();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top minibar
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
                const SizedBox(height: 40), // Spacing for minibar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Text(
                        'SMS Inbox',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.menu, color: Colors.white),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Message list
                Expanded(
                  child: groupedMessages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: groupedMessages.keys.length,
                          itemBuilder: (context, index) {
                            final sender = groupedMessages.keys.elementAt(index);
                            final messages = groupedMessages[sender]!;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageDetailPage(sender: sender, messages: messages),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF070056),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.person, color: Color(0xFF1F0D68)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sender,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            messages.first.body ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

class MessageDetailPage extends StatelessWidget {
  final String sender;
  final List<SmsMessage> messages;

  const MessageDetailPage({required this.sender, required this.messages, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sender),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return ListTile(
            title: Text(message.body ?? ""),
            subtitle: Text(
              message.dateSent != null
                  ? DateTime.fromMillisecondsSinceEpoch(message.dateSent!).toString()
                  : (message.date != null
                      ? DateTime.fromMillisecondsSinceEpoch(message.date!).toString()
                      : "Unknown date"),
            ),
          );
        },
      ),
    );
  }
}