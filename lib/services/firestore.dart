import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  FirebaseFirestore db = FirebaseFirestore.instance;

  // Query users
  Future<List<Map<String, dynamic>>> queryUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db.collection('Users').get();
      List<Map<String, dynamic>> userList = [];
      querySnapshot.docs.forEach((docSnapshot) {
        userList.add(docSnapshot.data() as Map<String, dynamic>);
      });
      return userList;
    } catch (e) {
      print('Error fetching users: $e');
      throw e;
    }
  }

  // Query bookings
  Future<List<Map<String, dynamic>>> queryBookings() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db.collection('bookings').get();
      List<Map<String, dynamic>> bookingList = [];
      querySnapshot.docs.forEach((docSnapshot) {
        bookingList.add(docSnapshot.data() as Map<String, dynamic>);
      });
      return bookingList;
    } catch (e) {
      print('Error fetching bookings: $e');
      throw e;
    }
  }
}
