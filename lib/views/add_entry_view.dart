import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../controller/diary_controller.dart';
import '../model/diary_entry.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEntryView extends StatefulWidget {
  final DiaryController diaryController;
  final DiaryEntry? entry;

  const AddEntryView({super.key, required this.diaryController, this.entry});

  @override
  State<AddEntryView> createState() => _AddEntryViewState();
}

class _AddEntryViewState extends State<AddEntryView> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late int _rating;
  late DateTime _selectedDate;
  late String? existingImagePath;

  @override
  void initState() {
    super.initState();
    existingImagePath = widget.entry?.imagePath;
    _rating = widget.entry?.rating ?? 3;
    _selectedDate = widget.entry?.date ??
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _descriptionController =
        TextEditingController(text: widget.entry?.description);
    _locationController = TextEditingController(text: widget.entry?.location);
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
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

  void _saveEntry() async {
    final String description = _descriptionController.text;
    String? location = _locationController.text;
    String? imagePath;
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description cannot be empty')),
      );
      return;
    }

    if (_image != null) {
      try {
        imagePath = await widget.diaryController.uploadImageToFirebase(_image);
      } catch (e) {
        throw Exception(e);
      }
    }

    final DiaryEntry newEntry = DiaryEntry(
      date: _selectedDate,
      description: description,
      rating: _rating,
      location: location,
      imagePath: imagePath,
    );

    widget.diaryController.addEntry(newEntry).then((_) {
      Navigator.pop(context);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    });
  }

  void _updateEntry() async {
    final String description = _descriptionController.text;
    String? location = _locationController.text;
    String? updatedImagePath = widget.entry?.imagePath;
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description cannot be empty')),
      );
      return;
    }

    if (_image != null) {
      if (existingImagePath != null) {
        widget.diaryController
            .removeImageFromFirebase(existingImagePath as String);
      }
      try {
        updatedImagePath =
            await widget.diaryController.uploadImageToFirebase(_image);
      } catch (e) {
        throw Exception(e);
      }
    }

    final DiaryEntry updatedEntry = DiaryEntry(
      id: widget.entry!.id,
      date: _selectedDate,
      description: description,
      rating: _rating,
      location: location,
      imagePath: updatedImagePath,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.browser_updated),
            onPressed: () {
              _pickImageFromGallery();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () {
              _pickImageFromCamera();
            },
          )
        ],
        title: widget.entry == null
            ? Text('Add Diary Entry')
            : Text('Edit Diary Entry'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _descriptionController,
                maxLength: 140,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  helperText: 'Describe your day in 140 characters',
                ),
              ),
              TextField(
                controller: _locationController,
                maxLength: 10,
                maxLines: 1,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Entry Location',
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
              Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          existingImagePath != null
                              ? Text(
                                  "Stored Image",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(),
                          SizedBox(
                            height: 6,
                          ),
                          existingImagePath != null
                              ? Image(
                                  height: 175,
                                  width: 175,
                                  image:
                                      NetworkImage(existingImagePath as String))
                              : Container(),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _image != null
                              ? Text(
                                  "Selected Image",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(),
                          SizedBox(
                            height: 6,
                          ),
                          _image != null
                              ? kIsWeb
                                  ? Image.network(
                                      _image!.path,
                                      width: 175,
                                      height: 175,
                                    )
                                  : Image.file(
                                      width: 175,
                                      height: 175,
                                      File(_image!.path),
                                    )
                              : Container(),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              existingImagePath != null
                  ? ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () {
                        setState(() {
                          widget.diaryController.removeImageFromFirebase(
                              existingImagePath as String);
                          existingImagePath = null;
                        });
                      },
                      child: Text('Delete stored image'))
                  : Container(),
              _image != null
                  ? ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () {
                        setState(() {
                          _image = null;
                        });
                      },
                      child: Text('Clear selected image'))
                  : Container(),
              ElevatedButton(
                onPressed: widget.entry == null ? _saveEntry : _updateEntry,
                child: widget.entry == null
                    ? Text('Save Entry')
                    : Text('Update Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
