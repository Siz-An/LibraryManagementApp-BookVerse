import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/home/screens/user/home/widget/gerne.dart';
import '../course_book_detail_screen.dart';

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
              child: StreamBuilder<QuerySnapshot>(
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
                  if (books.isEmpty) {
                    return Center(child: Text('No books found for grade $grade'));
                  }

                  return ListView.builder(
                    itemCount: books.length,
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
                  );
                },
              ),
            );
          } else {
            // Show courses
            return Padding(
              padding: const EdgeInsets.only(top: 1.0), // Adjust the padding as needed
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Row(
                    children: [
                      SizedBox(width: 16.0), // Space before the box
                      Expanded(
                        child: GestureDetector(
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
                          child: Container(
                            width: 50, // Set explicit width
                            height: 80, // Set explicit height
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black87, width: 1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                course,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
