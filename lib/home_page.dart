import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'new_record_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchRecords() async {
    final searchResults = await DBHelper.instance.searchRecordsByDate(_searchController.text);
    setState(() {
      _searchResults = searchResults;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchRecords,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final record = _searchResults[index];
                return ListTile(
                  title: Text('Date: ${record['date']}'),
                  subtitle: Text('SL No: ${record['slno']} | KMs: ${record['kms']} | Income: ${record['income']} | Paise: ${record['paise'] ?? 'N/A'}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewRecordPage,
        child: Icon(Icons.add),
      ),
    );
  }
}
