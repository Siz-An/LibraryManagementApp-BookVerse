import 'package:book_Verse/books/detailScreen/viewPdf.dart';
import 'package:flutter/material.dart';

class PDFListScreen2 extends StatelessWidget {
  final List<Map<String, dynamic>> pdfs;

  const PDFListScreen2({Key? key, required this.pdfs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Available PDFs')),
      body: ListView.builder(
        itemCount: pdfs.length,
        itemBuilder: (context, index) {
          final pdf = pdfs[index];
          return ListTile(
            title: Text(pdf['name'] ?? 'Unnamed PDF'),
            subtitle: Text(pdf['description'] ?? 'No description available'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen2(pdfUrl: pdf['url'] as String),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
