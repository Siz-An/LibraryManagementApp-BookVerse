

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../screens/login/login.dart';

class OnboardingController extends GetxController{
  static OnboardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

 /// Update Current Index when Page Scroll
  void updatePageIndicator(index) => currentPageIndex.value = index;

  /// Jump to the specific dot selected page
  void dotNavigationClick(index){
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  /// Update Current Index & Jump to the next Page
  void nextPage(){
    if(currentPageIndex.value == 2){
      final storage = GetStorage();
      if(kDebugMode){
        print('============ Get Storage Next Button ===========');
        print(storage.read('isFirstTime'));
      }
      storage.write('isFirstTime', false);

       Get.offAll(const LoginScreen());
      if(kDebugMode){
        print('============ Get Storage Next Button ===========');
        print(storage.read('isFirstTime'));
      }
    }else{
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  /// Update Current Index & Jump to the Last Page
  void skipPage(){
    currentPageIndex.value = 3;
    pageController.jumpToPage(3);
  }


}

