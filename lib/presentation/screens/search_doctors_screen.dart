import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/providers/doctor_provider.dart';
import 'package:patientappointment/presentation/screens/doctor_profile_screen.dart';
import 'package:patientappointment/presentation/widgets/doctor_card.dart';
import 'package:patientappointment/presentation/widgets/filter_sheet.dart';

class SearchDoctorsScreen extends StatefulWidget {
  const SearchDoctorsScreen({super.key});

  @override
  State<SearchDoctorsScreen> createState() => _SearchDoctorsScreenState();
}

class _SearchDoctorsScreenState extends State<SearchDoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<DoctorProvider>(context, listen: false)
        .searchDoctors(_searchController.text);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final doctors = doctorProvider.doctors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search doctors...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return DoctorCard(
                doctor: doctor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorProfileScreen(doctor: doctor),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}