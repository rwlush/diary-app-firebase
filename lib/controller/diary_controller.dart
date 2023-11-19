import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/diary_entry.dart';

class DiaryController {
  final user = FirebaseAuth.instance.currentUser;

  final CollectionReference diaryEntryCollection;

  DiaryController()
      : diaryEntryCollection = FirebaseFirestore.instance
            .collection('entries')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('userEntries');

  Future<DocumentReference<Object?>> addEntry(DiaryEntry entry) async {
    try {
      if (await entryExists(entry.date)) {
        throw Exception('An entry for this date already exists');
      }
      return await diaryEntryCollection.add(entry.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<DiaryEntry>> listEntries() async {
    try {
      QuerySnapshot snapshot = await diaryEntryCollection.get();
      return snapshot.docs.map((doc) => DiaryEntry.fromMap(doc)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateEntry(DiaryEntry updatedEntry) async {
    try {
      return await diaryEntryCollection
          .doc(updatedEntry.id)
          .update(updatedEntry.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> removeEntry(DiaryEntry entry) async {
    try {
      if (!await entryExists(entry.date)) {
        throw Exception('No entry found for this date');
      }
      return await diaryEntryCollection.doc(entry.id).delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> entryExists(DateTime date) async {
    try {
      DateTime start = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime end = DateTime(date.year, date.month, date.day, 23, 59, 59);

      QuerySnapshot matchingEntries = await diaryEntryCollection
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();

      return matchingEntries.docs.isNotEmpty;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<DiaryEntry>> searchEntries(String keyword) async {
    return [];
    // return diaryBox.values
    //     .cast<DiaryEntry>()
    //     .where((entry) => entry.description.contains(keyword))
    //     .toList();
  }

  Future<List<DiaryEntry>> filterEntries(int rating) async {
    return [];
    // return diaryBox.values
    //     .cast<DiaryEntry>()
    //     .where((entry) => entry.rating == rating)
    //     .toList();
  }

// void main() async {

//   var diaryController = DiaryController();

//   // Now you can use diaryController to manage diary entries
// }
}
