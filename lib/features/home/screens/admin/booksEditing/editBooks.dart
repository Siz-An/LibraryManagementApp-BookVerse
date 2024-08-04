import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditBookScreen extends StatefulWidget {
  final String bookId;

  const EditBookScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _writerController = TextEditingController();
  final _genreController = TextEditingController();
  final _courseController = TextEditingController();
  final _gradeController = TextEditingController();
  final _summaryController = TextEditingController();
  final _copiesController = TextEditingController(); // Controller for number of copies
  final _picker = ImagePicker();
  File? _image;
  String? _imageUrl; // To store the image URL from Firestore
  bool _isCourseBook = false;

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
  }

  Future<void> _loadBookDetails() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('books').doc(widget.bookId).get();
      if (doc.exists) {
        final data = doc.data()!;
        _titleController.text = data['title'] ?? '';
        _writerController.text = data['writer'] ?? '';
        _courseController.text = data['course'] ?? '';
        _gradeController.text = data['grade'] ?? '';
        _summaryController.text = data['summary'] ?? '';
        _copiesController.text = data['numberOfCopies']?.toString() ?? ''; // Load number of copies

        _isCourseBook = data['isCourseBook'] ?? false;

        if (!_isCourseBook && data['genre'] != null) {
          _genreController.text = (data['genre'] as List).join(', ');
        }

        // Load the image URL from Firestore
        _imageUrl = data['imageUrl'];

        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load book details: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        String imageUrl = _imageUrl ?? '';
        if (_image != null) {
          String fileName = _image!.path.split('/').last;
          TaskSnapshot snapshot = await FirebaseStorage.instance
              .ref('book_images/$fileName')
              .putFile(_image!);
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        // Split the genre text by commas and trim whitespace
        List<String>? genres = !_isCourseBook
            ? _genreController.text.split(',').map((e) => e.trim()).toList()
            : null;

        await FirebaseFirestore.instance.collection('books').doc(widget.bookId).update({
          'title': _titleController.text,
          'writer': _writerController.text,
          'genre': genres, // Store the list of genres
          'course': _isCourseBook ? _courseController.text : null,
          'grade': _isCourseBook && _gradeController.text.isNotEmpty ? _gradeController.text : null,
          'imageUrl': imageUrl,
          'isCourseBook': _isCourseBook,
          'summary': _summaryController.text,
          'numberOfCopies': int.tryParse(_copiesController.text) ?? 0, // Save number of copies
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully')),
        );

        Navigator.pop(context); // Go back after updating
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update book: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SwitchListTile(
                title: const Text('Is this a course book?'),
                value: _isCourseBook,
                onChanged: (value) {
                  setState(() {
                    _isCourseBook = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the book title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _writerController,
                decoration: const InputDecoration(
                  labelText: 'Writer',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the writer\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              if (!_isCourseBook)
                Column(
                  children: [
                    TextFormField(
                      controller: _genreController,
                      decoration: const InputDecoration(
                        labelText: 'Genre (comma-separated)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the genre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              if (_isCourseBook)
                Column(
                  children: [
                    TextFormField(
                      controller: _courseController,
                      decoration: const InputDecoration(
                        labelText: 'Year / Semester (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _gradeController,
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the grade';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
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
              const SizedBox(height: 10),
              TextFormField(
                controller: _copiesController,
                decoration: const InputDecoration(
                  labelText: 'Number of Copies',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the number of copies';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.file(
                    _image!,
                    height: 180,
                    width: 190,
                    fit: BoxFit.cover,
                  ),
                )
              else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.network(
                    _imageUrl!,
                    height: 180,
                    width: 190,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _updateBook,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
