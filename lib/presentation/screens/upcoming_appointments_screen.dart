import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/providers/appointment_provider.dart';
import 'package:patientappointment/core/providers/doctor_provider.dart';
import 'package:patientappointment/presentation/screens/appointment_details_screen.dart';
import 'package:patientappointment/presentation/widgets/appointment_card.dart';

class UpcomingAppointmentsScreen extends StatelessWidget {
  const UpcomingAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);

    final upcomingAppointments = appointmentProvider.upcomingAppointments;

    if (upcomingAppointments.isEmpty) {
      return const Center(
        child: Text('No upcoming appointments'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = upcomingAppointments[index];
        final doctor = doctorProvider.getDoctorById(appointment.doctorId);

        return AppointmentCard(
          appointment: appointment,
          doctor: doctor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentDetailsScreen(
                  appointment: appointment,
                  doctor: doctor,
                ),
              ),
            );
          },
        );
      },
    );
  }
}