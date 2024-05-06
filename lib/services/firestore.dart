import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  FirebaseFirestore db = FirebaseFirestore.instance;

   // Query users (Travellers)
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

  // Query business owners
  Future<List<Map<String, dynamic>>> queryBusinessOwners() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db.collection('Business Owners').get();
      List<Map<String, dynamic>> businessOwnerList = [];
      querySnapshot.docs.forEach((docSnapshot) {
        businessOwnerList.add(docSnapshot.data() as Map<String, dynamic>);
      });
      return businessOwnerList;
    } catch (e) {
      print('Error fetching business owners: $e');
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

  // Query revenue
  Future<double> queryRevenue() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db.collection('bookings').get();
      double totalRevenue = 0;
      querySnapshot.docs.forEach((docSnapshot) {
        totalRevenue += (docSnapshot.data()['amount'] ?? 0) as double;
      });
      return totalRevenue;
    } catch (e) {
      print('Error fetching revenue: $e');
      throw e;
    }
  }

  // Query accommodations
  Future<List<Map<String, dynamic>>> queryAccommodations() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db.collection('accommodations').get();
      List<Map<String, dynamic>> accommodationList = [];
      querySnapshot.docs.forEach((docSnapshot) {
        accommodationList.add(docSnapshot.data() as Map<String, dynamic>);
      });
      return accommodationList;
    } catch (e) {
      print('Error fetching accommodations: $e');
      throw e;
    }
  }

  queryBookingsForMonth(DateTime startOfMonth, DateTime endOfMonth) {}
}
