import 'package:flutter/material.dart';
import 'package:admin_hub/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_hub/firebase_options.dart';
import 'package:admin_hub/user_management_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:admin_hub/login_page.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Interface',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardOverviewPage(),
    UserManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QvrBo'),
      ),
      body: _pages[_currentIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/QvrBo.png',
                    width: 70,
                    height: 70,
                  ),
                  const SizedBox(height: 10),
                  const Text(
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
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context); // Close the drawer after navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
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
  const DashboardOverviewPage({Key? key});

  @override
  _DashboardOverviewPageState createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  FireStoreService fireStoreService = FireStoreService();
  int totalBookings = 0; // Initialize totalBookings to 0
  int totalUsers = 0; // Initialize totalUsers to 0
  double totalRevenue = 0.0; // Initialize totalRevenue to 0.0
  bool isLoading = false; // Track whether data is being fetched
  int completedBookings = 0;
  int cancelledBookings = 0;

  @override
  void initState() {
    super.initState();
    // Initialize total numbers here
    _fetchTotalNumbers();
  }

  Future<void> _fetchTotalNumbers() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Map<String, dynamic>> fetchedBookings = await fireStoreService.queryBookings();
      List<Map<String, dynamic>> fetchedUsers = await fireStoreService.queryUsers();

      double totalBookingRevenue = 0;
      int activeBookings = 0; // Track active bookings

      // Calculate total revenue from bookings
        for (var booking in fetchedBookings) {
      var status = booking['status'];
      if (status == 'active' || status == 'completed') {
        var priceDetails = booking['priceDetails'];
        double totalPrice = priceDetails['Total Price'] ?? 0;
        totalBookingRevenue += totalPrice * 0.05; // Multiply total price by 0.05 (5%)
        if (status == 'completed') {
          completedBookings++;
        }
        activeBookings++; // Increment active bookings count
      } else if (status == 'cancelled') {
        cancelledBookings++; // Increment cancelled bookings count
      }
    }

      setState(() {
      totalBookings = activeBookings; // Set totalBookings to active bookings count
      totalUsers = fetchedUsers.length;
      totalRevenue = totalBookingRevenue;
      isLoading = false;
    });
  } catch (e) {
    print('Error fetching data: $e');
    setState(() {
      isLoading = false;
    });
  }
}

