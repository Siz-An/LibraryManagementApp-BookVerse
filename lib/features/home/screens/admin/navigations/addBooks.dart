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

        // Check if a book with the same title already exists
        final existingBooksQuery = await FirebaseFirestore.instance
            .collection('books')
            .where('title', isEqualTo: _titleController.text.trim().toUpperCase())
            .get();

        if (existingBooksQuery.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Book with the same title already exists!'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        // Add the new book to Firestore
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
          'pdfs': pdfData,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Books added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        bool sendNotification = await _showNotificationDialog();
        if (sendNotification) {
          await _sendNotification();
        }

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add books: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.library_add, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Add New Book',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: _image != null
                              ? Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _image!,
                                        height: 140,
                                        width: 140,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _image = null;
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  height: 140,
                                  width: 140,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2E9E4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF9A8C98),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Color(0xFF4A4E69),
                                      size: 38,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image),
                                label: const Text('Pick Image'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A4E69),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickPDFs,
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Pick PDFs'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9A8C98),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _modernTextField(
                  controller: _numberOfBooksController,
                  label: 'Number of Copies',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the number of copies';
                    }
                    final numCopies = int.tryParse(value);
                    if (numCopies == null || numCopies < 0) {
                      return 'Number of copies must be 0 or greater';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                SwitchListTile(
                  title: const Text(
                    'Is this a course book?',
                    style: TextStyle(
                      color: Color(0xFF4A4E69),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _isCourseBook,
                  activeColor: const Color(0xFF4A4E69),
                  onChanged: (value) {
                    setState(() {
                      _isCourseBook = value;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                const SizedBox(height: 18),
                _modernTextField(
                  controller: _titleController,
                  label: 'Book Title',
                  icon: Icons.book,
                  validator: (value) => value!.isEmpty ? 'Please enter Book Title' : null,
                ),
                const SizedBox(height: 18),
                _modernStringValidatedTextField(
                  controller: _writerController,
                  label: 'Writer',
                  icon: Icons.person,
                ),
                const SizedBox(height: 18),
                if (!_isCourseBook)
                  _modernStringValidatedTextField(
                    controller: _genreController,
                    label: 'Genre (comma-separated)',
                    icon: Icons.category,
                  ),
                if (_isCourseBook)
                  Column(
                    children: [
                      _modernTextField(
                        controller: _courseController,
                        label: 'Year / Semester',
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 18),
                      _modernTextField(
                        controller: _gradeController,
                        label: 'Grade',
                        icon: Icons.grade,
                      ),
                    ],
                  ),
                const SizedBox(height: 18),
                _modernTextField(
                  controller: _summaryController,
                  label: 'Summary',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 22),
                if (_pdfs.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected PDFs',
                        style: TextStyle(
                          color: Color(0xFF4A4E69),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._pdfs.map((pdf) {
                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF9A8C98)),
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
                    ],
                  ),
                const SizedBox(height: 28),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addBooks,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      shadowColor: const Color(0xFF4A4E69).withOpacity(0.2),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernStringValidatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9A8C98)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a valid $label';
        }
        if (RegExp(r'\d').hasMatch(value)) {
          return '$label should not contain numbers';
        }
        return null;
      },
    );
  }

  Widget _modernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9A8C98)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator ?? (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
}
