import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dear_diary/views/add_entry_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/diary_controller.dart';
import '../model/diary_entry.dart';
import 'components/diary_entry_widget.dart';

class DiaryView extends StatelessWidget {
  DiaryView({super.key});

  final DiaryController diaryController = DiaryController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => AddEntryView(diaryController: diaryController)
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: diaryController.diaryEntryCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No entries found'),
            );
          } else {
            final entries = snapshot.data?.docs
                .map((doc) => DiaryEntry.fromMap(doc))
                .toList();
            entries?.sort((a, b) => b.date
                .compareTo(a.date)); // Sort entries by date in descending order
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder(
                stream: diaryController.diaryEntryCollection.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No entries found'),
                    );
                  } else {
                    final entries = snapshot.data?.docs
                        .map((doc) => DiaryEntry.fromMap(doc))
                        .toList();
                    entries?.sort((a, b) => b.date.compareTo(a.date));

                    List<Widget> widgets = [];
                    DateTime? lastDate;
                    for (int i = 0; i < entries!.length; i++) {
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
                            diaryController.removeEntry(entry);
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
