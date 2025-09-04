import 'package:flutter/material.dart';
import 'package:patientappointment/core/models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(doctor.avatarUrl),
          radius: 25,
        ),
        title: Text(
          doctor.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(doctor.specialty),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}