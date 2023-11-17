import 'package:hive/hive.dart';

part 'diary_entry.g.dart'; // Name of the generated file

@HiveType(typeId: 0) // Unique typeId for Hive
class DiaryEntry {
  @HiveField(0)
  final DateTime date;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final int rating;

  DiaryEntry(this.date, this.description, this.rating);
}
