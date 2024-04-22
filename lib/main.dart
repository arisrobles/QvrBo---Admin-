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
  title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
        child: Image.asset(
          'assets/QvrBo.png', // Replace 'assets/QvrBo.png' with your actual image path
          width: 40, // Adjust size as needed
          height: 40,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'QvrBo',
          textAlign: TextAlign.center,
        ),
      ),
    ],
  ),
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
              leading: Icon(Icons.people),
              title: Text('Travelers'),
              subtitle: Text('View traveler details and information.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.business),
              title: Text('Business Owners'),
              subtitle: Text('View business owner details and information.'),
            ),
          ),
        ],
      ),
    );
  }
}
