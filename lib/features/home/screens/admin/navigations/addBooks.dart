import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddBooks extends StatefulWidget {
  const AddBooks({Key? key}) : super(key: key);

  @override
  _AddBooksState createState() => _AddBooksState();
}

class _AddBooksState extends State<AddBooks> {
  final _formKey = GlobalKey<FormState>();
  final _numberOfBooksController = TextEditingController();
  final _titleController = TextEditingController();
  final _writerController = TextEditingController();
  final _genreController = TextEditingController();
  final _courseController = TextEditingController();
  final _gradeController = TextEditingController();
  final _summaryController = TextEditingController();
  final _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _image;
  bool _isCourseBook = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _addBooks() async {
    if (_formKey.currentState!.validate()) {
      try {
        int numberOfBooks = int.parse(_numberOfBooksController.text);
        String imageUrl = '';

        if (_image != null) {
          String fileName = _image!.path.split('/').last;
          TaskSnapshot snapshot = await FirebaseStorage.instance
              .ref('book_images/$fileName')
              .putFile(_image!);
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        List<String>? genres = !_isCourseBook
            ? _genreController.text.split(',').map((e) => e.trim().toUpperCase()).toList()
            : null;

        await FirebaseFirestore.instance.collection('books').add({
          'title': _titleController.text.toUpperCase(),
          'writer': _writerController.text.toUpperCase(),
          'genre': genres,
          'course': _isCourseBook ? _courseController.text.toUpperCase() : null,
          'grade': _isCourseBook && _gradeController.text.isNotEmpty
              ? _gradeController.text.toUpperCase()
              : null,
          'imageUrl': _image != null ? imageUrl : null,
          'isCourseBook': _isCourseBook,
          'summary': _summaryController.text.toUpperCase(),
          'numberOfCopies': numberOfBooks,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Books added successfully')),
        );

        bool sendNotification = await _showNotificationDialog();
        if (sendNotification) {
          final user = _auth.currentUser;
          if (user != null) {
            final recipientUserId = 'someRecipientUserId'; // Replace with actual recipient ID or retrieve dynamically
            await FirebaseFirestore.instance.collection('notifications').add({
              'title': 'New Book Added',
              'message': 'A new book titled "${_titleController.text.toUpperCase()}" has been added.',
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
              'sender': user.email,
              'recipientId': recipientUserId,
            });
          }
        }

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add books: $e')),
        );
      }
    }
  }


  Future<bool> _showNotificationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send Notification'),
          content: const Text('Do you want to send a notification about the new book?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _clearForm() {
    _numberOfBooksController.clear();
    _titleController.clear();
    _writerController.clear();
    _genreController.clear();
    _courseController.clear();
    _gradeController.clear();
    _summaryController.clear();
    setState(() {
      _image = null;
      _isCourseBook = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Books'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _numberOfBooksController,
                decoration: const InputDecoration(
                  labelText: 'Number of Copies',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the number of copies';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is this a course book?'),
                value: _isCourseBook,
                onChanged: (value) {
                  setState(() {
                    _isCourseBook = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title',
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the book title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _writerController,
                decoration: const InputDecoration(
                  labelText: 'Writer',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the writer\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!_isCourseBook)
                TextFormField(
                  controller: _genreController,
                  decoration: const InputDecoration(
                    labelText: 'Genre (comma-separated)',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the genre';
                    }
                    return null;
                  },
                ),
              if (_isCourseBook)
                Column(
                  children: [
                    TextFormField(
                      controller: _courseController,
                      decoration: const InputDecoration(
                        labelText: 'Year / Semester (optional)',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gradeController,
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        prefixIcon: Icon(Icons.grade),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the grade';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a summary';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_image != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Image.file(
                    _image!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addBooks,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Books'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
