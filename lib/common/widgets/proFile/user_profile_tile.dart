
import 'package:book_Verse/features/personalization/controller/user_Controller.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../images/t_circular_image.dart';

class TUserProfileTitle extends StatelessWidget {
  const TUserProfileTitle({
    super.key, required this.onPressed,
  });
  final  VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return ListTile(
      leading: const TCircularImage(image: TImages.genreIcon, width: 50, height: 50, padding: 0,),
      title: Text(controller.user.value.fullName, style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.white),),
      subtitle: Text(controller.user.value.email, style: Theme.of(context).textTheme.bodySmall!.apply(color: TColors.white),),
      trailing: IconButton(onPressed: onPressed, icon: const Icon(Iconsax.edit, color: TColors.white,),),
    );
  }
}
