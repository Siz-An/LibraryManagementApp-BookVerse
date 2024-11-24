import 'package:book_Verse/features/home/screens/user/pdfView/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PDFListScreen extends StatelessWidget {
  const PDFListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Library'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pdfs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load PDFs: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No PDFs available.'));
          } else {
            final pdfs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: pdfs.length,
              itemBuilder: (context, index) {
                final pdf = pdfs[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(pdf['name'] ?? 'Untitled'),
                  subtitle: Text(pdf['writer'] ?? 'Unknown'),
                  trailing: Icon(Icons.picture_as_pdf),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFViewerScreen(pdfUrl: pdf['pdfUrl']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
