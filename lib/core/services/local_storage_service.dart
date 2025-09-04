import 'package:hive_flutter/hive_flutter.dart';
import 'package:patientappointment/core/models/doctor_model.dart';
import 'package:patientappointment/core/models/appointment_model.dart';
import 'package:patientappointment/core/models/user_model.dart';

class LocalStorageService {
  static late Box<String> _sessionBox;
  static late Box<Doctor> _doctorsBox;
  static late Box<Appointment> _appointmentsBox;
  static late Box<User> _usersBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DoctorAdapter());
    Hive.registerAdapter(WorkDayAdapter());
    Hive.registerAdapter(AppointmentAdapter());
    Hive.registerAdapter(AppointmentStatusAdapter());
    Hive.registerAdapter(UserAdapter());
    _sessionBox = await Hive.openBox<String>('session');
    _doctorsBox = await Hive.openBox<Doctor>('doctors');
    _appointmentsBox = await Hive.openBox<Appointment>('appointments');
    _usersBox = await Hive.openBox<User>('users');
  }

  static Box<String> get sessionBox => _sessionBox;
  static Box<Doctor> get doctorsBox => _doctorsBox;
  static Box<Appointment> get appointmentsBox => _appointmentsBox;
  static Box<User> get usersBox => _usersBox;
}