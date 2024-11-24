import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;

  const PDFViewerScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late PdfControllerPinch _pdfController;
  String? localPdfPath;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    try {
      final support = await checkPdfSupport();
      if (!support) {
        throw Exception('PDF rendering is not supported on this device.');
      }
      await _downloadAndOpenPdf();
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<bool> checkPdfSupport() async {
    final pdfSupport = await hasPdfSupport();
    return pdfSupport;
  }

  Future<void> _downloadAndOpenPdf() async {
    final response = await http.get(Uri.parse(widget.pdfUrl));
    if (response.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        localPdfPath = file.path;
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(localPdfPath!),
        );
        isLoading = false;
      });
    } else {
      throw Exception('Failed to download PDF');
    }
  }

  Future<void> _downloadPdfToLocal() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        // Get the Downloads directory path
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!downloadsDir.existsSync()) {
          downloadsDir.createSync(recursive: true); // Ensure the directory exists
        }
        final file = File('${downloadsDir.path}/downloaded_pdf.pdf');
        await file.writeAsBytes(response.bodyBytes);

        // Show popup after successful download
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Download Complete'),
            content: Text('PDF has been downloaded to the Downloads folder.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF: $e')),
      );
    }
  }

  Future<void> _showDownloadConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download PDF'),
        content: Text('Are you sure you want to download this PDF?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Download'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _downloadPdfToLocal();
    }
  }

  @override
  void dispose() {
    if (!isError && localPdfPath != null) {
      _pdfController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _showDownloadConfirmation,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
          ? Center(child: Text('Error loading PDF'))
          : PdfViewPinch(
        controller: _pdfController,
      ),
    );
  }
}
