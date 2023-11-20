import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntry {
  final String? id;
  final DateTime date;
  final String description;
  final int rating;
  final String? location;
  final String? imagePath;

  DiaryEntry(
      {this.id,
      this.imagePath,
      this.location,
      required this.date,
      required this.description,
      required this.rating});

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'description': description,
      'rating': rating,
      'location': location,
      'imagePath': imagePath
    };
  }

  static DiaryEntry fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
        id: doc.id,
        date: DateTime.parse(map['date'].toDate().toString()),
        description: map['description'],
        rating: map['rating'],
        location: map['location'],
        imagePath: map['imagePath']);
  }
}
