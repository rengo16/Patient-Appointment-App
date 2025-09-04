
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:patientappointment/core/providers/appointment_provider.dart';
import 'package:patientappointment/core/providers/doctor_provider.dart';
import 'package:patientappointment/core/models/appointment_model.dart';
import 'package:patientappointment/core/models/doctor_model.dart';

class DoctorAdminScreen extends StatelessWidget {
  const DoctorAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);

    final List<Appointment> todayAppointments = appointmentProvider.todaysAppointmentsForAdmin;
    print("ADMIN_SCREEN - Build method called. Listening to provider.isLoading: ${appointmentProvider.isLoading}");
    print("ADMIN_SCREEN - todayAppointments count from provider getter: ${todayAppointments.length}");
    for (var appt in todayAppointments) {
      print("ADMIN_SCREEN --- Appt for ${appt.patientName}, Status: ${appt.status}, DateTime: ${DateFormat('yyyy-MM-dd HH:mm').format(appt.dateTime.toLocal())}, UserID: ${appt.userId}");
    }
    final pendingCount = todayAppointments.where((a) => a.status == AppointmentStatus.pending).length;
    print("ADMIN_SCREEN - Pending actions count (calculated in build from todayAppointments): $pendingCount");

    if (appointmentProvider.isLoading && todayAppointments.isEmpty) {
      print("ADMIN_SCREEN - Showing loading indicator.");
      return const Center(child: CircularProgressIndicator());
    }

    if (appointmentProvider.errorMessage != null && todayAppointments.isEmpty) {
      print("ADMIN_SCREEN - Showing error: ${appointmentProvider.errorMessage}");
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Error: ${appointmentProvider.errorMessage}", textAlign: TextAlign.center),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Today's Dashboard",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${todayAppointments.length} total appointments today.",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$pendingCount pending actions.",
                    style: TextStyle(fontSize: 15, color: Colors.orange[700]),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (todayAppointments.isEmpty && !appointmentProvider.isLoading)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy_outlined, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      "No appointments scheduled for today.",
                      style: TextStyle(fontSize: 17, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 70),
              itemCount: todayAppointments.length,
              itemBuilder: (context, index) {
                final appointment = todayAppointments[index];
                final Doctor? doctor = doctorProvider.getDoctorById(appointment.doctorId);
                ImageProvider? doctorAvatar;
                bool hasValidAvatar = false;
                if (doctor != null && doctor.avatarUrl.isNotEmpty) {
                  if (doctor.avatarUrl.startsWith('assets/')) {
                    doctorAvatar = AssetImage(doctor.avatarUrl);
                    hasValidAvatar = true;
                  } else if (doctor.avatarUrl.startsWith('http')) {
                    doctorAvatar = NetworkImage(doctor.avatarUrl);
                    hasValidAvatar = true;
                  }
                }


                return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: hasValidAvatar ? doctorAvatar : null,
                                onBackgroundImageError: (exception, stackTrace) {

                                  print("Error loading doctor avatar in admin: ${doctor?.avatarUrl} - $exception");
                                },
                                child: !hasValidAvatar
                                    ? const Icon(Icons.medical_services_outlined, size: 22)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  doctor?.name ?? 'Unknown Doctor',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: _getStatusColor(appointment.status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _getStatusColor(appointment.status), width: 0.5)
                                ),
                                child: Text(
                                  _formatStatus(appointment.status).toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(appointment.status),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16, thickness: 0.5),
                          Text(
                            'Patient: ${appointment.patientName}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Time: ${DateFormat('h:mm a').format(appointment.dateTime.toLocal())}',
                            style: const TextStyle(fontSize: 15, color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Booked by User ID: ${appointment.userId}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          if (appointment.status == AppointmentStatus.pending || appointment.status == AppointmentStatus.approved)
                            _buildActionButtons(context, appointmentProvider, appointment),
                        ],
                      ),
                    )
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppointmentProvider appointmentProvider, Appointment appointment) {
    List<Widget> buttons = [];
    if (appointment.status == AppointmentStatus.pending) {
      buttons.addAll([
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Approve'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 13)
          ),
          onPressed: () {
            _showConfirmationDialog(
              context,
              title: "Approve Appointment",
              content: "Are you sure you want to approve this appointment for ${appointment.patientName} at ${DateFormat('h:mm a').format(appointment.dateTime.toLocal())}?",
              onConfirm: () {
                appointmentProvider.updateAppointmentStatus(
                  appointment.id,
                  AppointmentStatus.approved,
                );
              },
            );
          },
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.cancel_outlined, size: 18),
          label: const Text('Decline'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 13)
          ),
          onPressed: () {
            _showConfirmationDialog(
              context,
              title: "Decline Appointment",
              content: "Are you sure you want to decline this appointment for ${appointment.patientName}?",
              onConfirm: () {
                appointmentProvider.updateAppointmentStatus(
                  appointment.id,
                  AppointmentStatus.declined,
                );
              },
            );
          },
        ),
      ]);
    } else if (appointment.status == AppointmentStatus.approved) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.done_all_outlined, size: 18),
          label: const Text('Mark Completed'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 13)
          ),
          onPressed: () {
            _showConfirmationDialog(
              context,
              title: "Complete Appointment",
              content: "Mark this appointment for ${appointment.patientName} as completed?",
              onConfirm: () {
                appointmentProvider.updateAppointmentStatus(
                  appointment.id,
                  AppointmentStatus.completed,
                );
              },
            );
          },
        ),
      );
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: buttons,
    );
  }

  void _showConfirmationDialog(BuildContext context, {required String title, required String content, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: Text(title.split(" ")[0]),
              onPressed: () {
                onConfirm();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending: return Colors.orange.shade700;
      case AppointmentStatus.approved: return Colors.green.shade700;
      case AppointmentStatus.declined: return Colors.red.shade700;
      case AppointmentStatus.completed: return Colors.blue.shade700;
      case AppointmentStatus.canceled: return Colors.grey.shade700;
      case AppointmentStatus.missed: return Colors.purple.shade700;
      default: return Colors.black;
    }
  }

  String _formatStatus(AppointmentStatus status) {
    String name = status.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }
}

