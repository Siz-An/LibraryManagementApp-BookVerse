// home_screen.dart
import 'package:book_Verse/features/home/screens/users/home/widget/gerne.dart';
import 'package:book_Verse/features/home/screens/users/home/widget/grade.dart';
import 'package:book_Verse/features/home/screens/users/home/widget/home_appbar.dart';
import 'package:book_Verse/features/home/screens/users/home/widget/promo_slider.dart';
import 'package:flutter/material.dart';
import '../../../../../common/widgets/custom_shapes/primary_header_container.dart';
import '../../../../../common/widgets/custom_shapes/rounded_container.dart';
import '../../../../../common/widgets/images/t_circular_image.dart';
import '../../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../../common/widgets/texts/T_genreTitle.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_function.dart';
import 'books /Course books /BCA/firstSem.dart'; // Import grades list from grades.dart

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// ---> Header
            const TPrimaryHeaderContainer(
              child: Column(
                children: [
                  SizedBox(height: TSizes.sm,),
                  /// ---> Appbar
                   THomeAppBar(), // Example placeholder
                 // SizedBox(height: TSizes.spaceBtwSections),

                  /// ---> searchBar
                 // TSearchContainer(text: 'Search in Library'),
                 // SizedBox(height: TSizes.spaceBtwSections),

                  /// ---> categories <-----
                  Padding(
                    padding: EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Heading
                        // TSectionHeading(title: 'Popular Genre', showActionButton: false, textColor: Colors.white,),
                        SizedBox(height: TSizes.spaceBtwItems),

                        /// Categories
                        // THomeCategory() // Example placeholder
                      ],
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            /// ----> Body Part
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  const TPromoSlide( // Example placeholder
                       banner: [
                          TImages.promoBanner1,
                         TImages.promoBanner2,
                        TImages.promoBanner3,
                        TImages.promoBanner4
                       ]
                   ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  ///----> Heading
                  TSectionHeading(
                    title: '| Course Books',
                    showActionButton: true,
                    onPressed: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// ----> Grade section
                  TGridLayout(
                    itemCount: grades.length,
                    mainAxisExtent: 80,
                    itemBuilder: (_, index) {
                      final grade = grades[index];
                      return GestureDetector(
                        onTap: () {
                          // Example navigation to a specific grade screen
                           Navigator.push(context, MaterialPageRoute(builder: (_) => firstSem()));
                        },
                        child: TRoundedContainer(
                          padding: const EdgeInsets.all(TSizes.md),
                          showBorder: true,
                          backgroundColor: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                grade['name'],
                                style: const TextStyle(
                                  fontSize: TSizes.fontSizeMd,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${grade['semesters']} Semesters',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  ///----> Heading
                  TSectionHeading(
                    title: '| Genre ',
                    showActionButton: true,
                    onPressed: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  TGridLayout(
                    itemCount: genres.length,
                    mainAxisExtent: 80,
                    itemBuilder: (_, index) {
                      final genre = genres[index];
                      return GestureDetector(
                        onTap: () {
                          // Example action when tapping on a genre
                          // print('Selected genre: ${genre['name']}');
                        },
                        child: TRoundedContainer(
                          padding: const EdgeInsets.all(TSizes.sm),
                          showBorder: true,
                          backgroundColor: Colors.transparent,
                          child: Row(
                            children: [
                              /// Icon
                              Flexible(
                                child: TCircularImage(
                                  isNetworkImage: false,
                                  image: genre['icon'],
                                  backgroundColor: Colors.transparent,
                                  overlayColor: THelperFunction.isDarkMode(context)
                                      ? TColors.white
                                      : TColors.black,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TGenreTitleWithVerification(
                                    title: genre['name'],
                                    genreTextSizes: TextSizes.large,
                                  ),
                                  Text(
                                    '${genre['books']} books',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
