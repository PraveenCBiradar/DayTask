import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OvertimePage extends StatefulWidget {
  @override
  _OvertimePageState createState() => _OvertimePageState();
}

class _OvertimePageState extends State<OvertimePage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _offTimeController = TextEditingController();

  bool _isOnLeave = false;
  bool _noOvertime = false;
  String? _errorMessage;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: currentDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (pickedDate.isAfter(currentDate)) {
        setState(() {
          _errorMessage = 'Future dates are not allowed';
        });
      } else {
        setState(() {
          _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          _errorMessage = null;
        });
      }
    }
  }

  void _saveData() {
    if (_dateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Date is required';
      });
      return;
    }

    // Implement your save logic here
    print('Saving data: {date: ${_dateController.text}, hours: ${_hoursController.text}, '
        'offTime: ${_offTimeController.text}, isOnLeave: $_isOnLeave, noOvertime: $_noOvertime}');

    // Navigate back to the dashboard after saving data
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overtime Entry'),
        backgroundColor: Colors.blue.shade600,
        // Back arrow to go back to the previous screen (Dashboard)
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when arrow is pressed
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Field (Required)
                          Text(
                            'Date *',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Select Date',
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.blue.shade200),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.calendar_today, color: Colors.blue),
                                onPressed: () => _pickDate(context),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Hours Field (Optional)
                          Text(
                            'Hours (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _hoursController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter Hours',
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.blue.shade200),
                              ),
                              suffixIcon: Icon(Icons.access_time, color: Colors.blue),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Off Time Field (Optional)
                          Text(
                            'Off Time (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _offTimeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter Off Time',
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.blue.shade200),
                              ),
                              suffixIcon: Icon(Icons.power_settings_new, color: Colors.blue),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Status Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isOnLeave = !_isOnLeave;
                                      if (_isOnLeave) _noOvertime = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isOnLeave
                                        ? Colors.blue.shade600
                                        : Colors.blue.shade100,
                                    foregroundColor: _isOnLeave
                                        ? Colors.white
                                        : Colors.blue.shade800,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('On Leave'),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _noOvertime = !_noOvertime;
                                      if (_noOvertime) _isOnLeave = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _noOvertime
                                        ? Colors.blue.shade600
                                        : Colors.blue.shade100,
                                    foregroundColor: _noOvertime
                                        ? Colors.white
                                        : Colors.blue.shade800,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('No OT'),
                                ),
                              ),
                            ],
                          ),

                          // Error Message
                          if (_errorMessage != null) ...[
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: Colors.red.shade800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Submit Button
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Submit Entry',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _hoursController.dispose();
    _offTimeController.dispose();
    super.dispose();
  }
}
