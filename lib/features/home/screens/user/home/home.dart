import 'package:book_Verse/features/home/screens/user/home/widget/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../books/contentbasedrecommendation.dart';
import '../../../../../books/detailScreen/genre_book_detail_screen.dart'; // Import the new file
import '../../../../../books/CourseSection/courseSelection.dart';
import '../../../../../books/randombooks.dart';
import '../../../../../common/widgets/custom_shapes/primary_header_container.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            const TPrimaryHeaderContainer(
              child: Column(
                children: [
                  SizedBox(height: TSizes.sm),
                  THomeAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            // Body Part
            Padding(
              padding: const EdgeInsets.all(TSizes.cardRadiusSm),
              child: Column(
                children: [
                  const ContentBasedAlgorithm(),
                  const Divider(),
                  const TRandomBooks(),
                  const Divider(),
                  // Course Books Section
                  TSectionHeading(
                    title: '| Course Books',
                    fontSize: 25,
                    onPressed: () {},
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('books')
                        .where('isCourseBook', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final books = snapshot.data!.docs;

                      // Group books by grade
                      final Map<String, List<QueryDocumentSnapshot>> groupedBooks = {};
                      for (var book in books) {
                        final grade = book['grade'] as String?;
                        if (grade != null) {
                          if (!groupedBooks.containsKey(grade)) {
                            groupedBooks[grade] = [];
                          }
                          groupedBooks[grade]!.add(book);
                        }
                      }

                      final grades = groupedBooks.keys.toList();

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 4 / 3,
                        ),
                        itemCount: grades.length,
                        itemBuilder: (context, index) {
                          final grade = grades[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseSelectionScreen(grade: grade),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.school,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    grade,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                  ,
                  const Divider(),

                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Genre Section
                  TSectionHeading(
                    title: '| Genre',
                    fontSize: 25,
                    onPressed: () {},
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('books')
                        .where('isCourseBook', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final books = snapshot.data!.docs;

                      // Group books by genre
                      final Map<String, List<QueryDocumentSnapshot>> groupedBooks = {};
                      for (var book in books) {
                        final genres = book['genre'] as List<dynamic>?;
                        if (genres != null) {
                          for (var genre in genres) {
                            if (genre is String) {
                              if (!groupedBooks.containsKey(genre)) {
                                groupedBooks[genre] = [];
                              }
                              groupedBooks[genre]!.add(book);
                            }
                          }
                        }
                      }

                      final genres = groupedBooks.keys.toList();

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3 ,
                        ),
                        itemCount: genres.length,
                        itemBuilder: (context, index) {
                          final genre = genres[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GenreBookDetailScreen(genre: genre),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green, Colors.greenAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Container(
                                height: 60, // Adjust this height if needed
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green, Colors.greenAccent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center( // Center the content
                                  child: Text(
                                    genre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                            ),

                          );
                        },
                      );
                    },
                  )

                  ,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
