import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 4)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final bool isAdmin;

  User({
    required this.id,
    required this.phone,
    required this.name,
    this.isAdmin = false,
  });
  User copyWith({
    String? id,
    String? phone,
    String? name,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'isAdmin': isAdmin,
    };
  }
}

