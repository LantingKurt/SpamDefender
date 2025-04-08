// Flutter Dependencies
import 'package:flutter/material.dart';

// UI Screens
import '../home_page.dart';
import 'messages_data.dart';
import 'individ_message.dart';

class MessagesScreen extends StatefulWidget {
  final int initialTab;

  const MessagesScreen({super.key, this.initialTab = 2});

  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  late int selectedIndex;
  Map<int, bool> selectedMessages = {};
  bool isEditing = false; // Track whether the user is in edit mode

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialTab; // Set the initial tab based on the parameter
  }

  List<Map<String, String>> get displayedMessages {
    if (selectedIndex == 0) return safeMessages;
    if (selectedIndex == 1) return spamMessages;
    return [...safeMessages, ...spamMessages];
  }

  void _showActionBottomSheet() {
    print("Opening action bottom sheet...");
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
                print("Opening delete confirmation dialog...");
                _showDeleteConfirmationDialog();
              }),
              if (selectedIndex == 0 || selectedIndex == 2) // Safe Messages or All Texts
                _bottomSheetButton("Mark as Spam", const Color(0xddffad49), () {
                  print("Opening mark as spam confirmation dialog...");
                  _showMarkAsSpamConfirmationDialog();
                }),
              if (selectedIndex == 1 || selectedIndex == 2) // Spam Messages or All Texts
                _bottomSheetButton("Mark as Safe", Colors.green, () {
                  print("Opening mark as safe confirmation dialog...");
                  _showMarkAsSafeConfirmationDialog();
                }),
              _bottomSheetButton("Cancel", Colors.grey, () {
                _resetEditingState();
                print("Action canceled.");
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete the selected messages?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                print("Delete canceled.");
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                print("Deleting selected messages...");
                _deleteSelectedMessages();
                _resetEditingState();
                Navigator.pop(context); // Close the bottom sheet
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showMarkAsSpamConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Mark as Spam"),
          content: const Text("Are you sure you want to mark the selected messages as spam?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                print("Mark as spam canceled.");
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                print("Marking selected messages as spam...");
                _markSelectedMessagesAsSpam();
                _resetEditingState();
                Navigator.pop(context); // Close the bottom sheet
              },
              child: const Text("Mark as Spam", style: TextStyle(color: Color(0xddffad49))),
            ),
          ],
        );
      },
    );
  }

  void _showMarkAsSafeConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Mark as Safe"),
          content: const Text("Are you sure you want to mark the selected messages as safe?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                print("Mark as safe canceled.");
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                print("Marking selected messages as safe...");
                _markSelectedMessagesAsSafe();
                _resetEditingState();
                Navigator.pop(context); // Close the bottom sheet
              },
              child: const Text("Mark as Safe", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _resetEditingState() {
    setState(() {
      isEditing = false; // Reset editing mode
      selectedMessages.clear(); // Clear selected messages
    });
    print("Editing mode reset and selected messages cleared.");
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _deleteSelectedMessages() {
    setState(() {
      if (selectedIndex == 2) { // Handle "All Texts" tab
        safeMessages.removeWhere((message) {
          final index = safeMessages.indexOf(message);
          return selectedMessages[index] ?? false;
        });
        spamMessages.removeWhere((message) {
          final index = safeMessages.length + spamMessages.indexOf(message);
          return selectedMessages[index] ?? false;
        });
      } else if (selectedIndex == 0) { // Handle "Safe Messages" tab
        safeMessages.removeWhere((message) {
          final index = safeMessages.indexOf(message);
          return selectedMessages[index] ?? false;
        });
      } else if (selectedIndex == 1) { // Handle "Spam Messages" tab
        spamMessages.removeWhere((message) {
          final index = spamMessages.indexOf(message);
          return selectedMessages[index] ?? false;
        });
      }
      selectedMessages.clear();
    });
    print("Selected messages deleted.");
  }

  void _markSelectedMessagesAsSpam() {
    setState(() {
      if (selectedIndex == 0 || selectedIndex == 2) { // Handle "Safe Messages" or "All Texts" tab
        safeMessages.removeWhere((message) {
          final index = safeMessages.indexOf(message);
          final isSelected = selectedMessages[index] ?? false;
          if (isSelected) {
            spamMessages.add(message); // Move to spamMessages
          }
          return isSelected;
        });
      }
      selectedMessages.clear();
    });
    print("Selected messages marked as spam.");
  }

  void _markSelectedMessagesAsSafe() {
    setState(() {
      if (selectedIndex == 1 || selectedIndex == 2) { // Handle "Spam Messages" or "All Texts" tab
        spamMessages.removeWhere((message) {
          final index = spamMessages.indexOf(message);
          final isSelected = selectedMessages[index] ?? false;
          if (isSelected) {
            safeMessages.add(message); // Move to safeMessages
          }
          return isSelected;
        });
      }
      selectedMessages.clear();
    });
    print("Selected messages marked as safe.");
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
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
                    color: isEditing
                        ? const Color(0xddffad49).withOpacity(0.8)
                        : Colors.grey.withOpacity(0.5),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing;
                      });
                      print("Editing mode toggled: $isEditing");
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
              mainAxisAlignment: MainAxisAlignment.center, // Center the tabs
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
                  trailing: isEditing
                      ? Checkbox(
                    value: selectedMessages[index] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        selectedMessages[index] = value ?? false;
                      });
                      print("Message at index $index selected: ${selectedMessages[index]}");
                    },
                  )
                      : null,
                  onTap: () {
                    if (isEditing) {
                      setState(() {
                        selectedMessages[index] = !(selectedMessages[index] ?? false);
                      });
                      print("Message at index $index toggled: ${selectedMessages[index]}");
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessagePage(message: message),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _showActionBottomSheet,
                child: const Text(
                  "Perform Action",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    double tabWidth;
    if (title == 'Safe Messages') {
      tabWidth = 120; // Custom width for "Safe Messages"
    } else if (title == 'Spam Messages') {
      tabWidth = 130; // Custom width for "Spam Messages"
    } else {
      tabWidth = 100; // Custom width for "All Texts"
    }
    return GestureDetector(
      onTap: () {
        if (!isEditing) { // Prevent tab switching while editing
          setState(() {
            selectedIndex = index; // Update selectedIndex to reflect the selected tab
          });
          print("Switched to tab: $title");
        } else {
          print("Tab switching disabled while editing.");
        }
      },
      child: SizedBox(
        width: tabWidth, // Use custom width for each tab
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
                width: tabWidth - 20, // Adjust underline width relative to tab width
                color: Colors.orange,
                margin: const EdgeInsets.only(top: 2),
              ),
          ],
        ),
      ),
    );
  }
}
