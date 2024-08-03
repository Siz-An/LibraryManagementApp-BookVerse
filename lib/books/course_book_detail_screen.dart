import 'package:flutter/material.dart';

class CourseBookDetailScreen extends StatelessWidget {
  final String title;
  final String writer;
  final String imageUrl;
  final String course;
  final String summary;

  const CourseBookDetailScreen({
    Key? key,
    required this.title,
    required this.writer,
    required this.imageUrl,
    required this.course,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                imageUrl,
                width: 190,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text('Image not available', style: TextStyle(color: Colors.red)));
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Title: $title',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Writer: $writer',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Course: $course',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Summary:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(summary),
          ],
        ),
      ),
    );
  }
}
