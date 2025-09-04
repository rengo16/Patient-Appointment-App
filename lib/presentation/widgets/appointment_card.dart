import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patientappointment/core/models/appointment_model.dart';
import 'package:patientappointment/core/models/doctor_model.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Doctor? doctor;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.doctor,
    required this.onTap,
  });

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.approved:
        return Colors.green;
      case AppointmentStatus.declined:
        return Colors.red;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.canceled:
        return Colors.grey;
      case AppointmentStatus.missed:
        return Colors.purple;
    }
  }

  String _formatStatus(AppointmentStatus status) {
    return status.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: doctor != null
            ? CircleAvatar(
          backgroundImage: AssetImage(doctor!.avatarUrl),
          radius: 25,
        )
            : const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(
          doctor?.name ?? 'Unknown Doctor',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('EEE, MMM d, y • h:mm a').format(appointment.dateTime),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatStatus(appointment.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}