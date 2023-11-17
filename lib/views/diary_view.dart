import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import '../controller/diary_controller.dart';
import '../model/diary_entry.dart';
import 'components/diary_entry_widget.dart';

class DiaryView extends StatelessWidget {
  final DiaryController diaryController;

  const DiaryView({Key? key, required this.diaryController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addEntry');
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: diaryController.diaryBox.listenable(),
        builder: (context, Box box, widget) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No entries found'),
            );
          } else {
            final entries = box.values.cast<DiaryEntry>().toList();
            entries.sort((a, b) => b.date
                .compareTo(a.date)); // Sort entries by date in descending order
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ValueListenableBuilder(
                valueListenable: diaryController.diaryBox.listenable(),
                builder: (context, Box box, widget) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Text('No entries found'),
                    );
                  } else {
                    final entries = box.values.cast<DiaryEntry>().toList();
                    entries.sort((a, b) => b.date.compareTo(a.date));

                    List<Widget> widgets = [];
                    DateTime? lastDate;
                    for (int i = 0; i < entries.length; i++) {
                      final entry = entries[i];
                      if (lastDate == null ||
                          entry.date.month != lastDate.month ||
                          entry.date.year != lastDate.year) {
                        final headerText =
                            DateFormat('MMMM yyyy').format(entry.date);
                        widgets.add(DateHeader(text: headerText));
                      }
                      widgets.add(
                        DiaryEntryWidget(
                          entry: entry,
                          onDelete: () {
                            diaryController.deleteEntryByEntry(entry);
                          },
                        ),
                      );
                      lastDate = entry.date;
                    }

                    return ListView(
                      children: widgets,
                    );
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class DateHeader extends StatelessWidget {
  final String text;

  const DateHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
