import 'package:hive/hive.dart';
import '../model/diary_entry.dart';

class DiaryController {
  final Box diaryBox;

  DiaryController(this.diaryBox);

  Future<void> addEntry(DiaryEntry entry) async {
    if (await entryExists(entry.date)) {
      throw Exception('Entry already exists for this date');
    }
    await diaryBox.put(entry.date.toString(), entry);
  }

  Future<void> updateEntry(DateTime date, DiaryEntry updatedEntry) async {
    if (!await entryExists(date)) {
      throw Exception('No entry found for this date');
    }
    await diaryBox.put(date.toString(), updatedEntry);
  }

  Future<void> removeEntry(DateTime date) async {
    if (!await entryExists(date)) {
      throw Exception('No entry found for this date');
    }
    await diaryBox.delete(date.toString());
  }

  Future<List<DiaryEntry>> listEntries() async {
    return diaryBox.values.cast<DiaryEntry>().toList();
  }

  Future<List<DiaryEntry>> searchEntries(String keyword) async {
    return diaryBox.values
        .cast<DiaryEntry>()
        .where((entry) => entry.description.contains(keyword))
        .toList();
  }

  Future<List<DiaryEntry>> filterEntries(int rating) async {
    return diaryBox.values
        .cast<DiaryEntry>()
        .where((entry) => entry.rating == rating)
        .toList();
  }

  Future<bool> entryExists(DateTime date) async {
    return diaryBox.containsKey(date.toString());
  }

  void deleteEntry(int index) {
    diaryBox.deleteAt(index);
  }

  Future<void> deleteEntryByEntry(DiaryEntry entry) async {
    final key = diaryBox.keys
        .firstWhere((k) => diaryBox.get(k) == entry, orElse: () => null);
    if (key != null) {
      await diaryBox.delete(key);
    } else {
      print('Entry not found');
    }
  }
}

void main() async {
  Hive.init('path_to_hive_box'); // Initialize Hive
  Hive.registerAdapter(DiaryEntryAdapter()); // Register your custom TypeAdapter

  var diaryBox = await Hive.openBox<DiaryEntry>('diaryBox');
  var diaryController = DiaryController(diaryBox);

  // Now you can use diaryController to manage diary entries
}
