import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:patientappointment/core/models/appointment_model.dart';
import 'package:patientappointment/core/models/doctor_model.dart';
import 'package:patientappointment/core/providers/appointment_provider.dart';
import 'package:patientappointment/presentation/screens/select_date_time_screen.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;
  final Doctor? doctor;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
    this.doctor,
  });

  @override
  Widget build(BuildContext context) {

    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doctor != null)
              Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage(doctor?.avatarUrl ?? 'assets/avatars/default_avatar.png'),
                  radius: 50,
                ),
              ),
            if (doctor != null) const SizedBox(height: 20),
            if (doctor != null)
              Text(
                doctor?.name ?? 'Unknown Doctor',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            if (doctor != null)
              Text(
                doctor?.specialty ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            if (doctor != null) const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _buildDetailRow('Patient Name', appointment.patientName),
            _buildDetailRow('Patient Phone', appointment.patientPhone),
            _buildDetailRow('Date', DateFormat.yMMMMd().format(appointment.dateTime)),
            _buildDetailRow('Time', DateFormat.jm().format(appointment.dateTime)),
            _buildDetailRow('Status', _formatStatus(appointment.status)),
            _buildDetailRow('Booked On', DateFormat.yMMMMd().add_jm().format(appointment.createdAt)),
            const Spacer(),
            if (appointment.status == AppointmentStatus.pending ||
                appointment.status == AppointmentStatus.approved)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (doctor == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Doctor details not available for rescheduling.")),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectDateTimeScreen(
                              doctor: doctor!,
                              existingAppointment: appointment,
                            ),
                          ),
                        );
                      },
                      child: const Text('Reschedule'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) => AlertDialog(
                            title: const Text('Cancel Appointment'),
                            content: const Text('Are you sure you want to cancel this appointment?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  appointmentProvider.deleteAppointment(appointment.id);
                                  Navigator.pop(dialogContext);
                                  Navigator.pop(context);
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatStatus(AppointmentStatus status) {
    return status.name[0].toUpperCase() + status.name.substring(1);
  }
}
