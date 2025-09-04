
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patientappointment/core/models/doctor_model.dart';

class ConfirmBookingDialog extends StatelessWidget {
  final Doctor doctor;
  final DateTime dateTime;
  final String patientName;
  final String patientPhone;

  const ConfirmBookingDialog({
    super.key,
    required this.doctor,
    required this.dateTime,
    required this.patientName,
    required this.patientPhone,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Booking'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Doctor: ${doctor.name}'),
            Text('Specialty: ${doctor.specialty}'),
            const SizedBox(height: 8),
            Text('Date: ${DateFormat.yMMMMd().format(dateTime)}'),
            Text('Time: ${DateFormat.jm().format(dateTime)}'),
            const SizedBox(height: 8),
            Text('Patient: $patientName'),
            Text('Phone: $patientPhone'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        ElevatedButton(
          child: const Text('Confirm Booking'),
          onPressed: () {
            Navigator.of(context).pop(true);

          },
        ),
      ],
    );
  }
}
