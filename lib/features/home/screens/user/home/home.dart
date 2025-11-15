import 'package:book_Verse/features/home/screens/user/home/widget/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../books/CollaborativeRecommendation.dart';
import '../../../../../books/contentbasedrecommendation.dart';
import '../../../../../books/detailScreen/genre_book_detail_screen.dart'; // Import the new file
import '../../../../../books/CourseSection/courseSelection.dart';
import '../../../../../common/widgets/custom_shapes/primary_header_container.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(
            child: TPrimaryHeaderContainer(
              child: Column(
                children: [
                  SizedBox(height: TSizes.sm),
                  THomeAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
          ),

          // Body Part
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.cardRadiusSm),
              child: Column(
                children: [
                  // Personalized Recommendations Section
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personalized For You',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Recommended books based on your interests',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 15),
                          ContentBasedAlgorithm(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Course Books Section
                  TSectionHeading(
                    title: 'Course Books',
                    fontSize: 22,
                    onPressed: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

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

                      return SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: grades.length,
                          itemBuilder: (context, index) {
                            final grade = grades[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CourseSelectionScreen(grade: grade),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.school,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        grade,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Genre Section
                  TSectionHeading(
                    title: 'Browse by Genre',
                    fontSize: 22,
                    onPressed: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

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

                      return SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: genres.length,
                          itemBuilder: (context, index) {
                            final genre = genres[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GenreBookDetailScreen(genre: genre),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF9A8C98), Color(0xFF4A4E69)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Background pattern
                                      Positioned(
                                        right: -20,
                                        top: -20,
                                        child: Opacity(
                                          opacity: 0.1,
                                          child: Transform.rotate(
                                            angle: 0.5,
                                            child: Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            genre,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Random Books Section
                  TSectionHeading(
                    title: 'Popular Books',
                    fontSize: 22,
                    onPressed: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const TRandomBooks(),
                  const SizedBox(height: TSizes.spaceBtwSections * 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}