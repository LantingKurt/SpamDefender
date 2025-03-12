import 'package:flutter/material.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  bool isNotificationsEnabled = false;
  String displayOption = 'Banners';

  void _toggleNotifications(bool value) {
    setState(() {
      isNotificationsEnabled = value;
    });
  }

  void _setDisplayOption(String value) {
    setState(() {
      displayOption = value;
    });
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
            top: 37.0,
            left: 10,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xddffad49),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                // Title
              ],
            ),
          ),

          Positioned(
            top: 80.0,
            left: 80.0,
            right: 80,
            child: Text(
              'Allow Notifications',
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
            left: 25.0,
            right: 25.0,
            child: Text(
              'We would like to send you notifications for important updates. Please enable notifications below.',
              style: TextStyle(
                fontFamily: 'Mosafin',
                fontSize: 16.0,
                color: Colors.black,
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
                  value: isNotificationsEnabled,
                  onChanged: (value) {
                    _toggleNotifications(value);
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
            left: 10.0,
            right: 10.0,
            child: Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Options',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'When you enable notifications, you will receive alerts for all important updates. You can customize notifications later in your settings.',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
