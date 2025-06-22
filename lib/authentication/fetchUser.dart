import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> fetchUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    return null;
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
}
