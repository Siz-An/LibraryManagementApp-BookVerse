import 'package:book_Verse/features/home/screens/user/home/widget/gerne.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../utils/constants/sizes.dart';

class CourseGradesScreen extends StatelessWidget {
  final String course;

  const CourseGradesScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grades for $course')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('isCourseBook', isEqualTo: true)
            .where('course', isEqualTo: course)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!.docs;

          // Debugging print statements
          print('Course filter: $course');
          print('Books found: ${books.length}');

          if (books.isEmpty) {
            return Center(child: Text('No books found for this course.'));
          }

          final grades = books.map((book) => book['grade']).toSet().toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: TSizes.cardRadiusSm,
              mainAxisSpacing: TSizes.cardRadiusSm,
              childAspectRatio: 3,
            ),
            itemCount: grades.length,
            itemBuilder: (context, index) {
              final grade = grades[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookListScreen(
                        isCourseBook: true,
                        filter: grade,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(TSizes.sm),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      grade,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
