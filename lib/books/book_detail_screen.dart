// import 'package:flutter/material.dart';
//
// class BookDetailScreen extends StatelessWidget {
//   final String title;
//   final String writer;
//   final String imageUrl;
//   final String genre;
//   final String course;
//   final String summary;
//
//   const BookDetailScreen({
//     Key? key,
//     required this.title,
//     required this.writer,
//     required this.imageUrl,
//     required this.genre,
//     required this.course,
//     required this.summary,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     print('Image URL: $imageUrl'); // Debugging line
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: imageUrl.isNotEmpty
//                   ? Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 height: 200,
//                 width: 150, // Adjusted width
//                 errorBuilder: (context, error, stackTrace) {
//                   print('Image load error: $error'); // Debugging line
//                   return Center(
//                     child: Text(
//                       'Image not available',
//                       style: TextStyle(color: Colors.red, fontSize: 16),
//                     ),
//                   );
//                 },
//               )
//                   : Text(
//                 'Image not available',
//                 style: TextStyle(color: Colors.red, fontSize: 16),
//               ),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Title: $title',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Writer: $writer',
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 8),
//             if (genre.isNotEmpty)
//               Text(
//                 'Genre: $genre',
//                 style: TextStyle(fontSize: 16),
//               ),
//             if (course.isNotEmpty)
//               Text(
//                 'Course: $course',
//                 style: TextStyle(fontSize: 16),
//               ),
//             SizedBox(height: 16),
//             Text(
//               'Summary:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text(
//               summary.isNotEmpty ? summary : 'Summary not available',
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
