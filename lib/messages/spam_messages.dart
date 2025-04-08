// // Flutter Dependencies
// import 'package:flutter/material.dart';
// import '../home_page.dart';
// import 'individ_message.dart';
// import 'edit_messages.dart';
//
//
// // Data
// import 'messages_data.dart';
//
// class SpamMessages extends StatefulWidget {
//   const SpamMessages({super.key});
//
//   @override
//   SpamMessagesState createState() => SpamMessagesState();
// }
//
// class SpamMessagesState extends State<SpamMessages> {
//   int selectedIndex = 0;
//
//   List<Map<String, String>> get displayedMessages {
//     if (selectedIndex == 0) return spamMessages;
//     if (selectedIndex == -1) return safeMessages;
//     return [...safeMessages, ...spamMessages];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             left: 0,
//             child: Image.asset(
//               'images/minibartop.png',
//               width: MediaQuery.of(context).size.width,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned(
//             top: 40.0,
//             left: 15,
//             right: 15,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.black.withOpacity(0.7),
//                   ),
//                   child: IconButton(
//                     icon: Icon(Icons.home, color: Colors.white),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => HomeScreen()),
//                       );
//                     },
//                   ),
//                 ),
//                 Text(
//                   'Messages',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 23,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Mosafin',
//                   ),
//                 ),
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.black.withOpacity(0.7),
//                   ),
//                   child: IconButton(
//                     icon: Icon(Icons.edit, color: Colors.white),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => EditMessages(
//                             messages: displayedMessages,
//                             selectedIndex: selectedIndex == 0 ? 1 : selectedIndex,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             top: 95.0,
//             left: -55,
//             right: 20.0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildTab('Safe Messages', -1),
//                 SizedBox(width: 10),
//                 _buildTab('Spam Messages', 0),
//                 SizedBox(width: 10),
//                 _buildTab('All Texts', 1),
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.only(top: 140),
//             child: ListView.builder(
//               itemCount: displayedMessages.length,
//               itemBuilder: (context, index) {
//                 final message = displayedMessages[index];
//                 return ListTile(
//                   leading: Icon(Icons.person, size: 40.0, color: Colors.grey),
//                   title: Text(
//                     message['sender']!,
//                     style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Mosafin'),
//                   ),
//                   subtitle: Text(
//                     message['message']!,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(fontFamily: 'Mosafin'),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MessagePage(message: message),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTab(String title, int index) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedIndex = index;
//         });
//       },
//       child: Column(
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: selectedIndex == index ? Colors.white : Colors.grey,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Mosafin',
//             ),
//           ),
//           if (selectedIndex == index)
//             Container(
//               height: 2,
//               width: 80,
//               color: Colors.orange,
//               margin: EdgeInsets.only(top: 2),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildIconCircle(IconData icon) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.black.withOpacity(0.4),
//       ),
//       child: IconButton(
//         icon: Icon(icon, color: Colors.white),
//         onPressed: () {},
//       ),
//     );
//   }
// }
