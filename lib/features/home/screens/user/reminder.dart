// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// void showReminderPopup(BuildContext context, String userId) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         contentPadding: EdgeInsets.zero,
//         content: Container(
//           width: MediaQuery.of(context).size.width * 0.8,
//           height: MediaQuery.of(context).size.height * 0.6,
//           child: Column(
//             children: [
//               Align(
//                 alignment: Alignment.topRight,
//                 child: IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   'Reminders',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ),
//               const Divider(
//                 color: Colors.grey,
//                 thickness: 1,
//                 indent: 20,
//                 endIndent: 20,
//               ),
//               Expanded(
//                 child: StreamBuilder(
//                   stream: FirebaseFirestore.instance
//                       .collection('issuedBooks')
//                       .where('userId', isEqualTo: userId)
//                       .orderBy('timestamp')
//                       .snapshots(),
//                   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (!snapshot.hasData) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Text(
//                           'Error: ${snapshot.error}',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                       );
//                     }
//
//                     final reminders = snapshot.data?.docs ?? [];
//
//                     // If no reminders found, show a message
//                     if (reminders.isEmpty) {
//                       return const Center(
//                         child: Text(
//                           'No reminders found.',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       );
//                     }
//
//                     return ListView.builder(
//                       itemCount: reminders.length,
//                       itemBuilder: (context, index) {
//                         final reminder = reminders[index].data() as Map<String, dynamic>;
//                         final bookTitle = reminder['bookTitle'] ?? 'Unknown Book';
//                         final issueDate = (reminder['issueDate'] as Timestamp).toDate();
//                         final returnDate = (reminder['returnDate'] as Timestamp).toDate();
//
//                         return ListTile(
//                           title: Text(bookTitle),
//                           subtitle: Text(
//                             'Issued on: ${formatDate(issueDate)}\nReturn by: ${formatDate(returnDate)}',
//                           ),
//                           onTap: () {
//                             // You can add any action here if needed
//                           },
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
//
// /// Helper function to format date into a readable format
// String formatDate(DateTime date) {
//   return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
// }
