// Flutter Dependencies
import 'package:flutter/material.dart';
import '../home_page.dart';
import 'safe_messages.dart';



class SpamMessages extends StatefulWidget {
  const SpamMessages({super.key});

  @override
  SpamMessagesState createState() => SpamMessagesState();
}

class SpamMessagesState extends State<SpamMessages> {
  final List<Map<String, String>> messages = [
    {'sender': 'ShopMore PH', 'message': "Congratulations! You've won a voucher worth PHP 1,000. Claim it now..."},
    {'sender': 'BPI Bank Alert', 'message': "IMPORTANT: Your BPI account has been locked due to suspicious login attempts..."},
    {'sender': 'Maya Pay', 'message': "PHP 4,800 has been sent to your Maya account. Verify the transaction at..."},
    {'sender': 'Maya', 'message': "A deposit of PHP 2,650.00 is on its way. Please visit Maya.ph to verify your account..."},
    {'sender': 'Bes', 'message': "Hi Bes! Kamusta ka na? Kamusta ang buhay mo diyan sa Manila? Kita tayo soon!"},
    {'sender': 'Ella', 'message': "Friend, may alam ka bang masarap na kainan sa BGC? Date night namin ni bf eh!"},
    {'sender': 'Mom', 'message': "Anak, kumain ka na ba? Huwag mong kalimutang magpahinga ha. Laging alagaan ang sarili."},
  ];

  int selectedIndex = 0;

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
                    icon: Icon(Icons.home, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()), //
                      );
                    },
                  ),
                ),
                Text(
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
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                _buildTab('Safe Messages', -1,  onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SafeMessages()), //
                  );
                }),
                SizedBox(width: 10),
                _buildTab('Spam Messages', 0, onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SpamMessages()), //
                  );
                }),
                SizedBox(width: 10),
                _buildTab('All Texts', 1),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 140),
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
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
                  onTap: () {},
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
  Widget _buildIconCircle(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.4),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
