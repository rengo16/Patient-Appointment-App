import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:patientappointment/core/models/appointment_model.dart';
import 'package:patientappointment/core/models/user_model.dart' as UserModelImport;
import 'package:patientappointment/core/providers/appointment_provider.dart';
import 'package:patientappointment/core/providers/auth_provider.dart';
import 'package:patientappointment/data/repos/appointment_repository.dart';
import 'package:patientappointment/core/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz; // Import for tz.TZDateTime for mock verification
import 'package:timezone/data/latest_all.dart' as tz_data; // For initializing timezones for tz.local

// Import generated mocks
import 'appointment_provider_test.mocks.dart';

@GenerateMocks([AppointmentRepository, AuthProvider, NotificationService])
void main() { // <<<< ENSURE THIS main() FUNCTION IS PRESENT AND WRAPS EVERYTHING

  // Initialize timezones once for all tests in this file if tz.local is used
  // This is needed because AppointmentProvider calls tz.TZDateTime.from(dateTime, tz.local)
  setUpAll(() {
    tz_data.initializeTimeZones();
    // If your tests or code relies on a specific default local timezone, set it here.
    // Otherwise, tz.local will use the system's default if available or a fallback.
    // Example: tz.setLocalLocation(tz.getLocation('America/New_York'));
  });

  late AppointmentProvider appointmentProvider;
  late MockAppointmentRepository mockAppointmentRepository;
  late MockAuthProvider mockAuthProvider;
  late MockNotificationService mockNotificationService;

  // Using a fixed 'now' for more predictable date calculations in tests
  // It's even better to inject a clock, but this is a good step.
  final now = DateTime.now();
  final tPatientUser = UserModelImport.User(id: 'patient1', name: 'Test Patient', phone: '111', isAdmin: false);
  final tAdminUser = UserModelImport.User(id: 'admin1', name: 'Test Admin', phone: '999', isAdmin: true);

  final tAppointment1 = Appointment(
    id: 'appt1', userId: 'patient1', doctorId: 'doc1', patientName: 'Test Patient', patientPhone: '111',
    dateTime: now.add(const Duration(days: 1)), status: AppointmentStatus.approved,
    createdAt: now, updatedAt: now, notificationId: 1,
  );
  final tAppointment2 = Appointment(
    id: 'appt2', userId: 'patient1', doctorId: 'doc2', patientName: 'Test Patient', patientPhone: '111',
    dateTime: now.subtract(const Duration(days: 1)), status: AppointmentStatus.completed,
    createdAt: now, updatedAt: now, notificationId: 2,
  );
  final tAppointment3Pending = Appointment(
    id: 'appt3', userId: 'patient2', doctorId: 'doc1', patientName: 'Other Patient', patientPhone: '222',
    dateTime: now.add(const Duration(hours: 2)), status: AppointmentStatus.pending,
    createdAt: now, updatedAt: now, notificationId: 3,
  );
  final List<Appointment> tAllAppointmentsFromRepo = [tAppointment1, tAppointment2, tAppointment3Pending];

  void initializeProviders({UserModelImport.User? currentUser}) {
    mockAppointmentRepository = MockAppointmentRepository();
    mockAuthProvider = MockAuthProvider();
    mockNotificationService = MockNotificationService();

    when(mockAuthProvider.currentUser).thenReturn(currentUser);
    when(mockAuthProvider.addListener(any)).thenReturn(null);
    when(mockAuthProvider.removeListener(any)).thenReturn(null);

    when(mockAppointmentRepository.getAllAppointments()).thenReturn(tAllAppointmentsFromRepo);
    when(mockAppointmentRepository.addAppointment(any)).thenAnswer((_) async {});
    when(mockAppointmentRepository.updateAppointment(any)).thenAnswer((_) async {});
    when(mockAppointmentRepository.deleteAppointment(any)).thenAnswer((_) async {});
    when(mockAppointmentRepository.isDoctorAvailable(any, any)).thenReturn(true);

    when(mockNotificationService.scheduleNotification(
      id: anyNamed('id'),
      title: anyNamed('title'),
      body: anyNamed('body'),
      scheduledDateTime: anyNamed('scheduledDateTime'), // This will match tz.TZDateTime
      payload: anyNamed('payload'),
    )).thenAnswer((_) async {});
    when(mockNotificationService.cancelNotification(any)).thenAnswer((_) async {});

    appointmentProvider = AppointmentProvider(
      mockAppointmentRepository,
      mockAuthProvider,
      mockNotificationService, // Pass the mock
    );
  }

  group('AppointmentProvider Tests', () {
    group('Patient User Context', () {
      setUp(() {
        initializeProviders(currentUser: tPatientUser);
      });

      test('_loadCurrentUserAppointments filters for current patient', () async {
        appointmentProvider.testNotifyAuthStateChanged();
        await Future.delayed(Duration.zero); // Allow async operations in onAuthStateChanged to complete
        expect(appointmentProvider.appointments.length, 2);
        expect(appointmentProvider.appointments.any((a) => a.id == tAppointment1.id), isTrue);
      });

      test('upcomingAppointments filters correctly', () {
        appointmentProvider.testNotifyAuthStateChanged();
        expect(appointmentProvider.upcomingAppointments.length, 1);
        expect(appointmentProvider.upcomingAppointments.first.id, tAppointment1.id);
      });

      test('completedAppointments filters correctly', () {
        appointmentProvider.testNotifyAuthStateChanged();
        expect(appointmentProvider.completedAppointments.length, 1);
        expect(appointmentProvider.completedAppointments.first.id, tAppointment2.id);
      });

      test('addAppointment successfully adds and schedules notification', () async {
        const doctorId = 'docNew';
        final newDateTime = now.add(const Duration(days: 2));
        // Crucial: Create the exact TZDateTime that AppointmentProvider will create
        final expectedTZDateTime = tz.TZDateTime.from(newDateTime, tz.local);

        await appointmentProvider.addAppointment(doctorId: doctorId, dateTime: newDateTime);

        final capturedAppt = verify(mockAppointmentRepository.addAppointment(captureAny)).captured.single as Appointment;
        expect(capturedAppt.doctorId, doctorId);
        expect(capturedAppt.patientName, tPatientUser.name);
        expect(appointmentProvider.appointments.any((a) => a.id == capturedAppt.id), isTrue);
        expect(appointmentProvider.errorMessage, isNull);

        verify(mockNotificationService.scheduleNotification(
          id: capturedAppt.notificationId,
          title: 'Appointment Reminder',
          body: anyNamed('body'),
          scheduledDateTime: expectedTZDateTime, // Verify with the correct TZDateTime
          payload: 'appointment_id=${capturedAppt.id}',
        )).called(1);
      });

      test('addAppointment fails if user is admin', () async {
        initializeProviders(currentUser: tAdminUser);
        await appointmentProvider.addAppointment(doctorId: 'docX', dateTime: now);
        verifyNever(mockAppointmentRepository.addAppointment(any));
        verifyNever(mockNotificationService.scheduleNotification(id: anyNamed('id'), title: anyNamed('title'), body: anyNamed('body'), scheduledDateTime: anyNamed('scheduledDateTime'), payload: anyNamed('payload')));
        expect(appointmentProvider.errorMessage, contains("Only patients can book"));
      });
    });

    group('Admin User Context', () {
      setUp(() {
        initializeProviders(currentUser: tAdminUser);
      });

      test('allAppointmentsForAdmin returns all from repository', () {
        appointmentProvider.testNotifyAuthStateChanged();
        expect(appointmentProvider.allAppointmentsForAdmin.length, tAllAppointmentsFromRepo.length);
      });

      test('pendingAppointmentsForAdmin filters correctly', () {
        appointmentProvider.testNotifyAuthStateChanged();
        expect(appointmentProvider.pendingAppointmentsForAdmin.length, 1);
        expect(appointmentProvider.pendingAppointmentsForAdmin.first.id, tAppointment3Pending.id);
      });

      test('updateAppointmentStatus calls repository and handles notifications', () async {
        final appointmentToUpdate = tAppointment3Pending;
        const newStatus = AppointmentStatus.approved;
        // Crucial: Create the exact TZDateTime
        final expectedTZDateTime = tz.TZDateTime.from(appointmentToUpdate.dateTime, tz.local);

        await appointmentProvider.updateAppointmentStatus(appointmentToUpdate.id, newStatus);

        final capturedAppt = verify(mockAppointmentRepository.updateAppointment(captureAny)).captured.single as Appointment;
        expect(capturedAppt.id, appointmentToUpdate.id);
        expect(capturedAppt.status, newStatus);
        expect(appointmentProvider.errorMessage, isNull);

        //old status was pending, new is approved.
        //1. cancelNotification(oldAppointment.notificationId) is NOT called because condition for it is not met
        //   `(oldAppointment.status == AppointmentStatus.pending || oldAppointment.status == AppointmentStatus.approved) && (newStatus != AppointmentStatus.pending && newStatus != AppointmentStatus.approved)`
        //   Here, newStatus IS AppointmentStatus.approved.
        //2. cancelNotification(updatedAppointmentData.notificationId) IS called
        //3. scheduleNotification(...) IS called
        verify(mockNotificationService.cancelNotification(appointmentToUpdate.notificationId)).called(1); // From the second cancel call
        verify(mockNotificationService.scheduleNotification(
          id: appointmentToUpdate.notificationId,
          title: 'Appointment ${newStatus.name}',
          body: anyNamed('body'),
          scheduledDateTime: expectedTZDateTime, // Verify with TZDateTime
          payload: anyNamed('payload'),
        )).called(1);
      });
    });
  });
}

extension AppointmentProviderTestExtension on AppointmentProvider {
  void testNotifyAuthStateChanged() {
    onAuthStateChanged();
  }
}
