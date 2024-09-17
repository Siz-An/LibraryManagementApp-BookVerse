import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToBeReturnedBooksScreen extends StatelessWidget {
  final String userId;

  const ToBeReturnedBooksScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // DateFormat instance to format dates
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('To Be Returned Books'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TO BE RETURNED BOOKS:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('toBeReturnedBooks')
                      .where('userId', isEqualTo: userId) // Filter by userId
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No books to be returned.'));
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id; // Get the document ID for deletion

                        // Check if the issueDate and requestedReturnDate fields are not null
                        final issueDate = data["issueDate"] != null
                            ? (data["issueDate"] as Timestamp).toDate()
                            : null;
                        final requestedReturnDate = data["requestedReturnDate"] != null
                            ? (data["requestedReturnDate"] as Timestamp).toDate()
                            : null;

                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                data["imageUrl"] as String,
                                width: 100,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data["title"] as String,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text('Writer: ${data["writer"] as String}'),
                                    if (issueDate != null)
                                      Text('Issue Date: ${dateFormat.format(issueDate)}'),
                                    if (requestedReturnDate != null)
                                      Text('Requested Return Date: ${dateFormat.format(requestedReturnDate)}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
