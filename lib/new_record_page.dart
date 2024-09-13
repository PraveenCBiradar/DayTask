// new_record_page.dart

import 'package:flutter/material.dart';
import 'db_helper.dart';

class NewRecordPage extends StatefulWidget {
  @override
  _NewRecordPageState createState() => _NewRecordPageState();
}

class _NewRecordPageState extends State<NewRecordPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _slnoController = TextEditingController();
  final TextEditingController _kmsController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _paiseController = TextEditingController();
  bool _isConfirmed = false;

  Future<void> _saveRecord() async {
    try {
      await DBHelper.instance.addRecord(
        date: _dateController.text,
        slno: int.parse(_slnoController.text),
        kms: int.parse(_kmsController.text),
        income: int.parse(_incomeController.text),
        paise: _paiseController.text.isNotEmpty ? int.parse(_paiseController.text) : null,
        isConfirmed: _isConfirmed,
      );
      Navigator.pop(context); // Return to previous screen
    } catch (e) {
      // Handle error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Record'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _slnoController,
              decoration: InputDecoration(labelText: 'SL No'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _kmsController,
              decoration: InputDecoration(labelText: 'KMs'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _incomeController,
              decoration: InputDecoration(labelText: 'Income'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _paiseController,
              decoration: InputDecoration(labelText: 'Paise (optional)'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Text('Confirmed'),
                Checkbox(
                  value: _isConfirmed,
                  onChanged: (value) {
                    setState(() {
                      _isConfirmed = value ?? false;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRecord,
              child: Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }
}
