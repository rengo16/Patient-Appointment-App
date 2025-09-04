
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'appointment_model.g.dart';

@HiveType(typeId: 2)
class Appointment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String doctorId;

  @HiveField(2)
  final String patientName;

  @HiveField(3)
  final String patientPhone;

  @HiveField(4)
  final DateTime dateTime;

  @HiveField(5)
  final AppointmentStatus status;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final int notificationId;
  @HiveField(9)
  final String userId;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientName,
    required this.patientPhone,
    required this.dateTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.notificationId,
    required this.userId,
  });

  factory Appointment.create({
    required String doctorId,
    required String patientName,
    required String patientPhone,
    required DateTime dateTime,
    required String currentUserId,
  }) {
    final now = DateTime.now();
    return Appointment(
      id: const Uuid().v4(),
      doctorId: doctorId,
      patientName: patientName,
      patientPhone: patientPhone,
      dateTime: dateTime,
      status: AppointmentStatus.pending,
      createdAt: now,
      updatedAt: now,
      notificationId: now.millisecondsSinceEpoch % 100000,
      userId: currentUserId,
    );
  }

  Appointment copyWith({
    String? id,
    String? doctorId,
    String? patientName,
    String? patientPhone,
    DateTime? dateTime,
    AppointmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? notificationId,
    String? userId,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
    );
  }
}

@HiveType(typeId: 3)
enum AppointmentStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  approved,

  @HiveField(2)
  declined,

  @HiveField(3)
  completed,

  @HiveField(4)
  canceled,

  @HiveField(5)
  missed,
}

