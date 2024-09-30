import 'package:book_Verse/common/widgets/products/bookmark/bookmark_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/shimmer.dart';
import '../../../../../../utils/constants/text_strings.dart';
import '../../../../personalization/controller/admin_Controller.dart';
import '../../user/notification.dart';

class TAdminAppBar extends StatelessWidget {
  const TAdminAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    return TAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( TTexts.homeAppBarTitle, style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.grey),),
          Obx((){
            if(controller.profileLoading.value){
              return const TShimmerEffect(width: 80, height: 15);
            }else{
              return Text( controller.admin.value.fullName, style: Theme.of(context).textTheme.bodySmall!.apply(color: TColors.white ));
            }
          })
        ],
      ),
      actions:  [
        TCartCounterIcons(onPressed: () => Get.to(()=> AdminNotificationScreen()),iconColor: TColors.white, icon: Iconsax.user,),
      ],
    );
  }
}