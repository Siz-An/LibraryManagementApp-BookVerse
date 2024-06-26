import 'package:book_Verse/features/home/screens/home/books%20/Course%20books%20/BCA/firstSem.dart';
import 'package:book_Verse/features/home/screens/home/widget/home_appbar.dart';
import 'package:book_Verse/features/home/screens/home/widget/home_category.dart';
import 'package:book_Verse/features/home/screens/home/widget/promo_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../common/widgets/custom_shapes/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/search_container.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/profile/widgets/profile_menu.dart';


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
                  SizedBox(height: TSizes.spaceBtwSections),
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
                   TSectionHeading(title: '| Course Books',showActionButton: true, onPressed: (){},),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// ----> Grade section 
                  
                  ///----> BCA
                  TProfileMenu(onPressed: ()=> Get.to(() => const firstSem()), title: 'BCA Books', value: '',),
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ///----> BBA
                  TProfileMenu(onPressed: () { }, title: 'BBA Books', value: '',),
                  Divider(
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ///----> BBS
                  TProfileMenu(onPressed: () {  }, title: 'BBS Books', value: '',),
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ///----> Bsc-CsIT
                  TProfileMenu(onPressed: () {  }, title: 'Bsc-CsIT Books', value: '',),
                  SizedBox(height: TSizes.spaceBtwItems),

                  ///----> 2nd Heading
                  TSectionHeading(title: '| Genre',showActionButton: true, onPressed: (){},),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  ///---->Fiction
                  TProfileMenu(onPressed: () {  }, title: 'Fiction Books', value: '',),
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ///----> Horror
                  TProfileMenu(onPressed: () {  }, title: 'Horror Books', value: '',),
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ///----> Thriller
                  TProfileMenu(onPressed: () {  }, title: 'Thriller Books', value: '',),
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ///----> Mystery
                  TProfileMenu(onPressed: () {  }, title: 'Mystery Books', value: '',),
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ///---->Romance
                  TProfileMenu(onPressed: () {  }, title: 'Romance Books', value: '',),
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ///----> Adventure
                  TProfileMenu(onPressed: () {  }, title: 'Adventure Books', value: '',),
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ///----> Bio Graph
                  TProfileMenu(onPressed: () {  }, title: 'Bio-Graph Books', value: '',),
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ///----> Poetry
                  TProfileMenu(onPressed: () {  }, title: 'Poetry Books', value: '',),
                  SizedBox(height: TSizes.spaceBtwItems),


                ],
              )
            )
          ],
        ),
      ),
    );
  }
}








