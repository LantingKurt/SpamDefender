// Flutter Dependencies
import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:io'; // Add this import for file operations
import 'package:path_provider/path_provider.dart'; // Add this for file paths
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String displayOption = 'Banners';

  final Telephony telephony = Telephony.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
          // Alert user if it's spam
          _showNotification("Spam Alert", "Message from $senderName is spam!");
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
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      for (var contact in contacts) {
        if (contact.phones.any(
          (phone) =>
              phone.number.replaceAll(RegExp(r'\D'), '') ==
              senderNumber.replaceAll(RegExp(r'\D'), ''),
        )) {
          return contact.displayName;
        }
      }
    }
    return senderNumber; // Return the number if no matching contact is found
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
    setState(() {
      displayOption = value;
    });
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
                      'Display as',
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
                              Icons.message,
                              color: Color(0xffFFAD49),
                              size: 40.0,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Banners',
                              style: TextStyle(color: Colors.black),
                            ),
                            Radio<String>(
                              value: 'Banners',
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
                              Icons.notifications_active,
                              color: Color(0xffFFAD49),
                              size: 40.0,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Alerts',
                              style: TextStyle(color: Colors.black),
                            ),
                            Radio<String>(
                              value: 'Alerts',
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
                              Icons.badge_rounded,
                              color: Color(0xffFFAD49),
                              size: 40.0,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Badges',
                              style: TextStyle(color: Colors.black),
                            ),
                            Radio<String>(
                              value: 'Badges',
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
