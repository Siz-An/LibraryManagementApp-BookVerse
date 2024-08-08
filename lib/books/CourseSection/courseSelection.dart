import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/home/screens/user/home/widget/bookList_Screen.dart';
import '../detailScreen/course_book_detail_screen.dart';

class CourseSelectionScreen extends StatelessWidget {
  final String grade;

  const CourseSelectionScreen({Key? key, required this.grade}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Course for Grade $grade')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('grade', isEqualTo: grade)
            .where('isCourseBook', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!.docs;

          final courses = books.map((book) => book['course'] as String?)
              .where((course) => course != null)
              .cast<String>()
              .toSet()
              .toList();

          if (courses.isEmpty) {
            // No courses, directly show books
            return Padding(
              padding: const EdgeInsets.only(top: 16.0), // Adjust the padding as needed
              child: Column(
                children: [
                  Divider(height: 1.0, color: Colors.grey[300]), // Top divider
                  Expanded(
                    child: ListView.separated(
                      itemCount: books.length,
                      separatorBuilder: (context, index) => Divider(height: 1.0, color: Colors.grey[300]),
                      itemBuilder: (context, index) {
                        final book = books[index].data() as Map<String, dynamic>;
                        final title = book['title'] ?? 'No Title';
                        final writer = book['writer'] ?? 'Unknown Writer';
                        final imageUrl = book['imageUrl'] ?? '';
                        final course = book['course'] ?? '';
                        final summary = book['summary'] ?? '';

                        return ListTile(
                          title: Text(title),
                          subtitle: Text(writer),
                          leading: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseBookDetailScreen(
                                  title: title,
                                  writer: writer,
                                  imageUrl: imageUrl,
                                  course: course,
                                  summary: summary,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Divider(height: 1.0, color: Colors.grey[300]), // Bottom divider
                ],
              ),
            );
          } else {
            // Show courses with dividers
            return Padding(
              padding: const EdgeInsets.only(top: 16.0), // Adjust the padding as needed
              child: Column(
                children: [
                  Divider(height: 1.0, color: Colors.grey[300]), // Top divider
                  Expanded(
                    child: ListView.separated(
                      itemCount: courses.length,
                      separatorBuilder: (context, index) => Divider(height: 1.0, color: Colors.grey[300]),
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return ListTile(
                          title: Center(
                            child: Text(
                              course,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookListScreen(
                                  isCourseBook: true,
                                  filter: course,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Divider(height: 1.0, color: Colors.grey[300]), // Bottom divider
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
