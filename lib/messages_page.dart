import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class Message {
  final String? address;
  final String body;
  final DateTime date;

  Message({required this.address, required this.body, required this.date});
}

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late Future<List<Message>> _messagesFuture;
  final Telephony telephony = Telephony.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messagesFuture = fetchMessages();
  }

  Future<List<Message>> fetchMessages() async {
    setState(() => _isLoading = true);

    try {
      bool? permissionsGranted = await telephony.requestSmsPermissions;
      if (permissionsGranted != true) {
        throw Exception('SMS permissions denied');
      }

      final List<SmsMessage> smsMessages = await telephony.getInboxSms();
      final messages = smsMessages
          .map((sms) => Message(
        address: sms.address,
        body: sms.body ?? '',
        date: DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0),
      ))
          .toList();

      messages.sort((a, b) => b.date.compareTo(a.date));
      setState(() => _isLoading = false);
      return messages;
    } catch (e) {
      setState(() => _isLoading = false);
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<void> _refreshMessages() async {
    setState(() => _messagesFuture = fetchMessages());
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the build method remains the same as previous example
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMessages,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMessages,
        child: FutureBuilder<List<Message>>(
          future: _messagesFuture,
          builder: (context, snapshot) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    ElevatedButton(
                      onPressed: _refreshMessages,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No messages found'));
            }
            final messages = snapshot.data!;
            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageTile(message: message);
              },
            );
          },
        ),
      ),
    );
  }
}

// MessageTile class remains the same as previous example
class MessageTile extends StatelessWidget {
  final Message message;

  const MessageTile({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(message.address?.substring(0, 1) ?? '?'),
      ),
      title: Text(message.address ?? 'Unknown'),
      subtitle: Text(message.body),
      trailing: Text(
        _formatTimestamp(message.date),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}