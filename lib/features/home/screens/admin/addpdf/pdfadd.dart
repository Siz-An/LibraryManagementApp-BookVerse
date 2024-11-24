import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class AddPDFScreen extends StatefulWidget {
  @override
  _AddPDFScreenState createState() => _AddPDFScreenState();
}

class _AddPDFScreenState extends State<AddPDFScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _writerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  PlatformFile? _selectedPDF;

  void _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.extension == 'pdf') {
      setState(() {
        _selectedPDF = result.files.single;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a valid PDF file.')));
    }
  }

  Future<void> _uploadPDF() async {
    if (_nameController.text.isEmpty ||
        _writerController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedPDF == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All fields and PDF are required.')));
      return;
    }

    try {
      final pdfPath = 'pdfs/${_selectedPDF!.name}';
      final storageRef = FirebaseStorage.instance.ref().child(pdfPath);
      final file = File(_selectedPDF!.path!);
      await storageRef.putFile(file);

      final pdfUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('pdfs').add({
        'name': _nameController.text,
        'writer': _writerController.text,
        'description': _descriptionController.text,
        'pdfUrl': pdfUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      // Show popup dialog after successful upload
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload PDF: $e')));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Successful'),
        content: Text('Your PDF has been uploaded successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _writerController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedPDF = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add PDF'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'PDF Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _writerController,
                decoration: InputDecoration(
                  labelText: 'Writer Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'What is this PDF about?',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickPDF,
                icon: Icon(Icons.upload_file),
                label: Text(_selectedPDF == null ? 'Pick PDF' : 'Selected: ${_selectedPDF!.name}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _uploadPDF,
                child: Text('Upload PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
