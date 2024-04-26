import 'package:flutter/material.dart';
import 'package:admin_hub/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_hub/firebase_options.dart';
import 'package:admin_hub/user_management_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Interface',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardOverviewPage(),
    UserManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QvrBo'),
      ),
      body: _pages[_currentIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/QvrBo.png', 
                    width: 70,
                    height: 70,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'QvrBo',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context); // Close the drawer after navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('User Management'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context); // Close the drawer after navigation
              },
            ),
            // Add more list tiles for additional items
          ],
        ),
      ),
    );
  }
}

class DashboardOverviewPage extends StatefulWidget {
  @override
  _DashboardOverviewPageState createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  FireStoreService fireStoreService = FireStoreService();
  List<Map<String, dynamic>> bookings = [];
  int? totalBookings; // Initialize totalBookings to null
  bool isLoading = false; // Track whether data is being fetched

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            'Dashboard Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text('Total Bookings'),
              subtitle: totalBookings != null ? Text('$totalBookings') : null, // Display only if totalBookings is not null
              onTap: () async {
                setState(() {
                  isLoading = true; // Set loading to true when fetching data
                });
                try {
                  List<Map<String, dynamic>> fetchedBookings = await fireStoreService.queryBookings();
                  setState(() {
                    bookings = fetchedBookings;
                    totalBookings = fetchedBookings.length;
                    isLoading = false; // Set loading to false after data is fetched
                  });
                } catch (e) {
                  print('Error fetching bookings: $e');
                  // Handle the error gracefully
                  setState(() {
                    isLoading = false; // Set loading to false if an error occurs
                  });
                }
              },
            ),
          ),
          SizedBox(height: 20),
          isLoading ? CircularProgressIndicator() : Expanded(
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final checkInDate =
                    (bookings[index]['checkInDate'] as Timestamp).toDate();
                final checkOutDate =
                    (bookings[index]['checkOutDate'] as Timestamp).toDate();
                final dateFormat = DateFormat('MMMM d, yyyy');

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildDetailRow(
                          'Name:',
                          '${bookings[index]['userDetails']['name'] ?? 'null'}',
                        ),
                        _buildDetailRow(
                          'Place Name:',
                          '${bookings[index]['accommodation']['data']['Name'] ?? 'null'}',
                        ),
                        _buildDetailRow(
                          'Town:',
                          '${bookings[index]['accommodation']['data']['Town'] ?? 'null'}',
                        ),
                        _buildDetailRow(
                          'Type:',
                          '${bookings[index]['accommodation']['data']['Type'] ?? 'null'}',
                        ),
                        _buildDetailRow(
                          'Check-in:',
                          '${dateFormat.format(checkInDate)}',
                        ),
                        _buildDetailRow(
                          'Check-out:',
                          '${dateFormat.format(checkOutDate)}',
                        ),
                        _buildDetailRow(
                          'Selected Method:',
                          '${bookings[index]['payment']['selectedMethod'] ?? 'null'}',
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Room Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildDetailRow(
                          'Room Type:',
                          '${bookings[index]['room']['Name'] ?? 'null'}',
                        ),
                        _buildDetailRow(
                          'Price:',
                          '${bookings[index]['room']['Price'] ?? 'null'}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
