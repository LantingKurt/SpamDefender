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
      appBar: AppBar(
        title: const Text('SMS Inbox'),
        backgroundColor: Colors.orange,
      ),
      body: groupedMessages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: groupedMessages.keys.length,
              itemBuilder: (context, index) {
                final sender = groupedMessages.keys.elementAt(index);
                final messages = groupedMessages[sender]!;
                return ListTile(
                  leading: const Icon(Icons.person, size: 40.0, color: Colors.grey),
                  title: Text(
                    sender,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    messages.first.body ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageDetailPage(sender: sender, messages: messages),
                      ),
                    );
                  },
                );
              },
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