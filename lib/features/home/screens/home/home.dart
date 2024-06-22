import 'package:book_Verse/features/home/screens/home/widget/home_appbar.dart';
import 'package:book_Verse/features/home/screens/home/widget/home_category.dart';
import 'package:book_Verse/features/home/screens/home/widget/promo_slider.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_shapes/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/search_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/products/product_card/product_card_vertical.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ---> Header
            const TPrimaryHeaderContainer(
              child: Column(
                children: [
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
                        TSectionHeading(title: 'Popular Genre', showActionButton: false, textColor: Colors.white,),
                        SizedBox(height: TSizes.spaceBtwItems),
                        /// Categories
                        THomeCategory()
                      ],
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwSections,)
                ],
              ),
            ),
            /// ----> Body Part
            Padding(
              padding:  const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  const TPromoSlide(banner: [TImages.promoBanner1,TImages.promoBanner2,TImages.promoBanner3,TImages.promoBanner4]),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  ///----> Heading
                   TSectionHeading(title: 'Popular Books',showActionButton: true, onPressed: (){},),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// ----> Popular Books
                  TGridLayout(itemCount: 8, itemBuilder: (_, index) => const TProductCardVertical()),


                ],
              )
            )
          ],
        ),
      ),
    );
  }
}