@override
Widget build(BuildContext context) {
  double completedPercentage = totalBookings == 0 ? 0 : (completedBookings / totalBookings) * 100;
  double cancelledPercentage = totalBookings == 0 ? 0 : (cancelledBookings / totalBookings) * 100;

  // Ensure completedPercentage and cancelledPercentage are non-zero
  completedPercentage = completedPercentage == 0 ? 0.1 : completedPercentage;
  cancelledPercentage = cancelledPercentage == 0 ? 0.1 : cancelledPercentage;

  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Dashboard Overview',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCard(
              color: Colors.blueAccent,
              icon: Icons.book,
              title: 'Total Bookings',
              value: '$totalBookings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TotalBookingsPage()),
                );
              },
            ),
            _buildCard(
              color: Colors.green,
              icon: Icons.person,
              title: 'Total Users',
              value: '$totalUsers',
            ),
            _buildCard(
              color: Colors.orange,
              icon: Icons.attach_money,
              title: 'Total Revenue',
              value: '₱$totalRevenue',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Booking Status Distribution',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200, // Adjust the height as needed
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.blue,
                  value: completedPercentage,
                  title: 'Completed',
                  radius: 80,
                  titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: cancelledPercentage,
                  title: 'Cancelled',
                  radius: 80,
                  titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Status of Bookings for May 2024', // Change the month and year accordingly
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Total Bookings: $totalBookings', // You can add more details here as needed
          style: TextStyle(fontSize: 14),
        ),
        Text(
          'Completed Bookings: $completedBookings',
          style: TextStyle(fontSize: 14),
        ),
        Text(
          'Cancelled Bookings: $cancelledBookings',
          style: TextStyle(fontSize: 14),
        ),
      ],
    ),
  );
}

  Widget _buildCard({
    required Color color,
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        color: color,
        child: SizedBox(
          height: 150,
          width: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TotalBookingsPage extends StatefulWidget {
  const TotalBookingsPage({Key? key});

  @override
  _TotalBookingsPageState createState() => _TotalBookingsPageState();
}

class _TotalBookingsPageState extends State<TotalBookingsPage> {
  String _selectedStatus = 'All'; // Initialize selected status to 'All'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Bookings'),
      ),
      body: Column(
        children: [
          _buildFilterDropdown(),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No bookings found.'),
                  );
                }
                var filteredBookings = snapshot.data!.docs.where((booking) {
                  var data = booking.data() as Map<String, dynamic>;
                  // Check if the 'status' field exists in the document data
                  if (data.containsKey('status')) {
                    var status = data['status'];
                    if (_selectedStatus == 'All') {
                      return true; // Show all bookings
                    } else {
                      // Filter by the value of the 'status' field
                      return status == _selectedStatus;
                    }
                  } else {
                    // Handle the case where the 'status' field is missing
                    return false;
                  }
                }).toList();

                // If there are no bookings for the selected status, display a message
                if (filteredBookings.isEmpty) {
                  return Center(
                    child: Text('No bookings found for $_selectedStatus status.'),
                  );
                }

                // If there are bookings, display them
                return ListView.builder(
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    var booking = filteredBookings[index];
                    var accommodationData = booking['accommodation']['data'];
                    var userDetails = booking['userDetails'];
                    var priceDetails = booking['priceDetails'];
                    var status = booking['status'];

                    // Determine the color of the bullet based on the status
                    Color bulletColor = Colors.green; // Default to green for 'active'
                    if (status == 'cancelled') {
                      bulletColor = Colors.red; // Red for 'cancelled'
                    } else if (status == 'completed') {
                      bulletColor = Colors.blue; // Yellow for 'completed'
                    }

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('Accommodation: ${accommodationData['Name']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                const SizedBox(width: 4),
                                // Bigger bullet indicator
                                Container(
                                  width: 16, // Increase the width
                                  height: 16, // Increase the height
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: bulletColor,
                                  ),
                                  margin: const EdgeInsets.only(right: 8),
                                ),
                              ],
                            ),
                            Text('Guest Name: ${userDetails['Guest Name']}'),
                            Text('Town: ${accommodationData['Town']}'),
                            Text('Type: ${accommodationData['Type']}'),
                            Text('Check-in Date: ${booking['checkInDate']}'),
                            Text('Check-out Date: ${booking['checkOutDate']}'),
                            Text('Payment Method: ${priceDetails['Payment Method']}'),
                            Text('Total Price: ${priceDetails['Total Price']}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedStatus,
        onChanged: (String? newValue) {
          setState(() {
            _selectedStatus = newValue!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Filter by Status',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        items: <String>['All', 'active', 'completed', 'cancelled']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}

class AccommodationPage extends StatefulWidget {
  const AccommodationPage({Key? key});

  @override
  _AccommodationPageState createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  String selectedType = 'All'; // Initialize selected type to 'All'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodation'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedType = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Type',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              items: <String>['All', 'cottage', 'inn', 'transient']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Accommodation').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No accommodation found.'),
                  );
                }

                // Filter accommodations based on the value of the 'Type' field
                var filteredAccommodation = snapshot.data!.docs.where((doc) {
                  var accommodation = doc.data() as Map<String, dynamic>;
                  if (selectedType == 'All') {
                    return true;
                  } else {
                    // Check if the 'Type' field matches the selected type
                    return accommodation['Type'] == selectedType;
                  }
                }).toList();

                // If there are no accommodations for the selected type, display a message
                if (filteredAccommodation.isEmpty) {
                  return Center(
                    child: Text('No accommodations found for $selectedType.'),
                  );
                }

                // If there are accommodations, display them
                return ListView.builder(
                  itemCount: filteredAccommodation.length,
                  itemBuilder: (context, index) {
                    var accommodation = filteredAccommodation[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(accommodation['Name'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Town: ${accommodation['Town']}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RoomPage(accommodationId: snapshot.data!.docs[index].id)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RoomPage extends StatelessWidget {
  final String accommodationId;

  const RoomPage({Key? key, required this.accommodationId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Accommodation').doc(accommodationId).collection('Rooms').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No rooms found for this accommodation.'),
            );
          }

          // If there are rooms, display them
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var room = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(room['Name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: ${room['Description']}'),
                      Text('Price: ${room['Price']}'),
                      Text('Amenities: ${room['Amenities']}'),
                      TextButton(
                        onPressed: () {
                          _showAvailableDatesDialog(context, room['bookdates'] ?? []);
                        },
                        child: const Text('Available Dates'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAvailableDatesDialog(BuildContext context, List<dynamic> availableDates) {
    List<String> availableDateStrings = availableDates.map((date) => date.toString()).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Available Dates',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableDateStrings.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                              availableDateStrings[index],
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
