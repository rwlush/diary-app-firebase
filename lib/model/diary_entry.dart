import 'package:cloud_firestore/cloud_firestore.dart';
class DiaryEntry {
  final DateTime date;
  final String description;
  final int rating;

  DiaryEntry(this.date, this.description, this.rating);
}
