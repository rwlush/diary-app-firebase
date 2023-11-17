import 'package:dear_diary/firebase_options.dart';
import 'package:dear_diary/model/diary_entry.dart';
import 'package:flutter/material.dart';
import 'controller/diary_controller.dart';
import 'views/add_entry_view.dart';
import 'views/diary_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter((DiaryEntryAdapter()));
  final diaryBox = await Hive.openBox('diaryBox');
  final DiaryController diaryController = DiaryController(diaryBox);
  runApp(MainApp(diaryController: diaryController));
}

class MainApp extends StatelessWidget {
  final DiaryController diaryController;
  const MainApp({super.key, required this.diaryController});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey.shade100,
        primarySwatch: Colors.grey,
        // scaffoldBackgroundColor: Colors.deepOrange.shade100,
        // primarySwatch: Colors.deepOrange,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => DiaryView(
              diaryController: diaryController,
            ),
        '/addEntry': (context) => AddEntryView(
              diaryController: diaryController,
            ),
      },
    );
  }
}
