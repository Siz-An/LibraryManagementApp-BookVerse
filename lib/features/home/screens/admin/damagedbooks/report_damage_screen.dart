import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ReportDamageScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final String userId;

  const ReportDamageScreen({
    Key? key,
    required this.bookId,
    required this.bookTitle,
    required this.userId,
  }) : super(key: key);

  @override
  _ReportDamageScreenState createState() => _ReportDamageScreenState();
}

class _ReportDamageScreenState extends State<ReportDamageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _damageTypeController = TextEditingController();
  final _explanationController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  final List<String> _damageTypes = [
    'Torn Pages',
    'Water Damage',
    'Missing Pages',
    'Cover Damage',
    'Spine Damage',
    'Other'
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_image!.path.split('/').last}';
      final ref = FirebaseStorage.instance.ref('damage_reports/$fileName');
      await ref.putFile(_image!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user name
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();
      String userName = 'Unknown User';
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        userName = userData['UserName'] ?? 'Unknown User';
      }
      
      // Upload image if available
      String? imageUrl = await _uploadImage();

      // Get book price
      double bookPrice = 0.0;
      try {
        final bookDoc = await FirebaseFirestore.instance.collection('books').doc(widget.bookId).get();
        if (bookDoc.exists) {
          final bookData = bookDoc.data() as Map<String, dynamic>;
          // Assuming the book has a 'price' field, if not, we can calculate based on other fields
          bookPrice = bookData['price'] ?? 0.0;
        }
      } catch (e) {
        print('Error fetching book price: $e');
      }

      // Create damage report
      final reportData = {
        'bookId': widget.bookId,
        'bookTitle': widget.bookTitle,
        'userId': widget.userId,
        'userName': userName,
        'damageType': _damageTypeController.text,
        'explanation': _explanationController.text,
        'imageUrl': imageUrl,
        'reportedAt': FieldValue.serverTimestamp(),
        'adminNotified': false,
        'resolved': false,
        'bookPrice': bookPrice,
      };

      await FirebaseFirestore.instance.collection('damagedBooks').add(reportData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Damage reported successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to report damage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _damageTypeController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Book Damage'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Book Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Title: ${widget.bookTitle}'),
                      const SizedBox(height: 4),
                      Text('Book ID: ${widget.bookId}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type of Damage',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select damage type' : null,
                items: _damageTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _damageTypeController.text = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _explanationController,
                decoration: const InputDecoration(
                  labelText: 'Explanation',
                  hintText: 'Describe the damage in detail...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please provide an explanation' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Photo of Book (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text('Tap to upload photo'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Report',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}