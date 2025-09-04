// lib/core/providers/appointment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:patientappointment/core/models/appointment_model.dart';
import 'package:patientappointment/data/repos/appointment_repository.dart';
import 'package:patientappointment/core/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:patientappointment/core/providers/auth_provider.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentRepository _appointmentRepository;
  final AuthProvider _authProvider;

  List<Appointment> _allUserAppointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  AppointmentProvider(this._appointmentRepository, this._authProvider) {
    _authProvider.addListener(_onAuthStateChanged);
    _loadCurrentUserAppointments();
  }

  void _onAuthStateChanged() {
    // --- DEBUG PRINT (Temporary) ---
    print("PROVIDER - _onAuthStateChanged: User: ${_authProvider.currentUser?.id}, isAdmin: ${_authProvider.currentUser?.isAdmin}");
    // --- END DEBUG PRINT ---
    if (_authProvider.currentUser != null && !_authProvider.currentUser!.isAdmin) {
      _loadCurrentUserAppointments();
    } else {
      _allUserAppointments = [];
      notifyListeners(); // Notify UI that patient list might be cleared
      print("PROVIDER - User is admin or null, patient-specific list (_allUserAppointments) cleared.");
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  List<Appointment> get appointments => _allUserAppointments;

  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    return appointments.where((appt) =>
    (appt.status == AppointmentStatus.pending || appt.status == AppointmentStatus.approved) &&
        appt.dateTime.isAfter(now)
    ).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Appointment> get completedAppointments {
    return appointments.where((appt) => appt.status == AppointmentStatus.completed).toList();
  }

  List<Appointment> get missedAppointments {
    final now = DateTime.now();
    return appointments.where((appt) =>
    (appt.status == AppointmentStatus.pending || appt.status == AppointmentStatus.approved) &&
        appt.dateTime.isBefore(now) &&
        appt.status != AppointmentStatus.completed
    ).toList();
  }

  List<Appointment> get allAppointmentsForAdmin {
    final all = _appointmentRepository.getAllAppointments();
    // --- DEBUG PRINT (Temporary) ---
    print("PROVIDER - allAppointmentsForAdmin: Total count from repo = ${all.length}");
    // --- END DEBUG PRINT ---
    return all;
  }

  List<Appointment> get todaysAppointmentsForAdmin {
    final now = DateTime.now();
    final allAdminAppointments = allAppointmentsForAdmin; // Use the getter

    // --- DEBUG PRINT (Temporary) ---
    print("PROVIDER - todaysAppointmentsForAdmin: Today's Date (Provider View) = ${DateFormat('yyyy-MM-dd').format(now)}");
    print("PROVIDER - todaysAppointmentsForAdmin: ALL admin appointments count before filtering for today: ${allAdminAppointments.length}");
    // --- END DEBUG PRINT ---

    final result = allAdminAppointments.where((appt) {
      bool isToday = appt.dateTime.year == now.year &&
          appt.dateTime.month == now.month &&
          appt.dateTime.day == now.day;
      // --- DEBUG PRINT (Temporary) ---
      // Uncomment to see details of each appt during filtering for today
      // print("PROVIDER - todaysAppointmentsForAdmin - Checking Appt ID: ${appt.id}, Patient: ${appt.patientName}, Appt Date: ${DateFormat('yyyy-MM-dd HH:mm').format(appt.dateTime.toLocal())}, Status: ${appt.status}, IsToday: $isToday");
      // --- END DEBUG PRINT ---
      return isToday;
    }).toList()..sort((a,b) => a.dateTime.compareTo(b.dateTime));

    // --- DEBUG PRINT (Temporary) ---
    print("PROVIDER - todaysAppointmentsForAdmin: Count AFTER filtering for today = ${result.length}");
    for (var appt in result) {
      print("PROVIDER - todaysAppointmentsForAdmin - INCLUDED: Appt ID: ${appt.id}, Patient: ${appt.patientName}, Appt Date: ${DateFormat('yyyy-MM-dd HH:mm').format(appt.dateTime.toLocal())}, Status: ${appt.status}");
    }
    // --- END DEBUG PRINT ---
    return result;
  }

  List<Appointment> get pendingAppointmentsForAdmin {
    final pending = allAppointmentsForAdmin.where((appt) => appt.status == AppointmentStatus.pending).toList();
    // --- DEBUG PRINT (Temporary) ---
    print("PROVIDER - pendingAppointmentsForAdmin: Count = ${pending.length}");
    // for (var appt in pending) {
    //   print("PROVIDER - pendingAppointmentsForAdmin - Appt ID: ${appt.id}, Patient: ${appt.patientName}, Status: ${appt.status}");
    // }
    // --- END DEBUG PRINT ---
    return pending;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadCurrentUserAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final currentUser = _authProvider.currentUser;

    if (currentUser == null || currentUser.isAdmin) {
      print("PROVIDER - _loadCurrentUserAppointments: No current patient or user is admin. Clearing patient list.");
      _allUserAppointments = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    print("PROVIDER - _loadCurrentUserAppointments: Loading for patient: ${currentUser.id}");
    try {
      final allAppointmentsFromRepo = _appointmentRepository.getAllAppointments(); // Get all
      _allUserAppointments = allAppointmentsFromRepo
          .where((appt) => appt.userId == currentUser.id) // Filter for current user
          .toList();
      print("PROVIDER - _loadCurrentUserAppointments: Loaded ${allAppointmentsFromRepo.length} raw from repo, then filtered to ${_allUserAppointments.length} for patient ${currentUser.id}");
    } catch (e) {
      _errorMessage = "Failed to load appointments for patient: ${e.toString()}";
      _allUserAppointments = [];
      print("PROVIDER - _loadCurrentUserAppointments: Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAppointment({
    required String doctorId,
    required DateTime dateTime,
  }) async {
    final currentUser = _authProvider.currentUser;
    if (currentUser == null || currentUser.isAdmin) {
      _errorMessage = "Only patients can book appointments.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final newAppointment = Appointment.create(
      doctorId: doctorId,
      patientName: currentUser.name,
      patientPhone: currentUser.phone,
      dateTime: dateTime,
      currentUserId: currentUser.id,
    );

    try {
      await _appointmentRepository.addAppointment(newAppointment);
      if (!currentUser.isAdmin && _authProvider.currentUser?.id == newAppointment.userId) {
        _allUserAppointments.add(newAppointment);
      }
      // --- DEBUG PRINT (Temporary) ---
      print("PROVIDER - addAppointment: Successfully added Appt ID: ${newAppointment.id} for user ${currentUser.id}. DateTime: ${DateFormat('yyyy-MM-dd HH:mm').format(newAppointment.dateTime.toLocal())}, Status: ${newAppointment.status}");
      // --- END DEBUG PRINT ---

      final scheduledTime = tz.TZDateTime.from(newAppointment.dateTime, tz.local);
      if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
        await NotificationService().scheduleNotification(
          id: newAppointment.notificationId,
          title: 'Appointment Reminder',
          body: 'Appointment for ${newAppointment.patientName} at ${DateFormat.yMMMMd().add_jm().format(newAppointment.dateTime.toLocal())}',
          scheduledDateTime: scheduledTime,
          payload: 'appointment_id=${newAppointment.id}',
        );
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Failed to add appointment: ${e.toString()}";
      print("PROVIDER - addAppointment: Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Appointment? appointmentToUpdate;
      int appointmentIndexInUserList = -1;
      bool isAdminUpdate = _authProvider.currentUser?.isAdmin ?? false;

      // --- DEBUG PRINT (Temporary) ---
      print("PROVIDER - updateAppointmentStatus: Called for Appt ID: $appointmentId, New Status: $newStatus, isAdmin: $isAdminUpdate");
      // --- END DEBUG PRINT ---

      if (isAdminUpdate) {
        final allAppointments = _appointmentRepository.getAllAppointments();
        final originalIndexInAll = allAppointments.indexWhere((app) => app.id == appointmentId);
        if (originalIndexInAll != -1) {
          appointmentToUpdate = allAppointments[originalIndexInAll];
        }
      } else {
        appointmentIndexInUserList = _allUserAppointments.indexWhere((app) => app.id == appointmentId);
        if (appointmentIndexInUserList != -1) {
          appointmentToUpdate = _allUserAppointments[appointmentIndexInUserList];
        }
      }

      if (appointmentToUpdate == null) {
        _errorMessage = "Appointment not found for update.";
        print("PROVIDER - updateAppointmentStatus: Appointment $appointmentId not found for update.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      Appointment oldAppointment = appointmentToUpdate;

      if ((oldAppointment.status == AppointmentStatus.pending || oldAppointment.status == AppointmentStatus.approved) &&
          (newStatus != AppointmentStatus.pending && newStatus != AppointmentStatus.approved)) {
        await NotificationService().cancelNotification(oldAppointment.notificationId);
      }

      final updatedAppointmentData = oldAppointment.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      await _appointmentRepository.updateAppointment(updatedAppointmentData);

      if (!isAdminUpdate && appointmentIndexInUserList != -1) {
        _allUserAppointments[appointmentIndexInUserList] = updatedAppointmentData;
      }

      if ((newStatus == AppointmentStatus.approved || newStatus == AppointmentStatus.pending) &&
          updatedAppointmentData.dateTime.isAfter(DateTime.now())) {
        final scheduledTime = tz.TZDateTime.from(updatedAppointmentData.dateTime, tz.local);
        if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
          await NotificationService().cancelNotification(updatedAppointmentData.notificationId);
          await NotificationService().scheduleNotification(
            id: updatedAppointmentData.notificationId,
            title: 'Appointment ${newStatus.name}',
            body: 'Appointment for ${updatedAppointmentData.patientName} at ${DateFormat.yMMMMd().add_jm().format(updatedAppointmentData.dateTime.toLocal())} is now ${newStatus.name}.',
            scheduledDateTime: scheduledTime,
            payload: 'appointment_id=${updatedAppointmentData.id}',
          );
        }
      }
      _errorMessage = null;
      print("PROVIDER - updateAppointmentStatus: Successfully updated Appt ID: $appointmentId to $newStatus");
    } catch (e) {
      _errorMessage = "Failed to update appointment status: ${e.toString()}";
      print("PROVIDER - updateAppointmentStatus: Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rescheduleAppointment(String appointmentId, DateTime newDateTime) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Appointment? appointmentToReschedule;
      int appointmentIndexInUserList = -1;
      bool isAdminUpdate = _authProvider.currentUser?.isAdmin ?? false;
      String? patientUserIdForNotification;

      // --- DEBUG PRINT (Temporary) ---
      print("PROVIDER - rescheduleAppointment: Called for Appt ID: $appointmentId, New DateTime: $newDateTime, isAdmin: $isAdminUpdate");
      // --- END DEBUG PRINT ---

      if (isAdminUpdate) {
        final allAppointments = _appointmentRepository.getAllAppointments();
        final originalIndexInAll = allAppointments.indexWhere((app) => app.id == appointmentId);
        if (originalIndexInAll != -1) {
          appointmentToReschedule = allAppointments[originalIndexInAll];
          patientUserIdForNotification = appointmentToReschedule.userId;
        }
      } else {
        final currentUserId = _authProvider.currentUser?.id;
        if(currentUserId == null) {
          _errorMessage = "User not logged in for reschedule.";
          _isLoading = false;
          notifyListeners();
          return;
        }
        appointmentIndexInUserList = _allUserAppointments.indexWhere((app) => app.id == appointmentId && app.userId == currentUserId);
        if (appointmentIndexInUserList != -1) {
          appointmentToReschedule = _allUserAppointments[appointmentIndexInUserList];
          patientUserIdForNotification = currentUserId;
        }
      }

      if (appointmentToReschedule == null) {
        _errorMessage = "Appointment not found or not authorized for reschedule.";
        print("PROVIDER - rescheduleAppointment: Appointment $appointmentId not found or not authorized.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      Appointment oldAppointment = appointmentToReschedule;
      await NotificationService().cancelNotification(oldAppointment.notificationId);

      final newNotificationId = DateTime.now().millisecondsSinceEpoch % 1000000;

      final updatedAppointmentData = oldAppointment.copyWith(
        dateTime: newDateTime,
        status: AppointmentStatus.approved,
        updatedAt: DateTime.now(),
        notificationId: newNotificationId,
      );

      await _appointmentRepository.updateAppointment(updatedAppointmentData);

      if (!isAdminUpdate && appointmentIndexInUserList != -1) {
        _allUserAppointments[appointmentIndexInUserList] = updatedAppointmentData;
      }

      final scheduledTime = tz.TZDateTime.from(updatedAppointmentData.dateTime, tz.local);
      if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
        String notificationTitle = isAdminUpdate ? 'Admin Rescheduled Your Appointment' : 'Appointment Rescheduled';
        await NotificationService().scheduleNotification(
          id: updatedAppointmentData.notificationId,
          title: notificationTitle,
          body: 'Appointment for ${updatedAppointmentData.patientName} now at ${DateFormat.yMMMMd().add_jm().format(updatedAppointmentData.dateTime.toLocal())}.',
          scheduledDateTime: scheduledTime,
          payload: 'appointment_id=${updatedAppointmentData.id}&user_id=${patientUserIdForNotification ?? "unknown"}',
        );
      }
      _errorMessage = null;
      print("PROVIDER - rescheduleAppointment: Successfully rescheduled Appt ID: $appointmentId");
    } catch (e) {
      _errorMessage = "Failed to reschedule appointment: ${e.toString()}";
      print("PROVIDER - rescheduleAppointment: Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Appointment? appointmentToDelete;
      int appointmentIndexInUserList = -1;
      bool isAdminDelete = _authProvider.currentUser?.isAdmin ?? false;

      // --- DEBUG PRINT (Temporary) ---
      print("PROVIDER - deleteAppointment: Called for Appt ID: $appointmentId, isAdmin: $isAdminDelete");
      // --- END DEBUG PRINT ---

      if (isAdminDelete) {
        final allAppointments = _appointmentRepository.getAllAppointments();
        final originalIndexInAll = allAppointments.indexWhere((app) => app.id == appointmentId);
        if (originalIndexInAll != -1) {
          appointmentToDelete = allAppointments[originalIndexInAll];
        }
      } else {
        final currentUserId = _authProvider.currentUser?.id;
        if(currentUserId == null) {
          _errorMessage = "User not logged in for delete.";
          _isLoading = false;
          notifyListeners();
          return;
        }
        appointmentIndexInUserList = _allUserAppointments.indexWhere((app) => app.id == appointmentId && app.userId == currentUserId);
        if (appointmentIndexInUserList != -1) {
          appointmentToDelete = _allUserAppointments[appointmentIndexInUserList];
        }
      }

      if (appointmentToDelete == null) {
        _errorMessage = "Appointment not found or not authorized for delete.";
        print("PROVIDER - deleteAppointment: Appointment $appointmentId not found or not authorized.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      await NotificationService().cancelNotification(appointmentToDelete.notificationId);
      await _appointmentRepository.deleteAppointment(appointmentId);

      if (!isAdminDelete && appointmentIndexInUserList != -1) {
        _allUserAppointments.removeAt(appointmentIndexInUserList);
      }

      _errorMessage = null;
      print("PROVIDER - deleteAppointment: Successfully deleted Appt ID: $appointmentId");
    } catch (e) {
      _errorMessage = "Failed to delete appointment: ${e.toString()}";
      print("PROVIDER - deleteAppointment: Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isDoctorAvailable(String doctorId, DateTime dateTime) {
    try {
      return _appointmentRepository.isDoctorAvailable(doctorId, dateTime);
    } catch (e) {
      _errorMessage = "Error checking availability: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }
}

