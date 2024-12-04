import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isShara = false;
  double _calculatedPaise = 0.0;

  @override
  void initState() {
    super.initState();

    // Add listeners to calculate paise dynamically
    _kmsController.addListener(_calculatePaise);
    _incomeController.addListener(_calculatePaise);
  }

  void _calculatePaise() {
    try {
      double kms = double.tryParse(_kmsController.text) ?? 0.0; // Optional decimal
      double income = double.tryParse(_incomeController.text) ?? 0.0; // Optional decimal

      setState(() {
        _calculatedPaise = kms > 0 ? income / kms : 0.0;
        _paiseController.text = _calculatedPaise.toStringAsFixed(2);
      });
    } catch (e) {
      setState(() {
        _paiseController.text = '0.00';
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime currentDate = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: currentDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.indigo,
            colorScheme: ColorScheme.light(primary: Colors.indigo),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
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

  Future<void> _saveRecord() async {
    try {
      await DBHelper.instance.addRecord(
        date: _dateController.text,
        slno: int.parse(_slnoController.text), // Accepting '/' in SL No
        kms: double.parse(_kmsController.text.isEmpty ? "0" : _kmsController.text),
        income: double.parse(_incomeController.text.isEmpty ? "0" : _incomeController.text),
        paise: _calculatedPaise,
        isConfirmed: _isShara,
      );
      Navigator.pop(context);
    } catch (e) {
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
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade200, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _dateController,
                      label: 'Date',
                      icon: Icons.calendar_today,
                      onTap: _selectDate,
                      readOnly: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _slnoController,
                      label: 'SL No',
                      icon: Icons.format_list_numbered,
                      keyboardType: TextInputType.number, // Updated for numeric input
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _kmsController,
                      label: 'KMs',
                      icon: Icons.speed,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _incomeController,
                      label: 'Income (₹)',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _paiseController,
                      label: 'Paise (Auto-calculated)',
                      icon: Icons.currency_rupee,
                      readOnly: true, // Make paise read-only
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text('Shara', style: TextStyle(fontSize: 16)),
                        Spacer(),
                        Switch(
                          value: _isShara,
                          onChanged: (value) {
                            setState(() {
                              _isShara = value;
                            });
                          },
                          activeColor: Colors.indigo,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveRecord,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Save Record', style: TextStyle(fontSize: 18)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.indigo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: keyboardType,
      onTap: onTap,
      readOnly: readOnly,
    );
  }

  @override
  void dispose() {
    _kmsController.removeListener(_calculatePaise);
    _incomeController.removeListener(_calculatePaise);
    super.dispose();
  }
}
