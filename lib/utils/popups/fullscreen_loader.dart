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
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: THelperFunction.isDarkMode(Get.context!) ? TColors.dark : TColors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TAnimationLoaderWidget(
                text: text,
                animation: animation,
              ),
            ],
          ),
        ),
      ),
    );
  }
  static stopLoading(){
    Navigator.of(Get.overlayContext!).pop();
  }
}
