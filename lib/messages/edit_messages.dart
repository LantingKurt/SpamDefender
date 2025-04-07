import 'package:flutter/material.dart';
import 'safe_messages.dart';
import 'spam_messages.dart';


class EditMessages extends StatefulWidget {
  final List<Map<String, String>> messages;
  final int selectedIndex;

  EditMessages({required this.messages, required this.selectedIndex});

  @override
  _EditMessagesState createState() => _EditMessagesState();
}

class _EditMessagesState extends State<EditMessages> {
  Map<int, bool> selectedMessages = {};
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  void _showActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF0B0C42),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Action",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              _bottomSheetButton("Delete", Colors.red, () {
                Navigator.pop(context);
                _confirmDelete();
              }),
              _bottomSheetButton("Mark as Spam", Color(0xddffad49), () {
                Navigator.pop(context);
              }),
              _bottomSheetButton("Cancel", Colors.grey, () {
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete the selected messages?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteSelectedMessages();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _bottomSheetButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _deleteSelectedMessages() {
    setState(() {
      widget.messages.removeWhere(
            (message) => selectedMessages[widget.messages.indexOf(message)] ?? false,
      );
      selectedMessages.clear();
    });
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
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Text(
                  'Edit Messages',
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
                    color: selectedMessages.containsValue(true)
                        ? Color(0xddffad49).withOpacity(0.8)
                        : Colors.grey.withOpacity(0.5),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: selectedMessages.containsValue(true) ? _showActionBottomSheet : null,
                  ),
                ),
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
                _buildTab('Safe Messages', 0, onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SafeMessages()));
                }),
                SizedBox(width: 10),
                _buildTab('Spam Messages', 1, onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SpamMessages()));
                }),
                SizedBox(width: 10),
                _buildTab('All Texts', 2),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 140),
            child: ListView.builder(
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                return ListTile(
                  leading: Icon(Icons.person, size: 40.0, color: Colors.grey),
                  title: Text(
                    message['sender']!,
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Mosafin'),
                  ),
                  subtitle: Text(
                    message['message']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Mosafin'),
                  ),
                  trailing: Checkbox(
                    value: selectedMessages[index] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        selectedMessages[index] = value ?? false;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      selectedMessages[index] = !(selectedMessages[index] ?? false);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        if (onPressed != null) {
          onPressed();
        }
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
              margin: EdgeInsets.only(top: 2),
            ),
        ],
      ),
    );
  }
}
