import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final Telephony telephony = Telephony.instance;
  List<SmsMessage> messages = [];
  List<SmsMessage> recentlyDeleted = []; // To simulate "recently deleted"
  bool isLoading = true;
  String _searchQuery = ''; // Search query variable

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() => isLoading = true);
    if (await _requestSmsPermission()) {
      try {
        List<SmsMessage> fetchedMessages = await telephony.getInboxSms(
          columns: [
            SmsColumn.ID,
            SmsColumn.ADDRESS,
            SmsColumn.BODY,
            SmsColumn.DATE,
          ],
          sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
        );
        setState(() {
          messages = fetchedMessages;
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

  Future<bool> _requestSmsPermission() async {
    bool? granted = await telephony.requestSmsPermissions;
    if (granted == null || !granted) {
      var status = await Permission.sms.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> _deleteMessage(SmsMessage message) async {
    setState(() {
      messages.remove(message);
      recentlyDeleted.add(message); // Move to "recently deleted"
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message moved to recently deleted')),
    );
  }

  Future<void> _restoreMessage(SmsMessage message) async {
    setState(() {
      recentlyDeleted.remove(message);
      messages.add(message); // Restore to main list
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message restored')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter messages based on search query
    List<SmsMessage> filteredMessages = messages.where((message) {
      final sender = (message.address ?? '').toLowerCase();
      final body = (message.body ?? '').toLowerCase();
      return sender.contains(_searchQuery.toLowerCase()) || body.contains(_searchQuery.toLowerCase());
    }).toList();

    // Group messages by sender's first letter
    Map<String, List<SmsMessage>> groupedMessages = {};
    for (var message in filteredMessages) {
      String firstLetter = message.address != null && message.address!.isNotEmpty
          ? message.address![0].toUpperCase()
          : '#';
      if (!groupedMessages.containsKey(firstLetter)) {
        groupedMessages[firstLetter] = [];
      }
      groupedMessages[firstLetter]!.add(message);
    }
    List<String> sectionHeaders = groupedMessages.keys.toList()..sort();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -350,
            left: 0,
            child: Image.asset(
              'images/minibar.png', // Ensure this asset exists
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 49.0,
            left: 10,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xddffad49)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text(
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
          const Positioned(
            top: 80.0,
            left: 25.0,
            child: Text(
              'Messages',
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
                hintText: 'Search by sender or message',
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF050a30)),
                contentPadding: const EdgeInsets.symmetric(
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
              padding: const EdgeInsets.only(top: 200),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: sectionHeaders.length,
                itemBuilder: (context, sectionIndex) {
                  String letter = sectionHeaders[sectionIndex];
                  List<SmsMessage> sectionMessages = groupedMessages[letter]!;

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
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              height: 2,
                              color: const Color(0xddffad49),
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                            ),
                          ],
                        ),
                      ),
                      ...sectionMessages.map((message) {
                        final sender = message.address ?? 'Unknown';
                        final body = message.body ?? 'No content';

                        return ListTile(
                          leading: const Icon(Icons.message),
                          title: Text(sender),
                          subtitle: Text(body, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      ListTile(
                                        title: const Text('Delete'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _deleteMessage(message);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecentlyDeletedDialog(),
        child: const Icon(Icons.delete_forever),
        backgroundColor: const Color(0xddffad49),
      ),
    );
  }

  // Show a dialog for recently deleted messages
  void _showRecentlyDeletedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recently Deleted Messages'),
          content: recentlyDeleted.isEmpty
              ? const Text('No recently deleted messages')
              : SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: recentlyDeleted.length,
              itemBuilder: (context, index) {
                final message = recentlyDeleted[index];
                return ListTile(
                  title: Text(message.address ?? 'Unknown'),
                  subtitle: Text(message.body ?? 'No content', maxLines: 1),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () {
                      _restoreMessage(message);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

