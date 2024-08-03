import 'package:book_Verse/common/widgets/products/bookmark/bookmark_icon.dart';
import 'package:book_Verse/features/personalization/controller/user_Controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/shimmer.dart';
import '../../../../../../utils/constants/text_strings.dart';
import '../../search/search.dart';
import '../../search/userSearch.dart';

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    return TAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( TTexts.homeAppBarTitle, style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.grey),),
          Obx((){
            if(controller.profileLoading.value){
              return const TShimmerEffect(width: 80, height: 15);
            }else{
              return Text( controller.user.value.fullName, style: Theme.of(context).textTheme.bodySmall!.apply(color: TColors.white ));
            }
          })
        ],
      ),
      actions:  [
        TCartCounterIcons(onPressed: () => Get.to(()=> UserSearch()),iconColor: TColors.white,)
      ],
    );
  }
}