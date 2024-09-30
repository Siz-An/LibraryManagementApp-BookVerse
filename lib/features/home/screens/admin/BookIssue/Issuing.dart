
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

class IssuedBooksScreen extends StatelessWidget {
  final String userId; // Accept userId

  const IssuedBooksScreen({super.key, required this.userId}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issued Books'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info), // Change to the desired icon
            onPressed: () {
            },
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('issuedBooks')
            .where('userId', isEqualTo: userId) // Filter issued books by userId
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No books issued to this user.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var bookData = doc.data() as Map<String, dynamic>;
              String imageUrl = bookData['imageUrl'] ?? '';
              String title = bookData['title'] ?? 'No Title';
              String writer = bookData['writer'] ?? 'Unknown';

              // Format the issue date
              Timestamp timestamp = bookData['issueDate'] ?? Timestamp.now();
              String issueDate = DateFormat('MMMM dd, yyyy, h:mm a').format(timestamp.toDate());

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.fitHeight)
                      : const Icon(Icons.broken_image, size: 50), // Placeholder if no image
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Writer: $writer'),
                      Text('Issue Date: $issueDate'),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
