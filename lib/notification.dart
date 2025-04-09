// Flutter Dependencies
import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:io'; // import for file operations
import 'package:path_provider/path_provider.dart'; // Add this for file paths
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'messages_page.dart'; // Import MessagesPage

// Top-level function for background message handling
Future<void> backgroundMessageHandler(SmsMessage message) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'sms_channel',
        'SMS Notifications',
        channelDescription: 'Notifications for incoming SMS messages',
        importance: Importance.high,
        priority: Priority.high,
      );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    0,
    message.address ?? "Unknown",
    message.body ?? "No content",
    platformChannelSpecifics,
  );
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  bool isNotificationsEnabled = false;
  bool pendingNotificationsEnabled = false; // Temporary state for the switch
  String displayOption = 'Confirmation Pop-Up';

  final Telephony telephony = Telephony.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Add a global key to access MessagesPageState
  final GlobalKey<MessagesPageState> messagesPageKey =
      GlobalKey<MessagesPageState>();

  @override
  void initState() {
    super.initState();
    _loadNotificationState(); // Load the state from a file
    _initializeState();
  }

  Future<void> _loadNotificationState() async {
    try {
      final file = await _getStateFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          isNotificationsEnabled = content == 'true';
          pendingNotificationsEnabled = isNotificationsEnabled;
        });
      }
    } catch (e) {
      debugPrint("Error loading notification state: $e");
    }
  }

  Future<void> _saveNotificationStateToFile() async {
    try {
      final file = await _getStateFile();
      await file.writeAsString(isNotificationsEnabled.toString());
    } catch (e) {
      debugPrint("Error saving notification state: $e");
    }
  }

  Future<File> _getStateFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/notification_state.txt');
  }

  void _initializeState() {
    debugPrint("Initializing in-memory notification settings...");
    // Default values for in-memory state
    pendingNotificationsEnabled = isNotificationsEnabled;
    debugPrint(
      "Initial state - isNotificationsEnabled: $isNotificationsEnabled, pendingNotificationsEnabled: $pendingNotificationsEnabled",
    );
  }

  void _savePendingNotificationState(bool value) {
    debugPrint("Saving pendingNotificationsEnabled in memory: $value");
    setState(() {
      pendingNotificationsEnabled = value;
    });
    debugPrint(
      "Updated state - pendingNotificationsEnabled: $pendingNotificationsEnabled",
    );
  }

  void _initializeNotifications() async {
    // Request notification permissions using permission_handler
    final status = await Permission.notification.request();

    if (!status.isGranted) {
      // Permission not granted, handle accordingly
      print("Notification permissions not granted.");
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _listenForSms() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        if (!isNotificationsEnabled) {
          print("Notifications are disabled. Ignoring incoming message.");
          return; // Ignore the message if notifications are disabled
        }
        String senderName = await _resolveSenderName(
          message.address ?? "Unknown",
        );

        // Check if the message is spam
        bool isSpam = await _checkIfSpam(message.body ?? "No content");

        if (isSpam) {
          // Proceed with spam handling
          _showNotification("Spam Alert", "Message from $senderName is spam!");
          debugPrint("Spam notification shown for $senderName.");

          if (displayOption == 'Confirmation Pop-Up') {
            // Show confirmation dialog
            final shouldProceed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Spam Detected"),
                  content: Text(
                    "Message from $senderName is detected as spam. Do you want to proceed?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Proceed"),
                    ),
                  ],
                );
              },
            );

            if (shouldProceed != true) {
              debugPrint("User canceled spam handling for $senderName.");
              return; // Exit if the user cancels
            }
          }

          try {
            // Fetch messages explicitly
            final List<SmsMessage> messages =
                await Telephony.instance.getInboxSms();
            final Map<String, List<SmsMessage>> groupedMessages = {};
            for (var msg in messages) {
              String sender = msg.address?.trim() ?? "Unknown";
              if (!groupedMessages.containsKey(sender)) {
                groupedMessages[sender] = [];
              }
              groupedMessages[sender]!.add(msg);
            }

            // Get the first message to mark as spam
            final firstMessage =
                groupedMessages.entries.isNotEmpty
                    ? {
                      "sender": groupedMessages.entries.first.key,
                      "message":
                          groupedMessages.entries.first.value.first.body ?? "",
                    }
                    : null;

            if (firstMessage != null) {
              debugPrint("Marking the first message as spam: $firstMessage");

              // Add the message to spam_messages.json
              final directory = await getApplicationDocumentsDirectory();
              final spamFile = File('${directory.path}/spam_messages.json');
              List<dynamic> existingSpamMessages = [];
              if (await spamFile.exists()) {
                final String jsonString = await spamFile.readAsString();
                existingSpamMessages = json.decode(jsonString);
              }

              // Check if the sender already exists in the spam list
              final existingIndex = existingSpamMessages.indexWhere(
                (spam) => spam['sender'] == firstMessage["sender"],
              );

              if (existingIndex != -1) {
                // Append the new message to the existing sender's messages
                existingSpamMessages[existingIndex]['message'].addAll(
                  groupedMessages[firstMessage["sender"]]!
                      .map((msg) => msg.body ?? "")
                      .toList(),
                );
              } else {
                // Add a new entry for the sender
                final newSpam = {
                  "sender": firstMessage["sender"],
                  "number":
                      groupedMessages[firstMessage["sender"]]!.first.address ??
                      "Unknown",
                  "message":
                      groupedMessages[firstMessage["sender"]]!
                          .map((msg) => msg.body ?? "")
                          .toList(),
                };
                existingSpamMessages.add(newSpam);
              }

              await spamFile.writeAsString(json.encode(existingSpamMessages));

              // Add the sender to blacklist.json
              final blacklistFile = File('${directory.path}/blacklist.json');
              List<dynamic> blacklist = [];
              if (await blacklistFile.exists()) {
                final String jsonString = await blacklistFile.readAsString();
                blacklist = json.decode(jsonString);
              }

              final blacklistEntry = {
                "sender": firstMessage["sender"],
                "number":
                    groupedMessages[firstMessage["sender"]]!.first.address ??
                    "Unknown",
              };

              // Avoid duplicate entries in the blacklist
              if (!blacklist.any(
                (entry) => entry['number'] == blacklistEntry['number'],
              )) {
                blacklist.add(blacklistEntry);
                await blacklistFile.writeAsString(json.encode(blacklist));
                debugPrint("Sender added to blacklist.json: $blacklistEntry");
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Message Marked as Spam and Added to Blacklist",
                  ),
                ),
              );

              debugPrint("Message successfully added to spam_messages.json");
            } else {
              debugPrint("No messages available to mark as spam.");
            }
          } catch (e) {
            debugPrint("Error in spam handling: $e");
          }
        } else {
          // Show regular notification
          _showNotification(senderName, message.body ?? "No content");
        }
      },
      onBackgroundMessage:
          backgroundMessageHandler, // Use the top-level function
    );
  }

  Future<bool> _checkIfSpam(String message) async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://192.168.1.19:5000/predict', // Updated with the correct IP address
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_spam'] ?? false;
      } else {
        print("Error from server: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error checking spam: $e");
      return false;
    }
  }

  Future<String> _resolveSenderName(String senderNumber) async {
    debugPrint("Resolving sender name for number: $senderNumber");

    if (await FlutterContacts.requestPermission()) {
      try {
        final fetchedContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withAccounts: true,
        );

        final contacts = await Future.wait(
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

        debugPrint("Fetched ${contacts.length} contacts.");

        // Normalize sender number
        senderNumber = _normalizePhoneNumber(senderNumber);
        debugPrint("Normalized sender number: $senderNumber");

        for (var contact in contacts) {
          for (var phone in contact.phones) {
            // Normalize contact phone numbers
            String normalizedPhone = _normalizePhoneNumber(phone.number);

            debugPrint(
              "Checking contact: ${contact.displayName}, phone: $normalizedPhone",
            );

            if (normalizedPhone == senderNumber) {
              debugPrint("Match found: ${contact.displayName}");
              return contact.displayName;
            }
          }
        }
      } catch (e) {
        debugPrint("Error resolving sender name: $e");
      }
    } else {
      debugPrint("Permission to access contacts was denied.");
    }

    debugPrint("No match found. Returning sender number: $senderNumber");
    return senderNumber; // Return the number if no matching contact is found
  }

  String _normalizePhoneNumber(String phoneNumber) {
    // Remove non-numeric characters
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Convert numbers starting with '09' to '+639'
    if (phoneNumber.startsWith('09')) {
      phoneNumber = phoneNumber.replaceFirst('09', '+639');
    }

    // Ensure numbers starting with '639' are prefixed with '+'
    if (phoneNumber.startsWith('639')) {
      phoneNumber = '+$phoneNumber';
    }

    return phoneNumber;
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'sms_channel',
          'SMS Notifications',
          channelDescription: 'Notifications for incoming SMS messages',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void _saveNotificationSettings() async {
    debugPrint("Save button pressed. Showing confirmation dialog...");
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            pendingNotificationsEnabled
                ? "Enable Notifications"
                : "Disable Notifications",
          ),
          content: Text(
            pendingNotificationsEnabled
                ? "Are you sure you want to enable notifications?"
                : "Are you sure you want to disable notifications?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      debugPrint("User confirmed. Saving notification settings in memory...");
      setState(() {
        isNotificationsEnabled = pendingNotificationsEnabled;
      });
      debugPrint(
        "Updated state - isNotificationsEnabled: $isNotificationsEnabled, pendingNotificationsEnabled: $pendingNotificationsEnabled",
      );

      await _saveNotificationStateToFile(); // Save the state to a file

      if (isNotificationsEnabled) {
        debugPrint(
          "Notifications are enabled. Initializing notifications and SMS listener...",
        );
        _initializeNotifications();
        _listenForSms();
        print("Notifications enabled.");
      } else {
        debugPrint("Notifications are disabled.");
        print("Notifications disabled.");
      }
    } else {
      debugPrint("User canceled. Reverting temporary state...");
      setState(() {
        pendingNotificationsEnabled = isNotificationsEnabled;
      });
    }
  }

  void _setDisplayOption(String value) {
    debugPrint("Changing display option from $displayOption to $value");
    setState(() {
      displayOption = value;
    });
    debugPrint("Display option updated to: $displayOption");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            top: 70.0,
            left: 10,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Color(0xddffad49)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                // Title
              ],
            ),
          ),

          Positioned(
            top: 75.0,
            left: 80.0,
            right: 80,
            child: Text(
              'Set Notifications',
              style: TextStyle(
                color: Color(0xffffffff),
                fontSize: 25,
                fontFamily: 'Mosafin',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            top: 250.0,
            left: 20,
            right: 20.0,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                leading: Icon(
                  Icons.notifications,
                  size: 40.0,
                  color: Color(0xffFFAD49),
                ),
                title: Text(
                  'Enable Notifications',
                  style: TextStyle(
                    fontFamily: 'Mosafin',
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                trailing: Switch(
                  value: pendingNotificationsEnabled,
                  onChanged: (value) async {
                    setState(() {
                      pendingNotificationsEnabled = value;
                    });
                    _savePendingNotificationState(value); // Save the state
                  },
                  activeColor: Color(0xffFFAD49),
                ),
              ),
            ),
          ),

          Positioned(
            top: 350.0,
            left: 20,
            right: 20.0,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Handle Spam Messages as:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Color(0xffFFAD49),
                              size: 40.0,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Confirmation Pop-Up',
                              style: TextStyle(color: Colors.black),
                            ),
                            Radio<String>(
                              value: 'Confirmation Pop-Up',
                              groupValue: displayOption,
                              onChanged: (value) {
                                _setDisplayOption(value!);
                              },
                              activeColor: Color(0xffFFAD49),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: Color(0xffFFAD49),
                              size: 40.0,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Automatic',
                              style: TextStyle(color: Colors.black),
                            ),
                            Radio<String>(
                              value: 'Automatic',
                              groupValue: displayOption,
                              onChanged: (value) {
                                _setDisplayOption(value!);
                              },
                              activeColor: Color(0xffFFAD49),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30.0,
            left: 20.0,
            right: 20.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffFFAD49),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveNotificationSettings,
              child: const Text(
                "Save",
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
