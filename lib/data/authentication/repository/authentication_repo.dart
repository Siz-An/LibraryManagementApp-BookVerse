import 'package:book_Verse/features/authentication/screens/login/login.dart';
import 'package:book_Verse/navigation_menu/navigation_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import '../../../features/authentication/screens/onboarding.dart';
import '../../../features/authentication/screens/signup/verify_email.dart';
import '../../../utils/exceptions/firebase_auth_exception.dart';
import '../../../utils/exceptions/firebase_exception.dart';
import '../../../utils/exceptions/format_exception.dart';
import '../../../utils/exceptions/platform_exception.dart';

class AuthenticationRepository extends GetxController{
  static AuthenticationRepository get instance => Get.find();

  /// Variables
   final deviceStorage = GetStorage();
   final _auth = FirebaseAuth.instance;

   /// Called from main.dart on app launch
   @override
 void onReady(){
     FlutterNativeSplash.remove();
     screenRedirect();
   }

   ///---> Function to show Relevant Screen
   screenRedirect() async{
    final user = _auth.currentUser;
     if(user != null){
       if(user.emailVerified){
         Get.offAll(() => const NavigationMenu());
       }else{
         Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email));
       }
     }else {
       // local Storage
       deviceStorage.writeIfNull('isFirstTime', true);
       deviceStorage.read('isFirstTime') != true
           ? Get.offAll(() => const LoginScreen())
           : Get.offAll(() => const OnBoardingScreen());
     }
   }

   /*-------------------------Email & Password Sign in---------------------------*/

///---> [Email Authentication] -- SignIn


///---> [Email Authentication] -- Register

Future<UserCredential> registerWithEmailAndPassword(String email, String password) async{
  try{
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch(e){
    throw TFirebaseAuthException(e.code).message;
  }on FirebaseException catch(e){
    throw TFirebaseException(e.code).message;
  }on FormatException catch(_){
    throw const TFormatException();
  }on PlatformException catch(e){
    throw TPlatformException(e.code).message;
  } catch(e){
    throw 'SomeThing Went Wrong Please Try Again';
  }
}

///---> [Email Authentication] -- Mail Verification

    Future<void> sendEmailVerification() async{
      try{
         await _auth.currentUser?.sendEmailVerification();
      } on FirebaseAuthException catch(e){
        throw TFirebaseAuthException(e.code).message;
      }on FirebaseException catch(e){
        throw TFirebaseException(e.code).message;
      }on FormatException catch(_){
        throw const TFormatException();
      }on PlatformException catch(e){
        throw TPlatformException(e.code).message;
      } catch(e){
        throw 'SomeThing Went Wrong Please Try Again';
      }
    }

///---> [Email Authentication] -- ReAuthentication USer


///---> [Email Authentication] -- Forget Password



/// [LogOutUser] - valid for any authentication
  Future<void> logout() async{
    try{
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch(e){
      throw TFirebaseAuthException(e.code).message;
    }on FirebaseException catch(e){
      throw TFirebaseException(e.code).message;
    }on FormatException catch(_){
      throw const TFormatException();
    }on PlatformException catch(e){
      throw TPlatformException(e.code).message;
    } catch(e){
      throw 'SomeThing Went Wrong Please Try Again';
    }
  }

}