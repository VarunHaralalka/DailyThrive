import 'package:cloud_firestore/cloud_firestore.dart';

void deleteExpense(String docId, String userId) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection("expenses")
      .doc(docId)
      .delete();
}
