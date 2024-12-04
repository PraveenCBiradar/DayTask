import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For date formatting

class NewKMPLRecordPage extends StatefulWidget {
  const NewKMPLRecordPage({Key? key}) : super(key: key);

  @override
  _NewKMPLRecordPageState createState() => _NewKMPLRecordPageState();
}

class _NewKMPLRecordPageState extends State<NewKMPLRecordPage> {
  final TextEditingController _fuelController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(); // For date input
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double? _calculatedMileage;

  @override
  void dispose() {
    _fuelController.dispose();
    _distanceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _calculateMileage() {
    if (_formKey.currentState!.validate()) {
      final double fuel = double.parse(_fuelController.text);
      final double distance = double.parse(_distanceController.text);

      setState(() {
        _calculatedMileage = distance / fuel;
      });
    }
  }

  void _saveRecord() {
    if (_calculatedMileage != null) {
      _showSuccessMessage('Record saved successfully!');
      Navigator.pop(context);
    } else {
      _showErrorMessage('Please calculate the mileage before saving.');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Restricts future dates
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New KMPL Record'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDateInputField(),
                const SizedBox(height: 16),
                _buildFuelTextField(),
                const SizedBox(height: 16),
                _buildDistanceTextField(),
                const SizedBox(height: 16),
                _buildCalculateMileageButton(),
                const SizedBox(height: 16),
                _buildMileageDisplay(),
                const SizedBox(height: 24),
                _buildSaveRecordButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInputField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: _selectDate,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget _buildFuelTextField() {
    return TextFormField(
      controller: _fuelController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Fuel Added (in liters)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.local_gas_station),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter fuel amount';
        }
        final fuel = double.tryParse(value);
        if (fuel == null || fuel <= 0) {
          return 'Please enter a valid fuel amount';
        }
        return null;
      },
    );
  }

  Widget _buildDistanceTextField() {
    return TextFormField(
      controller: _distanceController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Distance Traveled (in km)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.speed),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter distance traveled';
        }
        final distance = double.tryParse(value);
        if (distance == null || distance <= 0) {
          return 'Please enter a valid distance';
        }
        return null;
      },
    );
  }

  Widget _buildCalculateMileageButton() {
    return ElevatedButton(
      onPressed: _calculateMileage,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A237E),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: const Text(
        'Calculate Mileage',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMileageDisplay() {
    return _calculatedMileage != null
        ? Text(
      'Mileage: ${_calculatedMileage!.toStringAsFixed(2)} km/l',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
      textAlign: TextAlign.center,
    )
        : const SizedBox.shrink();
  }

  Widget _buildSaveRecordButton() {
    return ElevatedButton(
      onPressed: _saveRecord,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Save Record',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
