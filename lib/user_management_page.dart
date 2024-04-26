import 'package:flutter/material.dart';
import 'package:admin_hub/services/firestore.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  FireStoreService fireStoreService = FireStoreService();
  bool _isLoading = false;
  bool _showUsers = false;
  bool _buttonClicked = false;
  bool _showTravellersButton = true;
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Colors.grey[300] ?? Colors.grey;
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showTravellersButton)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ListTile(
                    title: SizedBox(
                      height: 60, // Adjust the height as needed
                      child: Container(
                        width: 200, // Adjust the width as needed
                        child: Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Travellers',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Text(
                                  'View and manage travellers',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _showUsers = true;
                        _isLoading = true;
                        _buttonClicked = true;
                      });
                      fetchUsers();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: buttonColor,
                  ),
                ),
              ),
            if (!_showUsers)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ListTile(
                    title: SizedBox(
                      height: 60, // Adjust the height as needed
                      child: Container(
                        width: 200, // Adjust the width as needed
                        child: Row(
                          children: [
                            Icon(Icons.business),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Business Owners',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Text(
                                  'View and manage business owners',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _showUsers = false;
                        _isLoading = false;
                        _buttonClicked = true;
                        _showTravellersButton = false; // Hide the "Travellers" button
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: buttonColor,
                  ),
                ),
              ),
            SizedBox(height: 20),
            if (_showUsers) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  filterUsers(value);
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(
                                    filteredUsers[index]['username'] ?? 'No Name',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(filteredUsers[index]['email'] ?? 'No Email'),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButtonLocation: _buttonClicked ? FloatingActionButtonLocation.endDocked : null,
      floatingActionButton: _buttonClicked
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  if (_showUsers) {
                    setState(() {
                      _isLoading = true;
                      users = [];
                    });
                    fetchUsers();
                  }
                },
                child: Icon(Icons.refresh),
              ),
            )
          : null,
    );
  }

  Future<void> fetchUsers() async {
    try {
      List<Map<String, dynamic>> fetchedUsers = await fireStoreService.queryUsers();
      setState(() {
        users = fetchedUsers;
        filteredUsers = fetchedUsers; // Initialize filteredUsers with all users
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void filterUsers(String query) {
    List<Map<String, dynamic>> searchResults = users.where((user) {
      String username = user['username'] ?? '';
      String email = user['email'] ?? '';
      return username.toLowerCase().contains(query.toLowerCase()) || email.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = searchResults;
    });
  }
}
