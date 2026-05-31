import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// Habit categories matching life areas
enum HabitCategory { spiritual, english, fitness, business, family, knowledge }

// Habit types for special handling
enum HabitType { prayer, quran, exercise, study, work, family, reading, custom }

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String nameEn;
  @HiveField(2) late String nameAr;
  @HiveField(3) late int categoryIndex;
  @HiveField(4) late int typeIndex;
  @HiveField(5) late String icon;
  @HiveField(6) late int colorValue;
  @HiveField(7) late int sortOrder;
  @HiveField(8) late bool isActive;
  @HiveField(9) late int? targetValue;     // e.g. 4 pages, 90 minutes
  @HiveField(10) late String? targetUnit;  // pages, minutes, hours
  @HiveField(11) late String? scheduledTime; // "06:00"
  @HiveField(12) late DateTime createdAt;

  HabitModel({
    String? id,
    required this.nameEn,
    required this.nameAr,
    required HabitCategory category,
    required HabitType type,
    required this.icon,
    required this.colorValue,
    required this.sortOrder,
    this.isActive = true,
    this.targetValue,
    this.targetUnit,
    this.scheduledTime,
    DateTime? createdAt,
  }) {
    this.id = id ?? const Uuid().v4();
    categoryIndex = category.index;
    typeIndex = type.index;
    this.createdAt = createdAt ?? DateTime.now();
  }

  HabitCategory get category => HabitCategory.values[categoryIndex];
  HabitType get type => HabitType.values[typeIndex];
  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;
}

@HiveType(typeId: 1)
class HabitLog extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String habitId;
  @HiveField(2) late DateTime date;
  @HiveField(3) late bool completed;
  @HiveField(4) late int? value; // actual value completed (pages read, etc.)
  @HiveField(5) late DateTime loggedAt;

  HabitLog({
    String? id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.value,
    DateTime? loggedAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.loggedAt = loggedAt ?? DateTime.now();
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool isSameDay(DateTime d) =>
      date.year == d.year && date.month == d.month && date.day == d.day;
}
