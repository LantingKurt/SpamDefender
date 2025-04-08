import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch spam messages from Firebase
  Future<List<Map<String, String>>> fetchSpamMessages() async {
    final QuerySnapshot snapshot =
    await _firestore.collection('spamMessages').get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id.toString(),          // doc.id is already a String
        'sender': doc['sender']?.toString() ?? '',
        'message': doc['message']?.toString() ?? '',
      };
    }).toList();
  }

  Future<List<Map<String, String>>> fetchSafeMessages() async {
    final QuerySnapshot snapshot =
    await _firestore.collection('safeMessages').get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id.toString(),
        'sender': doc['sender']?.toString() ?? '',
        'message': doc['message']?.toString() ?? '',
      };
    }).toList();
  }

  // Add a new spam message to Firebase
  Future<void> addSpamMessage(String sender, String message) async {
    await _firestore.collection('spamMessages').add({
      'sender': sender,
      'message': message,
    });
  }

  // Add a new safe message to Firebase
  Future<void> addSafeMessage(String sender, String message) async {
    await _firestore.collection('safeMessages').add({
      'sender': sender,
      'message': message,
    });
  }

  // Delete a spam message from Firebase
  Future<void> deleteSpamMessage(String id) async {
    await _firestore.collection('spamMessages').doc(id).delete();
  }

  // Delete a safe message from Firebase
  Future<void> deleteSafeMessage(String id) async {
    await _firestore.collection('safeMessages').doc(id).delete();
  }

  // Upload initial messages to Firebase (one-time operation)
  Future<void> uploadInitialMessages() async {
    try{
      final spamMessages = [
        {'sender': '!!!SHOPMORE FREE MONEY!!!', 'message': "🎉🎁 YOU WON PHP 100,000! 🎁🎉 CLAIM NOW BEFORE IT'S TOO LATE! 🔥 ONLY 5 WINNERS LEFT! CLICK HERE FAST! 👉 [scam-link]"},
        {'sender': 'BPI URGENT ALERT 999', 'message': "🚨🚨 YOUR BPI ACCOUNT HAS BEEN HACKED! 🚨🚨 IMMEDIATE ACTION REQUIRED! CLICK HERE TO RECOVER NOW! 🔓 [phishing-link]"},
        {'sender': 'MAYA FASTCASH WINNINGS', 'message': "💸💸 PHP 999,999 HAS BEEN SENT TO YOUR MAYA ACCOUNT! 💸💸 VERIFY NOW TO RECEIVE IT! ⚡ [scam-link]"},
        {'sender': 'MAYA IMMEDIATE PAYOUT', 'message': "🔥🔥 URGENT! PHP 500,000 READY FOR YOU! 🔥🔥 VERIFY IN 5 MINS OR LOSE IT FOREVER! 💵 [fraudulent-link]"},
        {'sender': 'GET RICH FAST 100%', 'message': "💰💰 OMG BES! NAGKAROON AKO NG 1M OVERNIGHT! 😱 JOIN KA DITO, LEGIT TO! NO WORK NEEDED! 🔥 [scam-link]"},
        {'sender': 'EASY CASH GIVEAWAY', 'message': "Sis! 💵 LIBRENG PERA SA BAGONG SITE NA TO! 💸 JOIN LANG, TAPOS BOOM! INSTANT MONEY! 🚀 [fraudulent-link]"},
        {'sender': 'MOM SECRET INVESTMENT', 'message': "Anak, 📢 MAY NEW SECRET INVESTMENT NA X10 ANG PERA MO IN 1 DAY! 🤑 REGISTER FAST! 💰 [scam-link]"},
        {'sender': 'BOBO TEST KUNG NA-ADD NGA BA', 'message': "POTANGINAAAA SANA GUMAGANA NA DATABASEEEEE PLSPLSPLSPSLPSLSPLSPLSPLSPLS"},
      ];

      final safeMessages = [
        {'sender': 'ShopMore PH', 'message': "Congratulations! You've won a voucher worth PHP 1,000. Claim it now..."},
        {'sender': 'BPI Bank Alert', 'message': "IMPORTANT: Your BPI account has been locked due to suspicious login attempts..."},
        {'sender': 'Maya Pay', 'message': "PHP 4,800 has been sent to your Maya account. Verify the transaction at..."},
        {'sender': 'Maya', 'message': "A deposit of PHP 2,650.00 is on its way. Please visit Maya.ph to verify your account..."},
        {'sender': 'Bes', 'message': "Hi Bes! Kamusta ka na? Kamusta ang buhay mo diyan sa Manila? Kita tayo soon!"},
        {'sender': 'Ella', 'message': "Friend, may alam ka bang masarap na kainan sa BGC? Date night namin ni bf eh!"},
        {'sender': 'Mom', 'message': "Anak, kumain ka na ba? Huwag mong kalimutang magpahinga ha. Laging alagaan ang sarili."},
        {'sender': 'Love', 'message': "Hello."},
      ];

      for (var message in spamMessages) {
        await addSpamMessage(message['sender']!, message['message']!);
      }

      for (var message in safeMessages) {
        await addSafeMessage(message['sender']!, message['message']!);
      }
    } catch (e) {
      print("Error uploading initial messages: $e");
    }
  }
}