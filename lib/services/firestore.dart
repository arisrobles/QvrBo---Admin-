import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: library_prefixes
import 'user.dart' as LocalUser; // Alias the User class from user.dart

class FireStoreService {
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LocalUser.User>> queryUsers() async { // Use the LocalUser alias
    List<LocalUser.User> userList = [];

    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();

      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        Map<String, dynamic>? userData = docSnapshot.data() as Map<String, dynamic>?; // Cast userData to Map<String, dynamic> or null

        if (userData != null) {
          LocalUser.User user = LocalUser.User.fromJson(userData); // Use the LocalUser alias

          userList.add(user);
        }
      }
    } catch (e) {
      // Handle any potential errors here
      print('Error fetching users: $e');
    }

    return userList;
  }
}
