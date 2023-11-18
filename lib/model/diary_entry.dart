import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntry {
  final String? id;
  final Timestamp date;
  final String description;
  final int rating;

  DiaryEntry(
      {this.id,
      required this.date,
      required this.description,
      required this.rating});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'rating': rating,
    };
  }

  static DiaryEntry fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: doc.id,
      date: map['date'] as Timestamp,
      description: map['description'],
      rating: map['rating'],
    );
  }
}
