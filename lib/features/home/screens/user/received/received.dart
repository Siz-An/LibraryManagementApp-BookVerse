import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Received extends StatelessWidget {
  const Received({super.key});

  // Function to move book data to 'toBeReturnedBooks' and remove from 'issuedBooks'
  Future<void> _confirmReturnBook(BuildContext context, String docId, Map<String, dynamic> data) async {
    // Show confirmation dialog
    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Return Book'),
          content: const Text('Are you sure you want to return this book?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    // If user confirms return
    if (isConfirmed == true) {
      final toBeReturnedBooksCollection = FirebaseFirestore.instance.collection('toBeReturnedBooks');
      final issuedBooksCollection = FirebaseFirestore.instance.collection('issuedBooks');

      // Add data to 'toBeReturnedBooks'
      await toBeReturnedBooksCollection.add(data);

      // Remove from 'issuedBooks'
      await issuedBooksCollection.doc(docId).delete();
    }
  }

  // Function to handle book removal from 'rejectedBooks'
  Future<void> _removeBook(String docId) async {
    final rejectedBooksCollection = FirebaseFirestore.instance.collection('rejectedBooks');

    // Remove book from 'rejectedBooks'
    await rejectedBooksCollection.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    // DateFormat instance to format dates
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Books'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ISSUED BOOKS:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4, // Adjust height as needed
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('issuedBooks').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No issued books found.'));
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id; // Get the document ID for deletion

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
                                    Text('Issue Date: ${dateFormat.format((data["issueDate"] as Timestamp).toDate())}'),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.reply),
                                onPressed: () {
                                  // Call the confirmation dialog for returning the book
                                  _confirmReturnBook(context, docId, data);
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'REJECTED BOOKS:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4, // Adjust height as needed
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('rejectedBooks').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No rejected books found.'));
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id; // Get the document ID for deletion

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
                                    Text('Rejection Date: ${dateFormat.format((data["rejectionDate"] as Timestamp).toDate())}'),
                                    Text('Reason: ${data["rejectionReason"] as String}'),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  _removeBook(docId);
                                },
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
