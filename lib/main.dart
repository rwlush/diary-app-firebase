import 'package:dear_diary/model/diary_entry.dart';
import 'package:flutter/material.dart';
import 'controller/diary_controller.dart';
import 'views/add_entry_view.dart';
import 'views/diary_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  // Ensure Flutter is initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive for Flutter.
  await Hive.initFlutter();
  // Register the adapter for `CarModel`.
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
