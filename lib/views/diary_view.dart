import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dear_diary/views/add_entry_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/diary_controller.dart';
import '../model/diary_entry.dart';
import 'components/diary_entry_widget.dart';

class DiaryView extends StatefulWidget {
  DiaryView({super.key});

  @override
  State<DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<DiaryView> {
  final DiaryController diaryController = DiaryController();
  late StreamController<QuerySnapshot> _streamController;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<QuerySnapshot>();

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        diaryController.diaryEntryCollection.snapshots().listen(
          (QuerySnapshot snapshot) {
            _streamController.add(snapshot);
          },
        );
      } else {
        _streamController.close();
      }
    });
  }

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
                      builder: (BuildContext context) =>
                          AddEntryView(diaryController: diaryController)),
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
          stream: _streamController.stream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No entries found'));
            } else {
              List<DiaryEntry> entries = snapshot.data!.docs
                  .map((doc) => DiaryEntry.fromMap(doc))
                  .toList();
              entries.sort((a, b) => b.date.compareTo(a.date));

              List<Widget> widgets = [];
              DateTime? lastDate;
              for (int i = 0; i < entries.length; i++) {
                final entry = entries[i];
                if (lastDate == null ||
                    entry.date.month != lastDate.month ||
                    entry.date.year != lastDate.year) {
                  final headerText = DateFormat('MMMM yyyy').format(entry.date);
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
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: widgets,
                ),
              );
            }
          },
        ));
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
