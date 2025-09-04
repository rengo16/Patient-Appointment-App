import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/providers/appointment_provider.dart';
import 'package:patientappointment/core/providers/doctor_provider.dart';
import 'package:patientappointment/presentation/widgets/appointment_card.dart';

class MissedAppointmentsScreen extends StatelessWidget {
  const MissedAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);

    final missedAppointments = appointmentProvider.missedAppointments;

    if (missedAppointments.isEmpty) {
      return const Center(
        child: Text('No missed appointments'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = missedAppointments[index];
        final doctor = doctorProvider.getDoctorById(appointment.doctorId);

        return AppointmentCard(
          appointment: appointment,
          doctor: doctor,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Missed Appointment'),
                content: Text(
                    'This appointment was missed on ${appointment.dateTime.toString()}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}