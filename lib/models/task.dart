import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  String priority;

  @HiveField(5)
  String status;

  @HiveField(6)
  String notes;

  @HiveField(7)
  String tags;

  @HiveField(8)                     // ← new field
  bool isCompleted;

  Task({
    required this.title,
    required this.date,
    this.description = '',
    this.category = '',
    this.priority = '',
    this.status = '',
    this.notes = '',
    this.tags = '',
    this.isCompleted = false,        // ← default false
  });
}