import 'package:hive/hive.dart';

part 'doctor_model.g.dart';

@HiveType(typeId: 0)
class Doctor {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String specialty;

  @HiveField(3)
  final String avatarUrl;

  @HiveField(4)
  final List<WorkDay> workDays;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    required this.workDays,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
      avatarUrl: json['avatarUrl'],
      workDays: (json['workDays'] as List)
          .map((day) => WorkDay.fromJson(day))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'avatarUrl': avatarUrl,
      'workDays': workDays.map((day) => day.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 1)
class WorkDay {
  @HiveField(0)
  final int weekday;

  @HiveField(1)
  final List<String> slots;

  WorkDay({
    required this.weekday,
    required this.slots,
  });

  factory WorkDay.fromJson(Map<String, dynamic> json) {
    return WorkDay(
      weekday: json['weekday'],
      slots: List<String>.from(json['slots']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'slots': slots,
    };
  }
}