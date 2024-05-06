import 'package:flutter/material.dart';
import 'package:admin_hub/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

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
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Colors.grey[300] ?? Colors.grey;
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
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
                        child: const Row(
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
                        child: const Row(
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
                        _showUsers = true; // Show Business Owners
                        _isLoading = true;
                        _buttonClicked = true;
                        _showTravellersButton = false; // Hide the "Travellers" button
                      });
                      fetchBusinessOwners();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: buttonColor,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (_showUsers) ...[
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  filterUsers(value);
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredUsers.isEmpty
                        ? const Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BusinessOwnerDetailsPage(
                                        ownerId: filteredUsers[index]['ownerID'] ?? '',
                                        ownerName: filteredUsers[index]['username'] ?? 'No Name',
                                        ownerEmail: filteredUsers[index]['email'] ?? 'No Email',
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text(
                                      filteredUsers[index]['username'] ?? 'No Name',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(filteredUsers[index]['email'] ?? 'No Email'),
                                  ),
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
                child: const Icon(Icons.refresh),
              ),
            )
          : null,
    );
  }

  Future<void> fetchUsers() async {
    try {
      List<Map<String, dynamic>> fetchedUsers = await fireStoreService.queryUsers();
      setState(() {
        users = fetchedUsers ?? [];
        filteredUsers = fetchedUsers ?? []; // Initialize filteredUsers with all users
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchBusinessOwners() async {
    try {
      List<Map<String, dynamic>> fetchedBusinessOwners = await fireStoreService.queryBusinessOwners();
      setState(() {
        users = fetchedBusinessOwners ?? [];
        filteredUsers = fetchedBusinessOwners ?? []; // Initialize filteredUsers with all business owners
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching business owners: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void filterUsers(String query) {
    List<Map<String, dynamic>> searchResults = users.where((user) {
      String? username = user['username'];
      String? email = user['email'];
      return (username != null && username.toLowerCase().contains(query.toLowerCase())) ||
          (email != null && email.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    setState(() {
      filteredUsers = searchResults;
    });
  }
}

class BusinessOwnerDetailsPage extends StatelessWidget {
  final String ownerId;
  final String ownerName;
  final String ownerEmail;

  BusinessOwnerDetailsPage({super.key, 
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Owner Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: const Text(
                  'Owner Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(
                          ownerName,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(
                          ownerEmail,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Accommodations:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('accommodations')
                    .where('ownerDetails.username', isEqualTo: ownerName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No accommodations found for this owner',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var accommodation = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                      String name = accommodation['Name'] ?? 'No Name';
                      String town = accommodation['Town'] ?? 'Unknown';
                      String type = accommodation['Type'] ?? 'Unknown';
                      List<String> amenities = (accommodation['amenities'] as List<dynamic>?)?.cast<String>() ?? [];
                      String imageUrl = accommodation['Images'] ?? ''; // Assuming the image URL is stored under 'image'

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                width: double.infinity,
                                height: 200, // Image height
                                fit: BoxFit.cover,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text('Town: $town', style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('Type: $type', style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Amenities: ${amenities.join(', ')}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Handle onTap if needed
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
