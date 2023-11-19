import 'package:flutter/material.dart';
import '../controller/diary_controller.dart';
import '../model/diary_entry.dart';

class AddEntryView extends StatefulWidget {
  final DiaryController diaryController;
  final DiaryEntry? entry;

  const AddEntryView({super.key, required this.diaryController, this.entry});

  @override
  State<AddEntryView> createState() => _AddEntryViewState();
}

class _AddEntryViewState extends State<AddEntryView> {
  late TextEditingController _descriptionController;
  late int _rating;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _rating = widget.entry?.rating ?? 3;
    _selectedDate = widget.entry?.date ??
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _descriptionController =
        TextEditingController(text: widget.entry?.description);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEntry() {
    final String description = _descriptionController.text;
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description cannot be empty')),
      );
      return;
    }

    final DiaryEntry newEntry = DiaryEntry(
      date: _selectedDate,
      description: description,
      rating: _rating,
    );

    widget.diaryController.addEntry(newEntry).then((_) {
      Navigator.pop(context);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    });
  }

  void _updateEntry() {
    final String description = _descriptionController.text;
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description cannot be empty')),
      );
      return;
    }

    final DiaryEntry updatedEntry = DiaryEntry(
      id: widget.entry!.id,
      date: _selectedDate,
      description: description,
      rating: _rating,
    );

    widget.diaryController.updateEntry(updatedEntry).then((_) {
      Navigator.pop(context);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.entry == null
            ? Text('Add Diary Entry')
            : Text('Edit Diary Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _descriptionController,
              maxLength: 140,
              maxLines: 4, // This allows for multiple lines
              keyboardType: TextInputType
                  .multiline, // This sets up the keyboard for multiline input
              decoration: const InputDecoration(
                labelText: 'Description',
                helperText: 'Describe your day in 140 characters',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Rate your day:'),
                Slider(
                  value: _rating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (double value) {
                    setState(() {
                      _rating = value.toInt();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.entry == null ? _saveEntry : _updateEntry,
              child: widget.entry == null
                  ? Text('Save Entry')
                  : Text('Update Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
