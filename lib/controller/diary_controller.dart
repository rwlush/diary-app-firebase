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

  Map<String, int> countTotalEntries(List<DiaryEntry> entries) {
    Map<String, int> totalEntriesCount = {};

    for (var entry in entries) {
      int month = entry.date.month;
      int year = entry.date.year;
      String monthYearKey = '$month-$year';

      if (!totalEntriesCount.containsKey(monthYearKey)) {
        totalEntriesCount[monthYearKey] = 1;
      } else {
        totalEntriesCount[monthYearKey] = totalEntriesCount[monthYearKey]! + 1;
      }
    }

    List<MapEntry<String, int>> sortedEntries =
        totalEntriesCount.entries.toList()
          ..sort((a, b) {
            var aDate = DateTime.parse('20${a.key.replaceAll('-', '01-')}');
            var bDate = DateTime.parse('20${b.key.replaceAll('-', '01-')}');
            return bDate.compareTo(aDate);
          });

    return Map.fromEntries(sortedEntries);
  }

  Map<String, double> findHighestRatings(List<DiaryEntry> entries) {
    Map<String, double> highestRatings = {};

    for (var entry in entries) {
      int month = entry.date.month;
      int year = entry.date.year;
      String monthYearKey = '$month-$year';

      if (!highestRatings.containsKey(monthYearKey) ||
          entry.rating > highestRatings[monthYearKey]!) {
        highestRatings[monthYearKey] = entry.rating as double;
      }
    }

    List<MapEntry<String, double>> sortedEntries =
        highestRatings.entries.toList()
          ..sort((a, b) {
            var aDate = DateTime.parse('20${a.key.replaceAll('-', '01-')}');
            var bDate = DateTime.parse('20${b.key.replaceAll('-', '01-')}');
            return bDate.compareTo(aDate);
          });

    return Map.fromEntries(sortedEntries);
  }

  Map<String, double> findLowestRatings(List<DiaryEntry> entries) {
    Map<String, double> lowestRatings = {};

    for (var entry in entries) {
      int month = entry.date.month;
      int year = entry.date.year;
      String monthYearKey = '$month-$year';

      if (!lowestRatings.containsKey(monthYearKey) ||
          entry.rating < lowestRatings[monthYearKey]!) {
        lowestRatings[monthYearKey] = entry.rating as double;
      }
    }

    List<MapEntry<String, double>> sortedEntries =
        lowestRatings.entries.toList()
          ..sort((a, b) {
            var aDate = DateTime.parse('20${a.key.replaceAll('-', '01-')}');
            var bDate = DateTime.parse('20${b.key.replaceAll('-', '01-')}');
            return bDate.compareTo(aDate);
          });

    return Map.fromEntries(sortedEntries);
  }

  Map<String, double> calculateAverageRatings(List<DiaryEntry> entries) {
    Map<String, List<double>> ratingsByMonthYear = {};

    for (var entry in entries) {
      int month = entry.date.month;
      int year = entry.date.year;
      String monthYearKey = '$month-$year';

      if (!ratingsByMonthYear.containsKey(monthYearKey)) {
        ratingsByMonthYear[monthYearKey] = [];
      }

      ratingsByMonthYear[monthYearKey]!.add(entry.rating as double);
    }

    Map<String, double> averageRatings = {};

    ratingsByMonthYear.forEach((monthYear, ratings) {
      double average = ratings.isNotEmpty
          ? ratings.reduce((a, b) => a + b) / ratings.length
          : 0;
      averageRatings[monthYear] = average;
    });

    List<MapEntry<String, double>> sortedEntries =
        averageRatings.entries.toList()
          ..sort((a, b) {
            var aDate = DateTime.parse('20${a.key.replaceAll('-', '01-')}');
            var bDate = DateTime.parse('20${b.key.replaceAll('-', '01-')}');
            return bDate.compareTo(aDate);
          });

    return Map.fromEntries(sortedEntries);
  }
}
