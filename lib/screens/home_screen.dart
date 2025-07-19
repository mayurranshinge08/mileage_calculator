import 'package:flutter/material.dart';

import '../models/mileage_record.dart';
import '../services/database_service.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _fuelController = TextEditingController();

  String _selectedVehicle = 'Car';
  double? _calculatedMileage;
  bool _isCalculating = false;

  final List<String> _vehicleTypes = ['Car', 'Bike', 'Bus'];
  final DatabaseService _databaseService = DatabaseService();

  @override
  void dispose() {
    _distanceController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  void _calculateMileage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });

      final distance = double.parse(_distanceController.text);
      final fuelUsed = double.parse(_fuelController.text);
      final mileage = distance / fuelUsed;

      // Save to database
      final record = MileageRecord(
        vehicleType: _selectedVehicle,
        distance: distance,
        fuelUsed: fuelUsed,
        mileage: mileage,
        date: DateTime.now(),
      );

      await _databaseService.insertRecord(record);

      setState(() {
        _calculatedMileage = mileage;
        _isCalculating = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mileage calculated and saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _distanceController.clear();
    _fuelController.clear();
    setState(() {
      _calculatedMileage = null;
      _selectedVehicle = 'Car';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mileage Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Type Selection
              Card(
                color: Colors.pink.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Vehicle Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedVehicle,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _vehicleTypes.map((String vehicle) {
                              return DropdownMenuItem<String>(
                                value: vehicle,
                                child: Row(
                                  children: [
                                    Icon(_getVehicleIcon(vehicle)),
                                    const SizedBox(width: 8),
                                    Text(vehicle),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedVehicle = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Input Fields
              Card(
                color: Colors.pink.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // Distance Input
                      TextFormField(
                        controller: _distanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Distance Travelled (km)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten),
                          suffixText: 'km',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter distance';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Fuel Input
                      TextFormField(
                        controller: _fuelController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fuel Used (litres)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_gas_station),
                          suffixText: 'L',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter fuel used';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Calculate Button
              ElevatedButton(
                onPressed: _isCalculating ? null : _calculateMileage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green.shade400,
                ),
                child:
                    _isCalculating
                        ? const CircularProgressIndicator()
                        : const Text(
                          'Calculate Mileage',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
              ),

              const SizedBox(height: 8),

              // Clear Button
              OutlinedButton(
                onPressed: _clearForm,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Clear Form',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Result Display
              if (_calculatedMileage != null)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Mileage Calculated!',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.green.shade700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_calculatedMileage!.toStringAsFixed(2)} km/L',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'for your $_selectedVehicle',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.green.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String vehicle) {
    switch (vehicle) {
      case 'Car':
        return Icons.directions_car;
      case 'Bike':
        return Icons.two_wheeler;
      case 'Bus':
        return Icons.directions_bus;
      default:
        return Icons.directions_car;
    }
  }
}
