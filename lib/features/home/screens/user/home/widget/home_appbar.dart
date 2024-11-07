import 'package:book_Verse/common/widgets/products/bookmark/bookmark_icon.dart';
import 'package:book_Verse/features/personalization/controller/user_Controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/shimmer.dart';
import '../../../../../../utils/constants/text_strings.dart';
import '../../../../../personalization/profile/widgets/users_Screen.dart';
import '../../notipopup.dart';
import '../../reminder.dart';

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
          Text(
            TTexts.homeAppBarTitle,
            style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.grey),
          ),
          Obx(() {
            if (controller.profileLoading.value) {
              return const TShimmerEffect(width: 80, height: 15);
            } else {
              return Text(
                controller.user.value.fullName,
                style: Theme.of(context).textTheme.bodySmall!.apply(color: TColors.white),
              );
            }
          })
        ],
      ),
      showSearchBox: true,
      actions: [
        // Notification Icon with Count
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('isRead', isEqualTo: false) // Only count unread notifications
              .snapshots(),
          builder: (context, snapshot) {
            int notificationCount = 0;
            if (snapshot.hasData) {
              notificationCount = snapshot.data!.docs.length;
            }
            return TCartCounterIcons(
              onPressed: () => showNotificationPopup(context), // Open popup instead of navigating
              iconColor: Colors.yellowAccent,
              icon: Iconsax.notification,
              count: notificationCount,
            );
          },
        ),
        // User Icon without Count
        TCartCounterIcons(
          onPressed: () => Get.to(() => userScreen()),
          iconColor: TColors.white,
          icon: Iconsax.user,
          count: 0, // Optional: set to 0 as there's no badge needed for the user icon
        ),
      ],
    );
  }
}
