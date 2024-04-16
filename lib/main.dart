import 'package:flutter/material.dart';

void main() {
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
        title: Text('Admin Dashboard'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'User Management',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dashboard Overview',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text('Total Bookings'),
              subtitle: Text('100'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Total Revenue'),
              subtitle: Text('\$1000'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.trending_up),
              title: Text('Occupancy Rate'),
              subtitle: Text('80%'),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add functionality here
            },
            child: Text('View Detailed Report'),
          ),
        ],
      ),
    );
  }
}

class UserManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'User Management',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('View User Details'),
              subtitle: Text('Admins can view user details and information.'),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add functionality here
            },
            child: Text('Manage User Roles'),
          ),
        ],
      ),
    );
  }
}
