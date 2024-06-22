import 'package:book_Verse/common/widgets/custom_shapes/rounded_container.dart';
import 'package:book_Verse/common/widgets/custom_shapes/search_container.dart';
import 'package:book_Verse/common/widgets/layouts/grid_layout.dart';
import 'package:book_Verse/common/widgets/texts/section_heading.dart';
import 'package:book_Verse/utils/constants/colors.dart';
import 'package:book_Verse/utils/constants/enums.dart';
import 'package:book_Verse/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/appbar/tabbar.dart';
import '../../../../common/widgets/images/t_circular_image.dart';
import '../../../../common/widgets/products/bookmark/bookmark_icon.dart';
import '../../../../common/widgets/texts/T_genreTitle.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
length: 4,

      child: Scaffold(
        appBar: TAppBar(
          title: Text(
            'Book Verse',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [
            TCartCounterIcons(onPressed: () {}),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                backgroundColor: THelperFunction.isDarkMode(context)
                    ? TColors.black
                    : TColors.white,
                expandedHeight: 405,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      /// Search Bar
                      const SizedBox(height: TSizes.spaceBtwItems),
                      const TSearchContainer(
                        text: 'Search',
                        showBorder: true,
                        showBackground: false,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections / 4),

                      /// Featured Genre
                      TSectionHeading(
                        title: 'Featured Genre',
                        showActionButton: true,
                        onPressed: () {},
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections / 7),

                      TGridLayout(
                        itemCount: 4,
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
                bottom: const TTabBar(
                  tabs: [
                    Tab(child: Text('Romance')),
                    Tab(child: Text('BioGraph')),
                    Tab(child: Text('History')),
                    Tab(child: Text('Horror')),

                  ],
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              /// Content for Romance tab
              Padding(
                padding: EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    TRoundedContainer(
                      showBorder: true,
                      borderColor: TColors.darkerGrey,
                      backgroundColor: Colors.transparent,
                      margin: EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                      child: Column(),
                    ),
                  ],
                ),
              ),
              /// Content for Horror tab
              Padding(
                padding: EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    TRoundedContainer(
                      showBorder: true,
                      borderColor: TColors.darkerGrey,
                      backgroundColor: Colors.transparent,
                      margin: EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                      child: Column(),
                    ),
                  ],
                ),
              ),
              /// Content for Mystery tab
              Padding(
                padding: EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    TRoundedContainer(
                      showBorder: true,
                      borderColor: TColors.darkerGrey,
                      backgroundColor: Colors.transparent,
                      margin: EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                      child: Column(),
                    ),
                  ],
                ),
              ),
              /// Content for Thriller tab
              Padding(
                padding: EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    TRoundedContainer(
                      showBorder: true,
                      borderColor: TColors.darkerGrey,
                      backgroundColor: Colors.transparent,
                      margin: EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                      child: Column(),
                    ),
                  ],
                ),
              ),



            ],
          ),
        ),
      ),
    );
  }
}
