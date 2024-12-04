import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';
import 'new_record_page.dart';
import 'record_detail_page.dart';
import 'profile_page.dart';
import 'about_us_page.dart';
import 'help_page.dart';
import 'settings_page.dart';
import 'overtime_page.dart';
import 'newkmplrecord_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isDarkMode = false;
  String _currentOvertime = '0.0';

  // Existing methods remain the same...
  Future<void> _searchRecords() async {
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a date'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final searchResults = await DBHelper.instance.searchRecordsByDate(_dateController.text);

      setState(() {
        _searchResults = searchResults;
        _calculateCurrentOvertime();
      });

      _showSearchResultsDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching records: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showSearchResultsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Search Results',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          content: _searchResults.isEmpty
              ? Text(
            'No records found for the selected date.',
            style: TextStyle(color: Colors.grey),
          )
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _searchResults.map((record) {
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      'Date: ${record['date'] ?? 'N/A'}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Time: ${record['time'] ?? 'N/A'} hours',
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF1A237E),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecordDetailPage(record: record),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Other existing methods remain the same...
  void _calculateCurrentOvertime() {
    double totalTime = 0;
    double totalOff = 0;

    for (var record in _searchResults) {
      totalTime += double.tryParse(record['time'] ?? '0.0') ?? 0.0;
      totalOff += double.tryParse(record['off'] ?? '0.0') ?? 0.0;
    }

    setState(() {
      _currentOvertime = (totalTime - totalOff).toStringAsFixed(2);
    });
  }

  Future<void> _selectDate() async {
    DateTime currentDate = DateTime.now();
    DateTime initialDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: currentDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF1A237E),
          secondary: Color(0xFF1A237E),
        ),
      )
          : ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF1A237E),
          secondary: Color(0xFF1A237E),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Work Tracker',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF1A237E),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () {}, // Logout method
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[100]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                // Search Container with Enhanced Design
                Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            hintText: 'YYYY-MM-DD',
                            labelText: 'Search Date',
                            prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF1A237E)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFF1A237E).withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFF1A237E),
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Color(0xFF1A237E)),
                        onPressed: _selectDate,
                        tooltip: 'Select Date',
                      ),
                      IconButton(
                        icon: Icon(Icons.search, color: Color(0xFF1A237E)),
                        onPressed: _searchRecords,
                        tooltip: 'Search Records',
                      ),
                    ],
                  ),
                ),

                // Quick Actions Container with Enhanced Design
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  padding: EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickActionButton(
                            icon: Icons.search,
                            label: 'Search',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    title: Text('Search Records'),
                                    content: TextField(
                                      controller: _dateController,
                                      decoration: InputDecoration(
                                        hintText: 'YYYY-MM-DD',
                                        labelText: 'Enter Date',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF1A237E),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _searchRecords();
                                        },
                                        child: Text('Search'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            icon: Icons.access_time,
                            label: 'EPKM',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => NewRecordPage()),
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            icon: Icons.electric_meter_rounded,
                            label: 'KMPL',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => NewKMPLRecordPage()),
                              );
                            },
                          ),

                          _buildQuickActionButton(
                            icon: Icons.bus_alert,
                            label: 'MECH',
                            onTap: () {}, // Navigate to MECH page
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1A237E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF1A237E).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 28,
                color: Color(0xFF1A237E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A237E),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}