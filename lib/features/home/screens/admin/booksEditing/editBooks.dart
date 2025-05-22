import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
  final TextEditingController _numberOfBooksController = TextEditingController();
  final _picker = ImagePicker();
  File? _image;
  String? _imageUrl;
  bool _isCourseBook = false;

  List<Map<String, dynamic>> _pdfs = [];

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
        _numberOfBooksController.text = data['numberOfCopies']?.toString() ?? '';
        _isCourseBook = data['isCourseBook'] ?? false;

        if (!_isCourseBook && data['genre'] != null) {
          _genreController.text = (data['genre'] as List).join(', ');
        }

        _imageUrl = data['imageUrl'];
        if (data['pdfs'] != null) {
          _pdfs = (data['pdfs'] as List).map((pdf) {
            return {
              'name': pdf['name'],
              'url': pdf['url'],
              'description': TextEditingController(text: pdf['description'] ?? ''),
            };
          }).toList();
        }
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load book details: $e')),
      );
    }
  }

  Future<void> _deleteBook() async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(widget.bookId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book deleted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete book: $e')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: const Text('Are you sure you want to delete this book? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteBook();
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

  Future<List<Map<String, String>>> _uploadPDFs() async {
    List<Map<String, String>> uploadedPDFs = [];
    for (var pdf in _pdfs) {
      if (pdf['file'] != null) {
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
      } else {
        uploadedPDFs.add({
          'name': pdf['name'],
          'url': pdf['url'],
          'description': pdf['description'].text,
        });
      }
    }
    return uploadedPDFs;
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        String title = _titleController.text.toUpperCase();

        // Check if a book with the same title exists (excluding the current book being updated)
        var querySnapshot = await FirebaseFirestore.instance
            .collection('books')
            .where('title', isEqualTo: title)
            .get();

        if (querySnapshot.docs.isNotEmpty &&
            querySnapshot.docs.first.id != widget.bookId) {
          // If a book with the same title exists, show a pop-up
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book with the same title already exists!'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return; // Exit the function if the book exists
        }

        String imageUrl = _imageUrl ?? '';
        if (_image != null) {
          String fileName = _image!.path.split('/').last;
          TaskSnapshot snapshot = await FirebaseStorage.instance
              .ref('book_images/$fileName')
              .putFile(_image!);
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        List<String>? genres = !_isCourseBook
            ? _genreController.text
            .split(',')
            .map((e) => e.trim().toUpperCase())
            .toList()
            : null;

        // Upload PDFs
        List<Map<String, String>> pdfData = await _uploadPDFs();

        await FirebaseFirestore.instance.collection('books').doc(widget.bookId).update({
          'title': title,
          'writer': _writerController.text.toUpperCase(),
          'genre': genres,
          'course': _isCourseBook ? _courseController.text.toUpperCase() : null,
          'grade': _isCourseBook && _gradeController.text.toUpperCase().isNotEmpty
              ? _gradeController.text.toUpperCase()
              : null,
          'imageUrl': imageUrl,
          'isCourseBook': _isCourseBook,
          'summary': _summaryController.text.toUpperCase(),
          'numberOfCopies': int.tryParse(_numberOfBooksController.text) ?? 0,
          'pdfs': pdfData, // Updated PDFs
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

  Widget _buildTextFields(
      TextEditingController controller,
      String labelText,
      IconData icon,
      String validationMessage,
      ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        final numCopies = int.tryParse(value);
        if (numCopies == null) {
          return 'Please enter a valid number';
        }
        // Allow zero and any positive number
        if (numCopies < 0) {
          return 'Number of copies cannot be negative';
        }
        return null;
      },
    );
  }

  Widget _buildStringValidatedTextFormField(
      TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a valid $labelText';
        }
        if (RegExp(r'\d').hasMatch(value)) {
          return '$labelText should not contain numbers';
        }
        return null;
      },
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: Colors.white,
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
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Edit Book',
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text(
                          'Is this a course book?',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        value: _isCourseBook,
                        activeColor: Colors.deepOrangeAccent,
                        onChanged: (value) {
                          setState(() {
                            _isCourseBook = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 18),
                      _buildTextField(_titleController, 'Book Title', Icons.book, 'Please enter the book title'),
                      const SizedBox(height: 14),
                      _buildStringValidatedTextFormField(_writerController, 'Writer', Icons.person),
                      const SizedBox(height: 14),
                      if (!_isCourseBook)
                        _buildStringValidatedTextFormField(_genreController, 'Genre (comma-separated)', Icons.category),
                      if (!_isCourseBook) const SizedBox(height: 14),
                      if (_isCourseBook)
                        _buildTextField(_courseController, 'Year / Semester (optional)', Icons.calendar_today),
                      if (_isCourseBook) const SizedBox(height: 14),
                      if (_isCourseBook)
                        _buildTextField(_gradeController, 'Grade', Icons.grade, 'Please enter the grade'),
                      if (_isCourseBook) const SizedBox(height: 14),
                      _buildTextField(_summaryController, 'Summary', Icons.description, 'Please enter a summary', TextInputType.text, 3),
                      const SizedBox(height: 14),
                      _buildTextFields(
                        _numberOfBooksController,
                        'Number of Copies',
                        Icons.numbers,
                        'Please enter the number of copies',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Book Image',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A4E69)),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300, width: 2),
                                color: Colors.grey.shade100,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _image != null
                                    ? Image.file(_image!, fit: BoxFit.cover)
                                    : (_imageUrl != null && _imageUrl!.isNotEmpty)
                                        ? Image.network(_imageUrl!, fit: BoxFit.cover)
                                        : const Icon(Icons.image, size: 60, color: Colors.grey),
                              ),
                            ),
                            if (_image != null || (_imageUrl != null && _imageUrl!.isNotEmpty))
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _image = null;
                                      _imageUrl = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF4A4E69),
                            minimumSize: const Size(120, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PDFs',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A4E69)),
                      ),
                      const SizedBox(height: 12),
                      if (_pdfs.isNotEmpty)
                        Column(
                          children: _pdfs.map((pdf) {
                            return Card(
                              color: const Color(0xFFF8F7FA),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF9A8C98)),
                                title: Text(pdf['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
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
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _pickPDFs,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Pick PDFs'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF9A8C98),
                            minimumSize: const Size(120, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _updateBook,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF4A4E69),
                        minimumSize: const Size(150, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        minimumSize: const Size(150, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Book'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
