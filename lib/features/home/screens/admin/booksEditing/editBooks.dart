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
  final _copiesController = TextEditingController();
  final _picker = ImagePicker();
  File? _image;
  String? _imageUrl;
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
        _copiesController.text = data['numberOfCopies']?.toString() ?? '';
        _isCourseBook = data['isCourseBook'] ?? false;

        if (!_isCourseBook && data['genre'] != null) {
          _genreController.text = (data['genre'] as List).join(', ');
        }

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

        List<String>? genres = !_isCourseBook
            ? _genreController.text.split(',').map((e) => e.trim()).toList()
            : null;

        await FirebaseFirestore.instance.collection('books').doc(widget.bookId).update({
          'title': _titleController.text,
          'writer': _writerController.text,
          'genre': genres,
          'course': _isCourseBook ? _courseController.text : null,
          'grade': _isCourseBook && _gradeController.text.isNotEmpty ? _gradeController.text : null,
          'imageUrl': imageUrl,
          'isCourseBook': _isCourseBook,
          'summary': _summaryController.text,
          'numberOfCopies': int.tryParse(_copiesController.text) ?? 0,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully')),
        );

        Navigator.pop(context);
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
        backgroundColor: Colors.green,
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
                activeColor: Colors.deepOrangeAccent,
                onChanged: (value) {
                  setState(() {
                    _isCourseBook = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(_titleController, 'Book Title', Icons.book, 'Please enter the book title'),
              const SizedBox(height: 10),
              _buildTextField(_writerController, 'Writer', Icons.person, 'Please enter the writer\'s name'),
              const SizedBox(height: 10),
              if (!_isCourseBook)
                Column(
                  children: [
                    _buildTextField(_genreController, 'Genre (comma-separated)', Icons.category, 'Please enter the genre'),
                    const SizedBox(height: 10),
                  ],
                ),
              if (_isCourseBook)
                Column(
                  children: [
                    _buildTextField(_courseController, 'Year / Semester (optional)', Icons.calendar_today),
                    const SizedBox(height: 10),
                    _buildTextField(_gradeController, 'Grade', Icons.grade, 'Please enter the grade'),
                    const SizedBox(height: 10),
                  ],
                ),
              _buildTextField(_summaryController, 'Summary', Icons.description, 'Please enter a summary',),
              const SizedBox(height: 10),
              _buildTextField(
                _copiesController,
                'Number of Copies',
                Icons.numbers,
                'Please enter the number of copies',

              ),
              const SizedBox(height: 20),
              if (_image != null || (_imageUrl != null && _imageUrl!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const Text('Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: _image != null
                              ? Image.file(_image!, fit: BoxFit.cover)
                              : Image.network(_imageUrl!, fit: BoxFit.cover),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(120, 40),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _updateBook,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      minimumSize: const Size(150, 40),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      minimumSize: const Size(150, 40),
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, [
        String? validatorMessage,
        TextInputType inputType = TextInputType.text,
        int maxLines = 1,
        String? Function(String?)? validator,
      ]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      keyboardType: inputType,
      maxLines: maxLines,
      validator: validator ??
              (value) {
            if (validatorMessage != null && value!.isEmpty) return validatorMessage;
            return null;
          },
    );
  }
}
