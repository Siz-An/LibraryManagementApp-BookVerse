import 'package:book_Verse/common/widgets/layouts/grid_layout.dart';
import 'package:book_Verse/features/home/screens/home/books%20/Course%20books%20/BCA/firstSem.dart';
import 'package:book_Verse/features/home/screens/home/widget/home_appbar.dart';
import 'package:book_Verse/features/home/screens/home/widget/promo_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/custom_shapes/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/rounded_container.dart';
import '../../../../common/widgets/custom_shapes/search_container.dart';
import '../../../../common/widgets/images/t_circular_image.dart';
import '../../../../common/widgets/texts/T_genreTitle.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';

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
                  THomeAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// ---> searchBar
                  TSearchContainer(text: 'Search in Library'),
                  SizedBox(height: TSizes.spaceBtwSections),

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
                        // THomeCategory()
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
                  const TPromoSlide(
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
                    itemCount: 4,
                    mainAxisExtent: 80,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to BCA firstSem screen
                          Get.to(() => firstSem());
                        },
                        child: TRoundedContainer(
                          padding: const EdgeInsets.all(TSizes.md),
                          showBorder: true,
                          backgroundColor: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                 'BCA',
                                style: TextStyle(
                                  fontSize: TSizes.fontSizeMd,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                '8 Semesters',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelLarge,
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
                    itemCount: 10,
                    mainAxisExtent: 80,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () {},
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
                                  image: TImages.genreIcon2,
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
                                  const TGenreTitleWithVerification(
                                    title: 'Romance',
                                    genreTextSizes: TextSizes.large,
                                  ),
                                  Text(
                                    '10 books',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.labelMedium,
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
