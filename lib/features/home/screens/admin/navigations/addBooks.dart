import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AddBooks extends StatefulWidget {
  const AddBooks({Key? key}) : super(key: key);

  @override
  _AddBooksState createState() => _AddBooksState();
}

class _AddBooksState extends State<AddBooks> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _numberOfBooksController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _writerController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? _image;
  bool _isCourseBook = false;

  // List to store selected PDFs
  List<Map<String, dynamic>> _pdfs = [];

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Pick PDFs
  Future<void> _pickPDFs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _pdfs.addAll(result.files.map((file) {
          return {
            'file': File(file.path!),
            'name': file.name,
            'description': TextEditingController(),
          };
        }));
      });
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    String fileName = imageFile.path.split('/').last;
    TaskSnapshot snapshot = await FirebaseStorage.instance
        .ref('book_images/$fileName')
        .putFile(imageFile);
    return await snapshot.ref.getDownloadURL();
  }

  // Upload PDFs to Firebase Storage
  Future<List<Map<String, String>>> _uploadPDFs() async {
    List<Map<String, String>> uploadedPDFs = [];
    for (var pdf in _pdfs) {
      String fileName = pdf['file'].path.split('/').last;
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('book_pdfs/$fileName')
          .putFile(pdf['file']);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      uploadedPDFs.add({
        'name': pdf['name'],
        'url': downloadUrl,
        'description': pdf['description'].text,
      });
    }
    return uploadedPDFs;
  }

  // Add book data to Firestore
  Future<void> _addBooks() async {
    if (_formKey.currentState!.validate()) {
      try {
        int numberOfBooks = int.parse(_numberOfBooksController.text);
        String? imageUrl;

        if (_image != null) {
          imageUrl = await _uploadImage(_image!);
        }

        // Parse genres if it's not a course book
        List<String>? genres = !_isCourseBook
            ? _genreController.text.split(',').map((e) => e.trim().toUpperCase()).toList()
            : null;

        // Upload PDFs
        List<Map<String, String>> pdfData = await _uploadPDFs();

        await FirebaseFirestore.instance.collection('books').add({
          'title': _titleController.text.trim().toUpperCase(),
          'writer': _writerController.text.trim().toUpperCase(),
          'genre': genres,
          'course': _isCourseBook ? _courseController.text.trim().toUpperCase() : null,
          'grade': _isCourseBook && _gradeController.text.isNotEmpty
              ? _gradeController.text.trim().toUpperCase()
              : null,
          'imageUrl': imageUrl,
          'isCourseBook': _isCourseBook,
          'summary': _summaryController.text.trim(),
          'numberOfCopies': numberOfBooks,
          'pdfs': pdfData, // Add the uploaded PDFs
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Books added successfully!')),
        );

        bool sendNotification = await _showNotificationDialog();
        if (sendNotification) {
          await _sendNotification();
        }

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add books: $e')),
        );
      }
    }
  }

  // Show notification dialog
  Future<bool> _showNotificationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send Notification'),
          content: const Text('Do you want to notify users about this book?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  // Send notification to users
  Future<void> _sendNotification() async {
    final user = _auth.currentUser;
    if (user != null) {
      final recipientUserId = 'recipientUserId'; // Replace with dynamic recipient ID if available
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'New Book Added',
        'message': 'A new book titled "${_titleController.text.trim()}" has been added!',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'sender': user.email,
        'recipientId': recipientUserId,
      });
    }
  }

  // Clear form fields and reset states
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
      _pdfs.clear();
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
                validator: (value) => value!.isEmpty ? 'Enter the number of copies' : null,
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
              _buildTextFormField(_titleController, 'Book Title', Icons.book),
              const SizedBox(height: 16),
              _buildTextFormField(_writerController, 'Writer', Icons.person),
              const SizedBox(height: 16),
              if (!_isCourseBook)
                _buildTextFormField(_genreController, 'Genre (comma-separated)', Icons.category),
              if (_isCourseBook)
                Column(
                  children: [
                    _buildTextFormField(_courseController, 'Year / Semester', Icons.calendar_today),
                    const SizedBox(height: 16),
                    _buildTextFormField(_gradeController, 'Grade', Icons.grade),
                  ],
                ),
              const SizedBox(height: 16),
              _buildTextFormField(_summaryController, 'Summary', Icons.description, maxLines: 3),
              const SizedBox(height: 20),
              if (_image != null)
                Image.file(
                  _image!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Image'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickPDFs,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Pick PDFs'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_pdfs.isNotEmpty)
                Column(
                  children: _pdfs.map((pdf) {
                    return Card(
                      child: ListTile(
                        title: Text(pdf['name']),
                        subtitle: TextField(
                          controller: pdf['description'],
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _pdfs.remove(pdf);
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addBooks,
                icon: const Icon(Icons.add),
                label: const Text('Add Books'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text form fields
  Widget _buildTextFormField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
}
