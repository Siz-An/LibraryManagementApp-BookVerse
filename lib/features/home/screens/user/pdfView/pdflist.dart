import 'package:book_Verse/features/home/screens/user/pdfView/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure you import your PDF viewer screen here.

class AllPDFsScreen extends StatelessWidget {
  const AllPDFsScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchAllUniquePDFs() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('books').get();

    // Use a Set to track unique URLs and prevent duplicates
    final Set<String> seenUrls = {};
    final List<Map<String, dynamic>> uniquePDFs = [];

    for (var doc in querySnapshot.docs) {
      final bookData = doc.data();
      if (bookData['pdfs'] != null && bookData['pdfs'] is List) {
        for (var pdf in List<Map<String, dynamic>>.from(bookData['pdfs'])) {
          if (pdf['url'] != null && !seenUrls.contains(pdf['url'])) {
            seenUrls.add(pdf['url']);
            uniquePDFs.add(pdf);
          }
        }
      }
    }

    return uniquePDFs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Available PDFs'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAllUniquePDFs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching PDFs.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No PDFs found.'));
          }

          final pdfs = snapshot.data!;

          return ListView.builder(
            itemCount: pdfs.length,
            itemBuilder: (context, index) {
              final pdf = pdfs[index];
              return ListTile(
                title: Text(pdf['name'] ?? 'Unnamed PDF'),
                subtitle: Text(pdf['description'] ?? 'No description available'),
                trailing: const Icon(Icons.picture_as_pdf),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerScreen(
                        pdfUrl: pdf['url'] as String,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
