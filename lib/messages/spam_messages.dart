import 'package:flutter/material.dart';
import '../home_page.dart';
import 'message_page.dart';
import 'messages_data.dart';
import 'edit_messages.dart';

class SpamMessages extends StatefulWidget {
  const SpamMessages({super.key});

  @override
  SpamMessagesState createState() => SpamMessagesState();
}

class SpamMessagesState extends State<SpamMessages> {
  final MessagesRepository _repository = MessagesRepository();
  List<Map<String, String>> spamMessages = [];
  List<Map<String, String>> safeMessages = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final spam = await _repository.fetchSpamMessages();
    final safe = await _repository.fetchSafeMessages();
    setState(() {
      spamMessages = spam;
      safeMessages = safe;
    });
  }

  List<Map<String, String>> get displayedMessages {
    if (selectedIndex == 0) return spamMessages;
    if (selectedIndex == -1) return safeMessages;
    return [...safeMessages, ...spamMessages];
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
                _buildIconCircle(Icons.home, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }),
                const Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Mosafin',
                  ),
                ),
                _buildIconCircle(Icons.edit, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMessages(
                        messages: displayedMessages,
                        selectedIndex: selectedIndex == 0 ? 1 : selectedIndex,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Positioned(
            top: 95.0,
            left: -55,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab('Safe Messages', -1),
                const SizedBox(width: 10),
                _buildTab('Spam Messages', 0),
                const SizedBox(width: 10),
                _buildTab('All Texts', 1),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 140),
            child: ListView.builder(
              itemCount: displayedMessages.length,
              itemBuilder: (context, index) {
                final message = displayedMessages[index];
                return ListTile(
                  leading: const Icon(Icons.person, size: 40.0, color: Colors.grey),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagePage(message: message),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: selectedIndex == index ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontFamily: 'Mosafin',
            ),
          ),
          if (selectedIndex == index)
            Container(
              height: 2,
              width: 80,
              color: Colors.orange,
              margin: const EdgeInsets.only(top: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildIconCircle(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.7),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}