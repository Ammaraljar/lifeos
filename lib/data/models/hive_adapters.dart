import 'package:hive/hive.dart';
import 'habit_model.dart';

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override final int typeId = 0;
  @override
  HabitModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return HabitModel(
      id: f[0] as String,
      nameEn: f[1] as String,
      nameAr: f[2] as String,
      category: HabitCategory.values[f[3] as int],
      type: HabitType.values[f[4] as int],
      icon: f[5] as String,
      colorValue: f[6] as int,
      sortOrder: f[7] as int,
      isActive: f[8] as bool,
      targetValue: f[9] as int?,
      targetUnit: f[10] as String?,
      scheduledTime: f[11] as String?,
      createdAt: f[12] as DateTime,
    );
  }
  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.nameEn)
      ..writeByte(2)..write(obj.nameAr)
      ..writeByte(3)..write(obj.categoryIndex)
      ..writeByte(4)..write(obj.typeIndex)
      ..writeByte(5)..write(obj.icon)
      ..writeByte(6)..write(obj.colorValue)
      ..writeByte(7)..write(obj.sortOrder)
      ..writeByte(8)..write(obj.isActive)
      ..writeByte(9)..write(obj.targetValue)
      ..writeByte(10)..write(obj.targetUnit)
      ..writeByte(11)..write(obj.scheduledTime)
      ..writeByte(12)..write(obj.createdAt);
  }
}

class HabitLogAdapter extends TypeAdapter<HabitLog> {
  @override final int typeId = 1;
  @override
  HabitLog read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return HabitLog(
      id: f[0] as String,
      habitId: f[1] as String,
      date: f[2] as DateTime,
      completed: f[3] as bool,
      value: f[4] as int?,
      loggedAt: f[5] as DateTime,
    );
  }
  @override
  void write(BinaryWriter writer, HabitLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.habitId)
      ..writeByte(2)..write(obj.date)
      ..writeByte(3)..write(obj.completed)
      ..writeByte(4)..write(obj.value)
      ..writeByte(5)..write(obj.loggedAt);
  }
}
