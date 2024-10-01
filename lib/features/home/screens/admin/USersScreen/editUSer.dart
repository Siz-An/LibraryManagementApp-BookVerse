import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;

  EditUserScreen({required this.userId, required Map<String, dynamic> initialData});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _email = '';
  String _phoneNumber = '';
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      setState(() {
        _userName = userData['UserName'] ?? '';
        _email = userData['Email'] ?? '';
        _phoneNumber = userData['PhoneNumber'] ?? '';
        _isLoading = false; // Loading completed
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Loading completed even on error
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading user data')));
    }
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      // Show confirmation dialog
      final shouldUpdate = await _showConfirmationDialog(context);
      if (shouldUpdate == true) {
        try {
          await FirebaseFirestore.instance.collection('Users').doc(widget.userId).update({
            'UserName': _userName,
            'Email': _email,
            'PhoneNumber': _phoneNumber,
          });
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating user data')));
        }
      }
    }
  }

  Future<void> _deleteUser() async {
    // Show confirmation dialog before deletion
    final shouldDelete = await _showDeleteConfirmationDialog(context);
    if (shouldDelete == true) {
      try {
        // Retrieve the user document
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();

        // Check if the user exists
        if (userDoc.exists) {
          // Delete user from Firestore
          await FirebaseFirestore.instance.collection('Users').doc(widget.userId).delete();

          // Delete user from Firebase Authentication
          User? userToDelete = await FirebaseAuth.instance.userChanges().firstWhere((user) => user?.uid == widget.userId).catchError((_) => null);

          if (userToDelete != null) {
            // If we find the user to delete, we delete the account
            await userToDelete.delete();
          }

          // Optionally, navigate back or show success message
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User account deleted successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User does not exist')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting user data')));
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this user account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Update'),
          content: Text('Are you sure you want to edit this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _userName,
                decoration: InputDecoration(labelText: 'User Name', border: OutlineInputBorder()),
                onChanged: (value) => _userName = value,
                validator: (value) => value!.isEmpty ? 'Please enter a user name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                onChanged: (value) => _email = value,
                validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                onChanged: (value) => _phoneNumber = value,
                validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Update User'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteUser,
                child: Text('Delete Account'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Colors.red, // Different color for delete
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
