import 'package:book_Verse/utils/constants/colors.dart';
import 'package:book_Verse/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/loaders/animation_loader.dart';

class TFullScreenLoader {
  static void openLoadingDialogue(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => AbsorbPointer(
        absorbing: true,
        child: Dialog(
          backgroundColor: THelperFunction.isDarkMode(Get.context!) ? TColors.dark : TColors.white,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TAnimationLoaderWidget(
                  text: text,
                  animation: animation,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  static void stopLoading() {
    Navigator.of(Get.overlayContext!).pop();
  }
}
