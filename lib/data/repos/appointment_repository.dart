
import 'package:intl/intl.dart';
import 'package:patientappointment/core/models/appointment_model.dart';
import 'package:patientappointment/core/services/local_storage_service.dart';

class AppointmentRepository {
  AppointmentRepository();

  List<Appointment> getAllAppointments() {
    final appointments = LocalStorageService.appointmentsBox.values.toList();
    print("REPO - getAllAppointments: Found ${appointments.length} total appointments in Hive.");
    for (var appt in appointments) {
      print("REPO --- Appt ID: ${appt.id}, Patient: ${appt.patientName}, DateTime: ${DateFormat('yyyy-MM-dd HH:mm').format(appt.dateTime.toLocal())}, Status: ${appt.status}, UserID: ${appt.userId}");
    }
    return appointments;
  }

  List<Appointment> getAppointmentsByStatus(AppointmentStatus status) {
    return getAllAppointments().where((appt) => appt.status == status).toList();
  }

  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    return getAllAppointments().where((appt) =>
    (appt.status == AppointmentStatus.pending || appt.status == AppointmentStatus.approved) &&
        appt.dateTime.isAfter(now)
    ).toList();
  }

  List<Appointment> getMissedAppointments() {
    final now = DateTime.now();
    return getAllAppointments().where((appt) =>
    (appt.status == AppointmentStatus.pending || appt.status == AppointmentStatus.approved) &&
        appt.dateTime.isBefore(now) &&
        appt.status != AppointmentStatus.completed
    ).toList();
  }

  List<Appointment> getCompletedAppointments() {
    return getAllAppointments().where((appt) =>
    appt.status == AppointmentStatus.completed
    ).toList();
  }

  Future<void> addAppointment(Appointment appointment) async {
    await LocalStorageService.appointmentsBox.put(appointment.id, appointment);
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await LocalStorageService.appointmentsBox.put(appointment.id, appointment);
  }

  Future<void> deleteAppointment(String id) async {
    await LocalStorageService.appointmentsBox.delete(id);
  }

  bool isDoctorAvailable(String doctorId, DateTime dateTime) {
    final appointments = getAllAppointments().where((appt) =>
    appt.doctorId == doctorId &&
        appt.dateTime.year == dateTime.year &&
        appt.dateTime.month == dateTime.month &&
        appt.dateTime.day == dateTime.day &&
        appt.dateTime.hour == dateTime.hour &&
        appt.dateTime.minute == dateTime.minute &&
        (appt.status == AppointmentStatus.pending || appt.status == AppointmentStatus.approved)
    ).toList();
    return appointments.isEmpty;
  }
}

