import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'db_helper.dart';
import 'new_record_page.dart';
import 'record_detail_page.dart'; // Import the new detail page
import 'profile_page.dart'; // Import the Profile page
import 'about_us_page.dart'; // Import the About Us page
import 'help_page.dart'; // Import the Help page
import 'settings_page.dart'; // Import the Settings page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false; // Flag to indicate loading state
  bool _isDarkMode = false; // Flag for theme switching

  Future<void> _searchRecords() async {
    setState(() {
      _isLoading = true;
    });

    final searchResults = await DBHelper.instance.searchRecordsByDate(_searchController.text);

    setState(() {
      _searchResults = searchResults;
      _isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    DateTime currentDate = DateTime.now();
    DateTime selectedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000), // Set a reasonable start date
      lastDate: currentDate, // Limit the selection to today's date
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        _searchController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      _searchRecords(); // Perform search with the selected date
    }
  }

  void _logout() async {
    await DBHelper.instance.logoutUser();
    Navigator.pushReplacementNamed(context, '/login'); // Redirect to login page
  }

  void _navigateToNewRecordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewRecordPage()),
    );
  }

  void _navigateToRecordDetailPage(Map<String, dynamic> record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordDetailPage(record: record),
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _logout,
            ),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                color: Colors.blueAccent,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'DayTask',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Placeholder for user profile section
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40.0, color: Colors.blueAccent),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'User Name', // Replace with user's name
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About Us'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AboutUsPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HelpPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.brightness_6),
                title: Text('Switch Theme'),
                onTap: _toggleTheme,
              ),
              Spacer(),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: _logout,
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blueGrey[50]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'YYYY-MM-DD', // Clear hint text for date format
                          labelText: 'Search by Date',
                          hintStyle: TextStyle(color: Colors.grey[600]), // Hint text style
                          labelStyle: TextStyle(color: Colors.blueGrey), // Label text style
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search, color: Colors.blue),
                            onPressed: _searchRecords,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        keyboardType: TextInputType.datetime,
                        onSubmitted: (_) => _searchRecords(), // Trigger search on submit
                      ),
                    ),
                    SizedBox(width: 8.0), // Spacing between search field and calendar icon
                    IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.blue),
                      onPressed: _selectDate,
                      tooltip: 'Select Date',
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Loading indicator color
              ))
                  : Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final record = _searchResults[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      color: Colors.amber,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text(
                          'Date: ${record['date']}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        subtitle: Text(
                          'SL No: ${record['slno']} | KMs: ${record['kms']} | Income: ${record['income']} | Paise: ${record['paise'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.black54),
                        ),
                        onTap: () => _navigateToRecordDetailPage(record),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToNewRecordPage,
          child: Icon(Icons.add),
          backgroundColor: Colors.deepPurpleAccent, // Floating Action Button color
          tooltip: 'Add New Record',
        ),
      ),
    );
  }
}