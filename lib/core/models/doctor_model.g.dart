

part of 'doctor_model.dart';



class DoctorAdapter extends TypeAdapter<Doctor> {
  @override
  final int typeId = 0;

  @override
  Doctor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Doctor(
      id: fields[0] as String,
      name: fields[1] as String,
      specialty: fields[2] as String,
      avatarUrl: fields[3] as String,
      workDays: (fields[4] as List).cast<WorkDay>(),
    );
  }

  @override
  void write(BinaryWriter writer, Doctor obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.specialty)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.workDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkDayAdapter extends TypeAdapter<WorkDay> {
  @override
  final int typeId = 1;

  @override
  WorkDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkDay(
      weekday: fields[0] as int,
      slots: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkDay obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weekday)
      ..writeByte(1)
      ..write(obj.slots);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
