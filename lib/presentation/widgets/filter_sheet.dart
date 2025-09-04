import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/providers/doctor_provider.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _selectedSpecialty = Provider.of<DoctorProvider>(context, listen: false).selectedSpecialty;
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final specialties = doctorProvider.specialties;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter by Specialty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedSpecialty,
            decoration: const InputDecoration(
              labelText: 'Specialty',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Specialties'),
              ),
              ...specialties.map((specialty) {
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(specialty),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSpecialty = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  doctorProvider.filterBySpecialty(_selectedSpecialty);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
              TextButton(
                onPressed: () {
                  doctorProvider.clearFilters();
                  setState(() {
                    _selectedSpecialty = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}