import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/providers/appointment_provider.dart';
import 'package:patientappointment/core/providers/doctor_provider.dart';
import 'package:patientappointment/presentation/widgets/appointment_card.dart';

class CompletedAppointmentsScreen extends StatelessWidget {
  const CompletedAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);

    final completedAppointments = appointmentProvider.completedAppointments;

    if (completedAppointments.isEmpty) {
      return const Center(
        child: Text('No completed appointments'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = completedAppointments[index];
        final doctor = doctorProvider.getDoctorById(appointment.doctorId);

        return AppointmentCard(
          appointment: appointment,
          doctor: doctor,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Completed Appointment'),
                content: Text(
                    'This appointment was completed on ${appointment.dateTime.toString()}'),
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