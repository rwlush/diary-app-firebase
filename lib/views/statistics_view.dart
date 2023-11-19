import 'package:dear_diary/model/diary_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/diary_controller.dart';

class StatisticsView extends StatefulWidget {
  final List<DiaryEntry> entriesList;
  StatisticsView({super.key, required this.entriesList});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  final DiaryController diaryController = DiaryController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, num> averageRatings =
        diaryController.calculateAverageRatings(widget.entriesList);
    Map<String, num> highestRatings =
        diaryController.findHighestRatings(widget.entriesList);
    Map<String, num> lowestRatings =
        diaryController.findLowestRatings(widget.entriesList);
    Map<String, num> totalRatings =
        diaryController.countTotalEntries(widget.entriesList);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Average Ratings for Each Month'),
      ),
      body: widget.entriesList.isEmpty
          ? const Center(
              child: Text(
                'No entries have been made yet.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: averageRatings.keys.map((monthYear) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                            style: Theme.of(context).textTheme.headlineSmall,
                            DateFormat('MMMM yyyy').format(DateTime(
                                int.parse(monthYear.split('-')[1]),
                                int.parse(monthYear.split('-')[0])))),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10.0),
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade900),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Ratings: ${totalRatings[monthYear]!.toString()}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Highest Rating: ${highestRatings[monthYear]!.toString()}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Average Rating: ${averageRatings[monthYear]!.toStringAsFixed(1)}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Lowest Rating: ${lowestRatings[monthYear]!.toString()}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
